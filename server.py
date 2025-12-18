from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import firebase_admin
from firebase_admin import credentials, messaging, firestore

app = Flask(__name__)
CORS(app)  # Flutter cihazından yerel ağa istek için

# --- Firebase Admin init ---
KEY_PATH = os.getenv("FIREBASE_KEY", "firebase-key.json")
if not os.path.exists(KEY_PATH):
    raise FileNotFoundError(f"Firebase service account JSON bulunamadı: {KEY_PATH}")

cred = credentials.Certificate(KEY_PATH)
default_app = firebase_admin.initialize_app(cred)
db = firestore.client()

# 🔹 token → userId bulmak için cache
_token_uid_cache = {}
def get_user_id_by_token(token: str):
    if token in _token_uid_cache:
        return _token_uid_cache[token]
    q = db.collection("users").where("fcmToken", "==", token).limit(1).stream()
    uid = None
    for doc in q:
        uid = doc.id
        break
    _token_uid_cache[token] = uid
    return uid


@app.get("/health")
def health():
    """Sunucu canlılık testi"""
    return jsonify({"ok": True}), 200


@app.post("/notify")
def notify():
    """
    POST /notify
    BODY (JSON) örneği:
    {
      "tokens": ["token1","token2"],      // en az 1 adet
      "title": "Kan Bağışı Çağrısı",
      "body": "A+ için acil ihtiyaç: Manisa Merkez",
      "data": {"announcementId": "abc123", "blood":"A+"}
    }
    """
    try:
        data = request.get_json(force=True) or {}
        tokens = data.get("tokens") or []
        title = data.get("title") or "Acil Kan İsteği"
        body = data.get("body") or "Lütfen uygulamayı açarak detayları kontrol edin."
        custom_data = data.get("data") or {}

        # Token doğrulama
        tokens = [t for t in tokens if isinstance(t, str) and t.strip()]
        if not tokens:
            return jsonify({"ok": False, "error": "Token listesi boş"}), 400

        # Tek token → daha anlamlı hata için
        if len(tokens) == 1:
            msg = messaging.Message(
                notification=messaging.Notification(title=title, body=body),
                data={k: str(v) for k, v in custom_data.items()},
                token=tokens[0],
            )
            resp = messaging.send(msg, app=default_app)

            # 🔹 Firestore log
            uid = get_user_id_by_token(tokens[0])
            if uid:
                db.collection("notifications").add({
                    "userId": uid,
                    "title": title,
                    "body": body,
                    "announcementId": str(custom_data.get("announcementId", "")),
                    "token": tokens[0],
                    "status": "sent",
                    "createdAt": firestore.SERVER_TIMESTAMP,
                })

            return jsonify({"ok": True, "sent": 1, "failed": 0, "message_id": resp}), 200

        # Çoklu token → multicast
        mmsg = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in custom_data.items()},
            tokens=tokens,
        )
        mresp = messaging.send_multicast(mmsg, app=default_app)

        # 🔹 Başarılı/başarısızları Firestore’a kaydet
        batch = db.batch()
        for idx, r in enumerate(mresp.responses):
            token = tokens[idx]
            uid = get_user_id_by_token(token)
            if not uid:
                continue
            docref = db.collection("notifications").document()
            batch.set(docref, {
                "userId": uid,
                "title": title,
                "body": body,
                "announcementId": str(custom_data.get("announcementId", "")),
                "token": token,
                "status": "sent" if r.success else "failed",
                "error": "" if r.success else str(r.exception),
                "createdAt": firestore.SERVER_TIMESTAMP,
            })
        batch.commit()

        errors = []
        for idx, r in enumerate(mresp.responses):
            if not r.success:
                errors.append({"token": tokens[idx], "error": str(r.exception)})

        return jsonify({
            "ok": True,
            "sent": mresp.success_count,
            "failed": mresp.failure_count,
            "errors": errors
        }), 200

    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 500


if __name__ == "__main__":
    # 0.0.0.0 → telefondan erişebilmek için
    app.run(host="0.0.0.0", port=5001, debug=True)
