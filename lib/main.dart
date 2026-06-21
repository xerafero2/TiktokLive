import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piratetok_live/piratetok_live.dart';

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  bool _isOverlayOpen = false;
  TikTokLiveClient? _client;

  Future<void> _startListening() async {
    if (_usernameController.text.isEmpty) return;
    setState(() => _isListening = true);

    _client = TikTokLiveClient(_usernameController.text);
    
    _client?.onGift.listen((event) {
      final giftName = event.gift.name.toLowerCase();
      
      if (giftName.contains("mawar") || giftName.contains("rose")) {
        _triggerNativeAction('recall_3x');
      } else if (giftName.contains("kopi") || giftName.contains("coffee")) {
        _triggerNativeAction('skill_1');
      } else if (giftName.contains("donat") || giftName.contains("donut")) {
        _triggerNativeAction('ultimate');
      }
    });

    try {
      await _client?.connect();
    } catch (e) {
      setState(() => _isListening = false);
    }
  }

  Future<void> _triggerNativeAction(String action) async {
    try {
      await platform.invokeMethod('performTap', {'action': action});
    } catch (e) {
      debugPrint("Error eksekusi: \${e}");
    }
  }

  Future<void> _toggleOverlay() async {
    setState(() => _isOverlayOpen = !_isOverlayOpen);
    _triggerNativeAction(_isOverlayOpen ? 'show_overlay' : 'hide_overlay');
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _toggleOverlay,
              child: Text(_isOverlayOpen ? 'Tutup Pengaturan Posisi' : 'Atur Posisi Koordinat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isListening ? null : _startListening,
              child: Text(_isListening ? 'Sistem Berjalan' : 'Mulai Integrasi'),
            ),
          ],
        ),
      ),
    );
  }
}
