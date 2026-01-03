import 'package:flutter/material.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> releases = [
      {
        "id": "1",
        "title": "Yellow Submarine",
        "artist": "Beatles",
        "image": "assets/images/fashion2.jpg",
      },
      {
        "id": "2",
        "title": "Don't Stop Me Now",
        "artist": "Queen",
        "image": "assets/images/fashion1.jpg",
      },
      {
        "id": "3",
        "title": "Billie Jean",
        "artist": "Michael Jackson",
        "image": "assets/images/fashion3.jpg",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cards',
          style: TextStyle(
            fontFamily: 'Arial',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Arial'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Cards are a great way to contain and organize your information, especially when combined with List Views. Cards can contain unique related data, like for example photos, text or links about a particular subject. Cards are typically an entry point to more complex and detailed information.',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle("Simple Cards"),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'This is a simple card with plain text, but cards can also contain their own header, footer, list view, image, or any other element.',
                  style: TextStyle(fontFamily: 'Arial', color: Colors.black87),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Card header',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\nCard with header and footer. Card headers are used to display card titles and footers for additional information or just for custom actions.\n\n\n Card Footer',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Another card. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse feugiat sem est, non tincidunt ligula volutpat sit amet. Mauris aliquet magna justo.',
                  style: TextStyle(fontFamily: 'Arial', color: Colors.black87),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle("Outline Cards"),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: const Text(
                  'This is a simple card with plain text, but cards can also contain their own header, footer, list view, image, or any other element.',
                  style: TextStyle(fontFamily: 'Arial', color: Colors.black87),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Card header',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\nCard with header and footer. Card headers are used to display card titles and footers for additional information or just for custom actions.\n',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Card Footer',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: const Text(
                  'Another card. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse feugiat sem est, non tincidunt ligula volutpat sit amet. Mauris aliquet magna justo.',
                  style: TextStyle(fontFamily: 'Arial', color: Colors.black87),
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("Outline With Dividers"),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Card header',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      // Garis bawah header (menyambung sisi kiri dan kanan)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        height: 1,
                        width: double.infinity,
                        color: Colors.black,
                      ),

                      // Isi teks
                      Text(
                        'Card with header and footer. Card headers are used to display card titles and footers for additional information or just for custom actions.',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),

                      // Garis atas footer (menyambung sisi kiri dan kanan)
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.black,
                      ),

                      // Footer
                      Text(
                        'Card Footer',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          color: Colors.grey,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("Raised Card"),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'This is a simple card with plain text, but cards can also contain their own header, footer, list view, image, or any other element.',
                  style: TextStyle(fontFamily: 'Arial', color: Colors.black87),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Card header',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\nCard with header and footer. Card headers are used to display card titles and footers for additional information or just for custom actions.\n',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Card Footer',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Another card. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse feugiat sem est, non tincidunt ligula volutpat sit amet. Mauris aliquet magna justo.',
                  style: TextStyle(fontFamily: 'Arial', color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle("Styled Cards"),

              // Card with image
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 1),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/nature9.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Text(
                              'Journey To Mountains',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 2, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Posted on January 21, 2015',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '\nQuisque eget vestibulum nulla. Quisque quis dui quis ex ultricies efficitur vitae non felis. Phasellus quis nibh hendrerit...\n\n',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 4),
                                  InkWell(
                                    splashColor: Colors.green.shade200,
                                    onTap: () => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          SnackBar(content: Text('Liked!')),
                                        ),
                                    child: Text(
                                      'Like',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        color: Colors.green.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                splashColor: Colors.green.shade200,
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Read more clicked!'),
                                      ),
                                    ),
                                child: Text(
                                  'Read more',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Card with image
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 1),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/bocil.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Text(
                              'Lorem Ipsum',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(blurRadius: 2, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Posted on January 21, 2015',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '\nQuisque eget vestibulum nulla. Quisque quis dui quis ex ultricies efficitur vitae non felis. Phasellus quis nibh hendrerit...\n\n',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 4),
                                  InkWell(
                                    splashColor: Colors.green.shade200,
                                    onTap: () => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          SnackBar(content: Text('Liked!')),
                                        ),
                                    child: Text(
                                      'Like',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        color: Colors.green.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                splashColor: Colors.green.shade200,
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Read more clicked!'),
                                      ),
                                    ),
                                child: Text(
                                  'Read more',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle("Cards With List View"),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(
                    5,
                    (index) => InkWell(
                      splashColor: Colors.green.shade200,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Link ${index + 1} clicked!')),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Link ${index + 1}',
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                color: Colors.black87,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "New Releases:",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827), // gray-900
                        ),
                      ),
                      const SizedBox(height: 20),

                      // List of releases
                      Column(
                        children: releases.map((release) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              // Aksi saat diklik
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    child: Image.asset(
                                      release["image"]!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          release["title"]!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(
                                              0xFF111827,
                                            ), // gray-900
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          release["artist"]!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(
                                              0xFF6B7280,
                                            ), // gray-600
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Footer
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "January 20, 2015",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            "5 comments",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Arial',
          color: Colors.green.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
