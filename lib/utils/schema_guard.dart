import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchemaGuard {
  /// Giriş/kayıt biter bitmez bir kez çağır.
  static Future<void> ensureUserDefaults() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final Map<String, dynamic>? data = snap.data();
      final patch = <String, dynamic>{};

      if (!(data?.containsKey('points') ?? false)) patch['points'] = 0;
      if (!(data?.containsKey('donationCount') ?? false)) patch['donationCount'] = 0;
      if (!(data?.containsKey('isAvailable') ?? false)) patch['isAvailable'] = true;
      if (!(data?.containsKey('lastDonationAt') ?? false)) {
        patch['lastDonationAt'] = FieldValue.serverTimestamp();
      }

      if (patch.isNotEmpty) {
        tx.set(ref, patch, SetOptions(merge: true));
      }
    });
  }
}
