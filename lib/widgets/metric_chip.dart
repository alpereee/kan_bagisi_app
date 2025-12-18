import 'package:flutter/material.dart';

class MetricChip extends StatelessWidget {
  final String label;
  const MetricChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withAlpha((255 * 0.12).round()),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w700)),
    );
  }
}
