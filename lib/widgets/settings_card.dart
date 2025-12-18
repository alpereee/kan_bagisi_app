import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final Widget header;
  final List<Widget> children;
  final bool showDivider;

  const SettingsCard({
    super.key,
    required this.header,
    this.children = const [],
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            header,
            if (showDivider) const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}
