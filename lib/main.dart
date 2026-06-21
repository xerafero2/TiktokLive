import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piratetok_live/piratetok_live.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'overlay_ui.dart';

// Entry point untuk background service overlay
@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayUI(),
  ));
}

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Tap System',
      theme: ThemeData(
        brightness: Brightness.Dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDEFF9A),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const platform = MethodChannel('com.example.tiktok/autoclick');
  final TextEditingController _usernameController = TextEditingController();
  bool _isListening = false;
  TikTokLiveClient? _client;

  Future<void> _startListening() async {
    if (_usernameController.text.isEmpty) return;

    setState(() => _isListening = true);

    _client = TikTokLiveClient(_usernameController.text);
    
    _client?.onGift.listen((event) async {
      final giftName = event.gift.name.toLowerCase();
      final userId = event.user.id; 
      
      debugPrint("Hadiah dari: $userId");

      final prefs = await SharedPreferences.getInstance();

      if (giftName.contains("mawar") || giftName.contains("rose")) {
        _triggerNativeTap('recall_3x', prefs.getDouble('recall_x') ?? 0, prefs.getDouble('recall_y') ?? 0);
      } else if (giftName.contains("kopi") || giftName.contains("coffee")) {
        _triggerNativeTap('skill_1', prefs.getDouble('skill1_x') ?? 0, prefs.getDouble('skill1_y') ?? 0);
      } else if (giftName.contains("donat") || giftName.contains("donut")) {
        _triggerNativeTap('ultimate', prefs.getDouble('ulti_x') ?? 0, prefs.getDouble('ulti_y') ?? 0);
      }
    });

    try {
      await _client?.connect();
    } catch (e) {
      setState(() => _isListening = false);
    }
  }

  Future<void> _triggerNativeTap(String action, double x, double y) async {
    try {
      await platform.invokeMethod('performTap', {'action': action, 'x': x, 'y': y});
    } on PlatformException catch (e) {
      debugPrint("Error eksekusi: ${e.message}");
    }
  }

  Future<void> _openOverlay() async {
    if (await FlutterOverlayWindow.isActive()) return;
    await FlutterOverlayWindow.showOverlay(
      enableDrag: false,
      overlayTitle: "Pengaturan Posisi",
      overlayContent: "Atur posisi tombol",
      flag: OverlayFlag.focusPointer,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfigurasi Sistem', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username TikTok',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openOverlay,
              icon: const Icon(Icons.settings_overscan),
              label: const Text('Atur Posisi Koordinat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isListening ? null : _startListening,
              icon: const Icon(Icons.play_arrow),
              label: Text(_isListening ? 'Sistem Berjalan' : 'Mulai Integrasi'),
            ),
          ],
        ),
      ),
    );
  }
}
