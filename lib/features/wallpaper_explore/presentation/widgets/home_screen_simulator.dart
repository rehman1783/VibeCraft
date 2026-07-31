import 'package:flutter/material.dart';

class HomeScreenSimulator extends StatelessWidget {
  const HomeScreenSimulator({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeight = constraints.maxHeight;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Search Bar Widget
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Search apps & web...',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.mic, color: Colors.white.withValues(alpha: 0.7), size: 18),
                  ],
                ),
              ),

              SizedBox(height: maxHeight * 0.03),

              // App Grid (2 rows x 4 cols) - Wrapped in Flexible & FittedBox to prevent overflow
              Flexible(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _AppIconItem(icon: Icons.phone, label: 'Phone', color: Colors.green),
                              _AppIconItem(icon: Icons.message, label: 'Messages', color: Colors.blue),
                              _AppIconItem(icon: Icons.camera_alt, label: 'Camera', color: Colors.purple),
                              _AppIconItem(icon: Icons.photo_library, label: 'Photos', color: Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _AppIconItem(icon: Icons.settings, label: 'Settings', color: Colors.grey),
                              _AppIconItem(icon: Icons.map, label: 'Maps', color: Colors.redAccent),
                              _AppIconItem(icon: Icons.music_note, label: 'Music', color: Colors.pinkAccent),
                              _AppIconItem(icon: Icons.store, label: 'Store', color: Colors.cyan),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Bottom App Dock
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DockIconItem(icon: Icons.phone, color: Colors.green),
                    _DockIconItem(icon: Icons.chat_bubble, color: Colors.lightBlue),
                    _DockIconItem(icon: Icons.language, color: Colors.indigo),
                    _DockIconItem(icon: Icons.camera_alt, color: Colors.deepOrange),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AppIconItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AppIconItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DockIconItem extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _DockIconItem({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
