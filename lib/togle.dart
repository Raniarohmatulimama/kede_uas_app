import 'package:flutter/material.dart';

// --- Data untuk Daftar Super Hero ---
class HeroItem {
  final String name;
  final Color activeTrackColor;
  bool isEnabled;

  HeroItem({
    required this.name,
    required this.activeTrackColor,
    this.isEnabled = false,
  });
}

// Data awal (dibuat di luar widget agar mudah diakses)
final List<HeroItem> heroData = [
  // Warna disesuaikan agar mirip dengan gambar
  HeroItem(
    name: 'Batman',
    isEnabled: true,
    activeTrackColor: Colors.green.shade600,
  ), // Hijau
  HeroItem(name: 'Aquaman', activeTrackColor: Colors.blue.shade700), // Biru
  HeroItem(name: 'Superman', activeTrackColor: Colors.red.shade700), // Merah
  HeroItem(
    name: 'Hulk',
    activeTrackColor: Colors.grey.shade500,
  ), // Abu-abu gelap (Track color)
  HeroItem(
    name: 'Spiderman',
    activeTrackColor: Colors.grey.shade300,
  ), // Abu-abu muda (Track color)
  HeroItem(
    name: 'Ironman',
    isEnabled: true,
    activeTrackColor: Colors.green.shade600,
  ), // Hijau
  HeroItem(
    name: 'Thor',
    isEnabled: true,
    activeTrackColor: Colors.brown.shade600,
  ), // Cokelat
  HeroItem(
    name: 'Wonder',
    activeTrackColor: Colors.purple.shade200,
  ), // Ungu muda/Pink
];

class ToggleScreen extends StatefulWidget {
  const ToggleScreen({super.key});

  @override
  State<ToggleScreen> createState() => _ToggleScreenState();
}

class _ToggleScreenState extends State<ToggleScreen> {
  // Data list yang akan diubah state-nya
  final List<HeroItem> _currentHeroList = List.from(heroData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tidak menggunakan AppBar agar bisa membuat header custom
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Header Custom ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ), // Tombol kembali
                  const SizedBox(width: 16),
                  const Text(
                    'Toggle',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // --- Kategori ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Text(
                'Super Heroes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600, // Warna hijau
                ),
              ),
            ),

            // --- Daftar Toggle ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                ), // Padding menyesuaikan
                itemCount: _currentHeroList.length,
                itemBuilder: (context, index) {
                  final hero = _currentHeroList[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Nama Super Hero
                        Text(hero.name, style: const TextStyle(fontSize: 18)),
                        // Toggle (Switch)
                        Switch(
                          value: hero.isEnabled,
                          onChanged: (bool value) {
                            // setState untuk mengubah tampilan toggle saat dipencet
                            setState(() {
                              hero.isEnabled = value;
                            });
                          },
                          // Warna Track saat aktif (warna-warni)
                          activeTrackColor: hero.activeTrackColor,
                          // Warna Thumb (lingkaran putih)
                          activeColor: Colors.white,
                          // Warna Track saat non-aktif
                          inactiveTrackColor: hero.activeTrackColor.withOpacity(
                            0.3,
                          ),
                          // Warna Thumb saat non-aktif (agar sama dengan warna track off di gambar)
                          inactiveThumbColor: Colors.white,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget Utama (Jika perlu) ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ToggleScreen(),
    );
  }
}
