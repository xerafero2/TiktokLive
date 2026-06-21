import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayUI extends StatefulWidget {
  const OverlayUI({super.key});

  @override
  State<OverlayUI> createState() => _OverlayUIState();
}

class _OverlayUIState extends State<OverlayUI> {
  Offset recallPos = const Offset(100, 100);
  Offset skill1Pos = const Offset(100, 200);
  Offset ultiPos = const Offset(100, 300);

  Future<void> _savePositions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('recall_x', recallPos.dx);
    await prefs.setDouble('recall_y', recallPos.dy);
    await prefs.setDouble('skill1_x', skill1Pos.dx);
    await prefs.setDouble('skill1_y', skill1Pos.dy);
    await prefs.setDouble('ulti_x', ultiPos.dx);
    await prefs.setDouble('ulti_y', ultiPos.dy);
    await FlutterOverlayWindow.closeOverlay();
  }

  Widget _buildPointer(String label, Offset pos, Function(Offset) onUpdate) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          onUpdate(Offset(pos.dx + details.delta.dx, pos.dy + details.delta.dy));
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDEFF9A), width: 2),
          ),
          child: Center(
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          _buildPointer('RECALL', recallPos, (val) => setState(() => recallPos = val)),
          _buildPointer('SKILL 1', skill1Pos, (val) => setState(() => skill1Pos = val)),
          _buildPointer('ULTI', ultiPos, (val) => setState(() => ultiPos = val)),
          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    color: Colors.black.withOpacity(0.4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => FlutterOverlayWindow.closeOverlay(),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _savePositions,
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
