import 'package:flutter/material.dart';

void main() {
  runApp(const AccordionApp());
}

class AccordionApp extends StatelessWidget {
  const AccordionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AccordionPage(),
    );
  }
}

class AccordionPage extends StatefulWidget {
  const AccordionPage({Key? key}) : super(key: key);

  @override
  State<AccordionPage> createState() => _AccordionPageState();
}

class _AccordionPageState extends State<AccordionPage> {
  bool isLoremOpen = false;
  bool isNestedOpen = false;
  bool isIntegerOpen = false;
  bool isOppositeLoremOpen = false;
  bool isOppositeNestedOpen = false;
  bool isOppositeIntegerOpen = false;

  void toggleLorem() {
    setState(() {
      isLoremOpen = !isLoremOpen;
      if (isLoremOpen) {
        isNestedOpen = false; // menutup nested list
        isIntegerOpen = false; // menutup integer semper
      }
    });
  }

  void toggleNested() {
    setState(() {
      isNestedOpen = !isNestedOpen;
      if (isNestedOpen) {
        isLoremOpen = false; // menutup lorem ipsum
        isIntegerOpen = false; // menutup integer semper
      }
    });
  }

  void toggleInteger() {
    setState(() {
      isIntegerOpen = !isIntegerOpen;
      if (isIntegerOpen) {
        isNestedOpen = false; // menutup nested list
        isLoremOpen = false; // menutup lorem ipsum
      }
    });
  }

  void toggleOppositeLorem() {
    setState(() {
      isOppositeLoremOpen = !isOppositeLoremOpen;
      if (isOppositeLoremOpen) {
        isOppositeNestedOpen = false; // menutup nested list
        isOppositeIntegerOpen = false; // menutup integer semper
      }
    });
  }

  void toggleOppositeNested() {
    setState(() {
      isOppositeNestedOpen = !isOppositeNestedOpen;
      if (isOppositeNestedOpen) {
        isOppositeLoremOpen = false; // menutup lorem ipsum
        isOppositeIntegerOpen = false; // menutup integer semper
      }
    });
  }

  void toggleOppositeInteger() {
    setState(() {
      isOppositeIntegerOpen = !isOppositeIntegerOpen;
      if (isOppositeIntegerOpen) {
        isOppositeNestedOpen = false; // menutup nested list
        isOppositeLoremOpen = false; // menutup lorem ipsum
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Accordion',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'List View Accordion',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),

            // Kotak utama accordion
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildAccordionHeader(
                    title: "Lorem Ipsum",
                    isOpen: isLoremOpen,
                    onTap: toggleLorem,
                  ),
                  if (isLoremOpen)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Aenean elementum id neque nec commodo. Sed vel justo at '
                        'turpis laoreet pellentesque quis sed lorem. Integer semper '
                        'arcu nibh, non mollis arcu tempor vel. Sed pharetra tortor '
                        'vitae est rhoncus, vel congue dui sollicitudin. Donec eu '
                        'arcu dignissim felis viverra blandit suscipit eget ipsum.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  _buildAccordionHeader(
                    title: "Nested List",
                    isOpen: isNestedOpen,
                    onTap: toggleNested,
                  ),
                  if (isNestedOpen)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 12,
                        bottom: 12,
                      ),
                      child: Column(
                        children: [
                          _buildListItem("Item 1"),
                          _buildListItem("Item 2"),
                          _buildListItem("Item 3"),
                          _buildListItem("Item 4"),
                        ],
                      ),
                    ),
                  _buildAccordionHeader(
                    title: "Integer semper",
                    isOpen: isIntegerOpen,
                    onTap: toggleInteger,
                  ),
                  if (isIntegerOpen)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Aenean elementum id neque nec commodo. Sed vel justo at '
                        'turpis laoreet pellentesque quis sed lorem. Integer semper '
                        'arcu nibh, non mollis arcu tempor vel. Sed pharetra tortor '
                        'vitae est rhoncus, vel congue dui sollicitudin. Donec eu '
                        'arcu dignissim felis viverra blandit suscipit eget ipsum.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Opposite Side',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),

            // Bagian Opposite Side
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildAccordionHeader(
                    title: "Lorem Ipsum",
                    isOpen: isOppositeLoremOpen,
                    onTap: toggleOppositeLorem,
                    reverseIcon: true,
                  ),
                  if (isOppositeLoremOpen)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Aenean elementum id neque nec commodo. Sed vel justo at '
                        'turpis laoreet pellentesque quis sed lorem. Integer semper '
                        'arcu nibh, non mollis arcu tempor vel. Sed pharetra tortor '
                        'vitae est rhoncus, vel congue dui sollicitudin. Donec eu '
                        'arcu dignissim felis viverra blandit suscipit eget ipsum.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  _buildAccordionHeader(
                    title: "Nested List",
                    isOpen: isOppositeNestedOpen,
                    onTap: toggleOppositeNested,
                    reverseIcon: true,
                  ),
                  if (isOppositeNestedOpen)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 12,
                        bottom: 12,
                      ),
                      child: Column(
                        children: [
                          _buildListItem("Item 1"),
                          _buildListItem("Item 2"),
                          _buildListItem("Item 3"),
                          _buildListItem("Item 4"),
                        ],
                      ),
                    ),
                  _buildAccordionHeader(
                    title: "Integer semper",
                    isOpen: isOppositeIntegerOpen,
                    onTap: toggleOppositeInteger,
                    reverseIcon: true,
                  ),
                  if (isOppositeIntegerOpen)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Aenean elementum id neque nec commodo. Sed vel justo at '
                        'turpis laoreet pellentesque quis sed lorem. Integer semper '
                        'arcu nibh, non mollis arcu tempor vel. Sed pharetra tortor '
                        'vitae est rhoncus, vel congue dui sollicitudin. Donec eu '
                        'arcu dignissim felis viverra blandit suscipit eget ipsum.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionHeader({
    required String title,
    required bool isOpen,
    required VoidCallback onTap,
    bool reverseIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisAlignment: reverseIcon
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: [
            if (!reverseIcon)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (reverseIcon)
              Icon(
                isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.black54,
              ),
            const SizedBox(width: 8),
            if (!reverseIcon)
              Icon(
                isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.black54,
              ),
            if (reverseIcon)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/logo-icon.png',
              width: 16,
              height: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
