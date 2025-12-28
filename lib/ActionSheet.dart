import 'package:flutter/material.dart';

void main() {
  runApp(const ActionSheetApp());
}

class ActionSheetApp extends StatelessWidget {
  const ActionSheetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ActionSheetPage(),
    );
  }
}

class ActionSheetPage extends StatelessWidget {
  const ActionSheetPage({Key? key}) : super(key: key);

  void _showOneGroup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF3F5FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Do something',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Button 1'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Button 2'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActionGrid(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF3F5FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGridRow([
                'assets/images/people4.jpg',
                'assets/images/people5.jpg',
                'assets/images/people6.jpg',
              ]),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Divider(),
              ),
              _buildGridRow([
                'assets/images/fashion1.jpg',
                'assets/images/fashion2.jpg',
                'assets/images/fashion3.jpg',
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridRow(List<String> imagePaths) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(imagePaths.length, (index) {
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePaths[index],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Button ${index + 1}',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Action Sheet',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kotak berisi tombol hijau
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildGreenButton(
                            'One group',
                            () => _showOneGroup(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGreenButton(
                            'Two groups',
                            () => _showOneGroup(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGreenButton(
                      'Action Grid',
                      () => _showActionGrid(context),
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Action Sheet To Popover',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Action Sheet can be automatically converted to Popover (for tablets). '
                          'This button will open Popover on tablets and Action Sheet on phones:\n\n',
                    ),
                    TextSpan(
                      text: 'Actions',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreenButton(
    String text,
    VoidCallback onPressed, {
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
