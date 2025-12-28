// color_picker_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  // State untuk menyimpan warna yang dipilih (Color Wheel)
  // Warna awal #00ff00 (Hijau Terang)
  Color _colorWheelColor = const Color(0xFF00FF00);
  String _colorWheelHex = '#00FF00';

  // Warna terpilih untuk detail di bagian bawah (sesuai gambar #139f47)
  final Color _detailColor = const Color(0xFF139F47);

  // Fungsi untuk mengonversi string HEX (tanpa alpha) menjadi Color
  Color _hexToColor(String hexString) {
    hexString = hexString.replaceAll('#', '');
    if (hexString.length == 6) {
      hexString = 'FF' + hexString;
    }
    try {
      return Color(int.parse(hexString, radix: 16));
    } catch (e) {
      return Colors.transparent;
    }
  }

  // Fungsi untuk menampilkan dialog Color Picker (Mode Color Wheel/Spektrum)
  void _showColorWheelDialog(BuildContext context) {
    Color pickerColor = _colorWheelColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Styling untuk meniru pop-up (Pop-up Framework7 biasanya kotak sudut bulat)
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          contentPadding: const EdgeInsets.all(12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Widget ColorPicker diatur ke mode Roda Warna Luar + Spektrum Tengah
              ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
                colorPickerWidth: 300.0,
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
                displayThumbColor: true,
                // Menggunakan HSV untuk mendapatkan Roda Luar dan Spektrum Tengah
                paletteType: PaletteType.hsv,
                // Menonaktifkan label agar lebih mirip template
                labelTypes: const [],
                // Membuat sudut Spektrum tengah bulat, tapi roda luar tetap lingkaran
                pickerAreaBorderRadius: BorderRadius.circular(8.0),
              ),
              const SizedBox(height: 10),
              // Tombol OK/Cancel
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text('OK', style: TextStyle(color: Color(0xFF4CAF50))),
                    onPressed: () {
                      setState(() {
                        _colorWheelColor = pickerColor;
                        _colorWheelHex = '#${pickerColor.value.toRadixString(16).substring(2).toUpperCase()}';
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper function untuk membangun setiap bagian Color Picker
  Widget _buildColorSection({
    required String title,
    required String description,
    required String colorValue,
    required Color displayColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul bagian (Hijau)
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4.0),
          // Deskripsi
          Text(description, style: const TextStyle(fontSize: 14.0)),
          const SizedBox(height: 12.0),

          // Kotak Warna
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  // Kotak kecil berwarna
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: displayColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12)
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Nilai warna
                  Expanded(
                    child: Text(
                      colorValue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Color Picker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Deskripsi Awal
              const Text(
                'Framework7 comes with ultimate modular Color Picker component that allows to create color picker with limitless combinations of color modules.',
                style: TextStyle(fontSize: 14.0, color: Colors.black87),
              ),
              const SizedBox(height: 24.0),

              // 1. Color Wheel (Interaktif)
              _buildColorSection(
                title: 'Color Wheel',
                description: 'Minimal example with color wheel in Popover',
                colorValue: _colorWheelHex,
                displayColor: _colorWheelColor,
                onTap: () => _showColorWheelDialog(context),
              ),

              // 2. Saturation-Brightness Spectrum
              _buildColorSection(
                title: 'Saturation-Brightness Spectrum',
                description: 'SB Spectrum + Hue Slider in Popover',
                colorValue: '#ff0000',
                displayColor: Colors.red,
              ),

              // 3. Hue-Saturation Spectrum
              _buildColorSection(
                title: 'Hue-Saturation Spectrum',
                description: 'HS Spectrum + Brightness Slider in Popover',
                colorValue: '#ff0000',
                displayColor: Colors.red,
              ),

              // 4. RGB Sliders
              _buildColorSection(
                title: 'RGB Sliders',
                description: 'RGB sliders with labels and values in Popover',
                colorValue: '#0000ff',
                displayColor: Colors.blue,
              ),

              // 5. RGBA Sliders
              _buildColorSection(
                title: 'RGBA Sliders',
                description: 'RGB sliders + Alpha Slider with labels and values in Popover',
                colorValue: 'rgba(255, 0, 255, 1)',
                displayColor: Colors.pink,
              ),

              // 6. HSB Sliders
              _buildColorSection(
                title: 'HSB Sliders',
                description: 'HSB sliders with labels and values in Popover',
                colorValue: 'hsb(120, 100%, 100%)',
                displayColor: Colors.lightGreenAccent.shade700,
              ),

              // 7. RGB Bars
              _buildColorSection(
                title: 'RGB Bars',
                description: 'RGB bars with labels and values in Popover on tablet and in Popup on phone',
                colorValue: 'rgb(0, 0, 255)',
                displayColor: Colors.blue,
              ),

              // 8. RGB Sliders + Colors
              _buildColorSection(
                title: 'RGB Sliders + Colors',
                description: 'RGB sliders with labels and values in Popover, and previous and current color values blocks',
                colorValue: 'rgb(255, 255, 0)',
                displayColor: Colors.yellow,
              ),

              // 9. Palette
              _buildColorSection(
                title: 'Palette',
                description: 'Palette opened in Sheet modal on phone and Popover on larger screens',
                colorValue: '#ffebee',
                displayColor: _hexToColor('#ffebee'),
              ),

              // 10. Pro Mode
              _buildColorSection(
                title: 'Pro Mode',
                description: 'Current Color + HSB Sliders + RGB sliders + Alpha Slider + HEX + Palette with labels and editable values',
                colorValue: 'rgba(0, 255, 255, 1)',
                displayColor: Colors.cyan,
              ),

              // 11. Inline Color Picker (Teks)
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Inline Color Picker',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Text('SB Spectrum + HSB Sliders', style: TextStyle(fontSize: 14.0)),

              const SizedBox(height: 30.0),
              const Divider(height: 1.0),
              const SizedBox(height: 16.0),

              // Detail Warna Terpilih (Sesuai Gambar Terakhir)
              Text(
                'HEX: #${_detailColor.value.toRadixString(16).substring(2).toUpperCase()}',
                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              // Nilai detail dari gambar
              const Text(
                'Alpha: 1\n'
                    'Hue: 142.4\n'
                    'RGB: 19, 159, 71\n'
                    'HSL: 142.4, 0.782, 0.348\n'
                    'HSB: 142.4, 0.878, 0.622\n'
                    'RGBA: 19, 159, 71, 1\n'
                    'HSLA: 142.4, 0.782, 0.348, 1',
                style: TextStyle(fontSize: 14.0, height: 1.5),
              ),
              const SizedBox(height: 16.0),

              // Simulasi Spektrum (Kotak Besar)
              Container(
                height: 200,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0C6B31), Color(0xFF139F47), Color(0xFF1FFF73)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300)
                ),
                child: Center(
                  // Meniru ikon penanda warna
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),

              // Simulasi Slider Bars (Hue, Saturation, Brightness, Alpha)
              const SizedBox(height: 16.0),
              _buildSliderBar(Colors.green, Icons.circle),
              _buildSliderBar(Colors.red, Icons.circle),
              _buildSliderBar(Colors.grey, Icons.circle),
              _buildSliderBar(Colors.black, Icons.circle_outlined),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk simulasi tampilan Slider Bar
  Widget _buildSliderBar(Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, color.withOpacity(0.5), color],
                  ),
                  borderRadius: BorderRadius.circular(2.5)
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(icon, size: 10, color: color),
          )
        ],
      ),
    );
  }
}