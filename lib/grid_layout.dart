import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid Layout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const GridLayoutPage(),
    );
  }
}

class GridLayoutPage extends StatelessWidget {
  const GridLayoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Grid / Layout',
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
            const Text(
              'Columns within a row are automatically set to have equal width. Otherwise you can define your column with pourcentage of screen you want.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Columns with gap
            const Text(
              'Columns with gap',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),

            // 2 columns row
            Row(
              children: [
                Expanded(child: _buildGridItem('2 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('2 cols')),
              ],
            ),
            const SizedBox(height: 10),

            // 4 columns row
            Row(
              children: [
                Expanded(child: _buildGridItem('4 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('4 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('4 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('4 cols')),
              ],
            ),
            const SizedBox(height: 10),

            // 3 columns row
            Row(
              children: [
                Expanded(child: _buildGridItem('3 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('3 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('3 cols')),
              ],
            ),
            const SizedBox(height: 10),

            // 5 columns row
            Row(
              children: [
                Expanded(child: _buildGridItem('5 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('5 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('5 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('5 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('5 cols')),
              ],
            ),
            const SizedBox(height: 40),

            // No gap between columns
            const Text(
              'No gap between columns',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),

            // 2 columns row no gap
            Row(
              children: [
                Expanded(child: _buildGridItem('2 cols', hasGap: false)),
                Expanded(child: _buildGridItem('2 cols', hasGap: false)),
              ],
            ),
            const SizedBox(height: 10),

            // 4 columns row no gap
            Row(
              children: [
                Expanded(child: _buildGridItem('4 cols', hasGap: false)),
                Expanded(child: _buildGridItem('4 cols', hasGap: false)),
                Expanded(child: _buildGridItem('4 cols', hasGap: false)),
                Expanded(child: _buildGridItem('4 cols', hasGap: false)),
              ],
            ),
            const SizedBox(height: 10),

            // 3 columns row no gap
            Row(
              children: [
                Expanded(child: _buildGridItem('3 cols', hasGap: false)),
                Expanded(child: _buildGridItem('3 cols', hasGap: false)),
                Expanded(child: _buildGridItem('3 cols', hasGap: false)),
              ],
            ),
            const SizedBox(height: 10),

            // 5 columns row no gap
            Row(
              children: [
                Expanded(child: _buildGridItem('5 cols', hasGap: false)),
                Expanded(child: _buildGridItem('5 cols', hasGap: false)),
                Expanded(child: _buildGridItem('5 cols', hasGap: false)),
                Expanded(child: _buildGridItem('5 cols', hasGap: false)),
                Expanded(child: _buildGridItem('5 cols', hasGap: false)),
              ],
            ),
            const SizedBox(height: 40),

            // Responsive Grid
            const Text(
              'Responsive Grid',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Grid cells have different size on Phone/Tablet',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),

            // Responsive 1 col / medium 2 cols
            _buildGridItem('1 col / medium 2 cols', isFullWidth: true),
            const SizedBox(height: 10),
            _buildGridItem('1 col / medium 2 cols', isFullWidth: true),
            const SizedBox(height: 10),

            // Responsive 2 col / medium 4 cols
            Row(
              children: [
                Expanded(child: _buildGridItem('2 col / medium 4 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('2 col / medium 4 cols')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildGridItem('2 col / medium 4 cols')),
                const SizedBox(width: 10),
                Expanded(child: _buildGridItem('2 col / medium 4 cols')),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
    String text, {
    bool hasGap = true,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: hasGap ? BorderRadius.circular(4) : BorderRadius.zero,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ),
    );
  }
}
