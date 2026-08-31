import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'widgets/face_guide_overlay.dart';
import 'widgets/face_guide_painter.dart';

/// Throwaway debug screen for visually iterating on the face guide
/// linework without camera permissions.  Gated behind [kDebugMode] —
/// remove once the shape is confirmed.
class FaceGuideDebugPreview extends StatelessWidget {
  const FaceGuideDebugPreview({super.key});

  @override
  Widget build(BuildContext context) {
    assert(() {
      return true;
    }(), 'FaceGuideDebugPreview should only run in debug mode');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Face Guide Debug'),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Column(
        children: [
          // ── Full overlay preview (simulates camera Stack) ────────────
          Expanded(
            child: Stack(
              children: [
                // Fake camera background
                Container(color: const Color(0xFF1A1A2E)),

                // The actual overlay
                const FaceGuideOverlay(
                  guideState: FaceGuideState.neutral,
                ),
              ],
            ),
          ),

          // ── State switcher ──────────────────────────────────────────
          _StateSwitcher(),
        ],
      ),
    );
  }
}

class _StateSwitcher extends StatefulWidget {
  @override
  State<_StateSwitcher> createState() => _StateSwitcherState();
}

class _StateSwitcherState extends State<_StateSwitcher> {
  FaceGuideState _state = FaceGuideState.neutral;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'State: ${_state.name}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final s in FaceGuideState.values)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(s.name),
                    selected: _state == s,
                    selectedColor: Colors.white24,
                    labelStyle: TextStyle(
                      color: _state == s ? Colors.white : Colors.white54,
                    ),
                    onSelected: (_) => setState(() => _state = s),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Inline preview at a small fixed size
          Center(
            child: Container(
              width: 180,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: FaceGuideOverlay(
                guideState: _state,
                strokeWidth: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
