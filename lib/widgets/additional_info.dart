import 'package:flutter/material.dart';

class AdditionalInfo extends StatelessWidget {
  final String text;
  final IconData icon;
  final String value;
  const AdditionalInfo({
    super.key,
    required this.text,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
