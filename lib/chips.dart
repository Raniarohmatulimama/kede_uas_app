import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chips Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        scaffoldBackgroundColor: const Color(0xFFF9FAF9),
        useMaterial3: true,
      ),
      home: const ChipsPage(),
    );
  }
}

class ChipsPage extends StatefulWidget {
  const ChipsPage({super.key});

  @override
  State<ChipsPage> createState() => _ChipsPageState();
}

class _ChipsPageState extends State<ChipsPage> {
  List<Map<String, dynamic>> deletableChips = [
    {"type": "chip", "label": "Example Chip"},
    {
      "type": "avatar",
      "label": "Chris",
      "initial": "C",
      "color": const Color(0xFFFFC107),
    },
    {
      "type": "contact",
      "label": "Jane Doe",
      "image": 'assets/images/people2.jpg',
    },
    {"type": "chip", "label": "One More Chip"},
    {
      "type": "avatar",
      "label": "Jennifer",
      "initial": "J",
      "color": const Color(0xFFE53935),
    },
    {
      "type": "contact",
      "label": "Adam Smith",
      "image": 'assets/images/people1.jpg',
    },
  ];

  void _showDeleteDialog(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Framework7',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Do you want to delete this \tiny demo Chip?',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        onConfirm();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chips',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Chips With Text"),
            _buildChipGroup([
              _buildFilledChip("Example Chip"),
              _buildFilledChip("Another Chip"),
              _buildFilledChip("One More Chip"),
              _buildFilledChip("Fourth Chip"),
              _buildFilledChip("Last One"),
            ]),

            _buildSectionTitle("Outline Chips"),
            _buildChipGroup([
              _buildOutlineChip("Example Chip"),
              _buildOutlineChip("Another Chip"),
              _buildOutlineChip("One More Chip"),
              _buildOutlineChip("Fourth Chip"),
              _buildOutlineChip("Last One"),
            ]),

            _buildSectionTitle("Icon Chips"),
            _buildChipGroup([
              _buildIconChip(
                "Add Contact",
                Icons.add_circle,
                const Color(0xFF2196F3),
              ),
              _buildIconChip(
                "London",
                Icons.location_on,
                const Color(0xFF4CAF50),
              ),
              _buildIconChip("John Doe", Icons.person, const Color(0xFFE53935)),
            ]),

            _buildSectionTitle("Contact Chips"),
            _buildChipGroup([
              _buildContactChip("Jane Doe", 'assets/images/people2.jpg'),
              _buildContactChip("John Doe", 'assets/images/people6.jpg'),
              _buildContactChip("Adam Smith", 'assets/images/people1.jpg'),
              _buildAvatarChip("Jennifer", "J", const Color(0xFFE53935)),
              _buildAvatarChip("Chris", "C", const Color(0xFFFFC107)),
              _buildAvatarChip("Kate", "K", const Color(0xFFE53935)),
            ]),

            _buildSectionTitle("Deletable Chips / Tags"),
            _buildChipGroup(
              deletableChips.map((chip) {
                switch (chip["type"]) {
                  case "chip":
                    return _buildDeletableChip(chip["label"], () {
                      setState(() {
                        deletableChips.remove(chip);
                      });
                    });
                  case "avatar":
                    return _buildDeletableAvatarChip(
                      chip["label"],
                      chip["initial"],
                      chip["color"],
                      () {
                        setState(() {
                          deletableChips.remove(chip);
                        });
                      },
                    );
                  case "contact":
                    return _buildDeletableContactChip(
                      chip["label"],
                      chip["image"],
                      () {
                        setState(() {
                          deletableChips.remove(chip);
                        });
                      },
                    );
                  default:
                    return Container();
                }
              }).toList(),
            ),

            _buildSectionTitle("Color Chips"),
            _buildChipGroup([
              _buildColorChip("Red Chip", const Color(0xFFFFCDD2)),
              _buildColorChip("Green Chip", const Color(0xFFC8E6C9)),
              _buildColorChip("Blue Chip", const Color(0xFFBBDEFB)),
              _buildColorChip("Orange Chip", const Color(0xFFFFE0B2)),
              _buildColorChip("Pink Chip", const Color(0xFFF8BBD0)),
              _buildOutlineColorChip("Red Chip"),
              _buildOutlineColorChip("Green Chip"),
              _buildOutlineColorChip("Blue Chip"),
              _buildOutlineColorChip("Orange Chip"),
              _buildOutlineColorChip("Pink Chip"),
            ]),
          ],
        ),
      ),
    );
  }

  // === Reusable Widgets ===

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChipGroup(List<Widget> chips) {
    return Wrap(spacing: 3, runSpacing: 1, children: chips);
  }

  Widget _buildFilledChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: const Color(0xFFD8E2FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildOutlineChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildIconChip(String label, IconData icon, Color iconColor) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(icon, color: iconColor, size: 20),
      ),
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: const Color(0xFFD8E2FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildContactChip(String label, String imagePath) {
    return Chip(
      avatar: CircleAvatar(backgroundImage: AssetImage(imagePath)),
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: const Color(0xFFD8E2FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildAvatarChip(String label, String initial, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(initial, style: const TextStyle(color: Colors.white)),
      ),
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: const Color(0xFFD8E2FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildDeletableChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: const Color(0xFFD8E2FF),
      deleteIcon: Icon(Icons.cancel, color: Colors.grey[600], size: 16),
      onDeleted: () => _showDeleteDialog(onDelete),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildDeletableAvatarChip(
    String label,
    String initial,
    Color color,
    VoidCallback onDelete,
  ) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(initial, style: const TextStyle(color: Colors.white)),
      ),
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: const Color(0xFFD8E2FF),
      deleteIcon: Icon(Icons.cancel, color: Colors.grey[600], size: 16),
      onDeleted: () => _showDeleteDialog(onDelete),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildDeletableContactChip(
    String label,
    String imagePath,
    VoidCallback onDelete,
  ) {
    return Chip(
      avatar: CircleAvatar(backgroundImage: AssetImage(imagePath)),
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: const Color(0xFFD8E2FF),
      deleteIcon: Icon(Icons.cancel, color: Colors.grey[600], size: 16),
      onDeleted: () => _showDeleteDialog(onDelete),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildOutlineColorChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Color(0xFF1E293B))),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}
