import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorSkinPage extends StatefulWidget {
  const ColorSkinPage({Key? key}) : super(key: key);

  @override
  State<ColorSkinPage> createState() => _ColorSkinPageState();
}

class _ColorSkinPageState extends State<ColorSkinPage> {
  // layout: true = light, false = dark
  bool isLight = true;
  Color selectedColor = const Color(0xFF007AFF); // default blue
  bool _initialized = false;
  int _bottomNavIndex = 0;

  final List<Map<String, dynamic>> defaultColors = [
    {'color': Colors.red, 'label': 'Red'},
    {'color': Colors.green, 'label': 'Green'},
    {'color': Colors.blue, 'label': 'Blue'},
    {'color': Colors.pink, 'label': 'Pink'},
    {'color': Colors.yellow.shade700, 'label': 'Yellow'},
    {'color': Colors.orange.shade700, 'label': 'Orange'},
    {'color': Colors.purple, 'label': 'Purple'},
    {'color': Colors.deepPurple, 'label': 'Deeppurple'},
    {'color': Colors.lightBlue, 'label': 'Lightblue'},
    {'color': Colors.teal, 'label': 'Teal'},
    {'color': Colors.lime, 'label': 'Lime'},
    {'color': Colors.deepOrange, 'label': 'Deeporange'},
  ];

  void _pickCustomHex() async {
    // Show a visual color picker (wheel + square) and allow the user to pick a color.
    Color tempColor = selectedColor;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (c) => tempColor = c,
                  showLabel: false,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                ),
                const SizedBox(height: 8),
                Text('#${tempColor.value.toRadixString(16).substring(2)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        selectedColor = tempColor;
      });
      // persist as primary color globally
      Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).setPrimaryColor(selectedColor);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Custom color set: #${selectedColor.value.toRadixString(16).substring(2)}',
          ),
        ),
      );
    }
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.green.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sync local state with global ThemeProvider on first build
    final themeProv = Provider.of<ThemeProvider>(context);
    if (!_initialized) {
      isLight = themeProv.isLight;
      selectedColor = themeProv.primaryColor;
      _initialized = true;
    }

    final bg = isLight ? Colors.white : Colors.black87;
    final cardBg = isLight ? Colors.grey.shade100 : Colors.grey.shade800;
    final sectionBg = isLight ? const Color(0xFFFAF0F2) : cardBg;
    // Light preview: revert to original always-white preview (do not reflect selected color)
    // per user request: "untuk light mode kembalikan seperti semula".
    final lightPreviewBg = Colors.white;
    final lightPreviewTextColor = Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Color Themes',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Layout Themes'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => isLight = true);
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).setIsLight(true);
                    },
                    child: Container(
                      width: 140,
                      height: 80,
                      decoration: BoxDecoration(
                        color: lightPreviewBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLight ? Colors.green : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              'Light',
                              style: TextStyle(
                                color: isLight
                                    ? lightPreviewTextColor
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                          if (isLight)
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Icon(
                                Icons.check_box,
                                color: isLight
                                    ? (lightPreviewTextColor)
                                    : Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => isLight = false);
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).setIsLight(false);
                    },
                    child: Container(
                      width: 140,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !isLight ? Colors.green : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              'Dark',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          if (!isLight)
                            const Positioned(
                              left: 8,
                              bottom: 8,
                              child: Icon(Icons.check_box, color: Colors.green),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('Default Color Themes'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Framework7 comes with 12 color themes set.'),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: defaultColors.map((c) {
                      final color = c['color'] as Color;
                      final label = c['label'] as String;
                      final isSelected = color.value == selectedColor.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                          // update global primary color
                          Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).setPrimaryColor(color);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selected theme color: #${color.value.toRadixString(16).substring(2)}',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(24),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.green.shade700,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('Custom Color Theme'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HEX Color',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '#${selectedColor.value.toRadixString(16).substring(2)}',
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _pickCustomHex,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.mail, 'Inbox', 0),
            _buildBottomNavItemWithBadge(
              Icons.calendar_today,
              'Calendar',
              1,
              5,
            ),
            _buildBottomNavItem(Icons.cloud_upload, 'Upload', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _bottomNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItemWithBadge(
    IconData icon,
    String label,
    int index,
    int badge,
  ) {
    final isSelected = _bottomNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                ),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badge.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
