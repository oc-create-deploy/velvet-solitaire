import 'package:flutter/material.dart';

class Options extends StatelessWidget {
  const Options({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff082f28),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.style, color: Color(0xffdfc886), size: 64),
              const SizedBox(height: 20),
              const Text(
                'Velvet Solitaire',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A quiet moment. A fresh deck.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: Color(0xffb7d9cb)),
              ),
              const SizedBox(height: 32),
              _mode(
                context,
                'Klondike',
                'The classic seven-column challenge',
                '/klondike',
              ),
              _mode(
                context,
                'Spider',
                'Build complete descending sequences',
                '/spider',
              ),
              _mode(
                context,
                'Invert',
                'A fresh twist: build foundations downward',
                '/invert',
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/rules'),
                child: const Text(
                  'How to play',
                  style: TextStyle(color: Color(0xffdfc886), fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _mode(
    BuildContext context,
    String title,
    String subtitle,
    String route,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card(
      color: const Color(0xff155444),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            subtitle,
            style: const TextStyle(color: Color(0xffc4e0d4), fontSize: 15),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xffdfc886)),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    ),
  );
}
