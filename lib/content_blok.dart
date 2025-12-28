import 'package:flutter/material.dart';

class ContentBlockPage extends StatelessWidget {
  const ContentBlockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Content Block',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks di luar content block
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'This paragraph is outside of content block. Not cool, but useful for any custom elements with custom styling.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            // Block Title
            _buildBlockTitle('Block Title'),
            _buildContentBlock(
              'Here comes paragraph within content block. Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
            ),

            // Strong Block
            _buildBlockTitle('Strong Block'),
            _buildStrongBlock(
              'Here comes another text block with additional "block-strong" class. Praesent nec imperdiet diam. Maecenas vel lectus porttitor, consectetur magna nec, viverra sem. Aliquam sed risus dolor. Morbi tincidunt ut libero id sodales. Integer blandit varius nisi quis consectetur.',
            ),

            // Strong Outline Block
            _buildBlockTitle('Strong Outline Block'),
            _buildOutlineBlock(
              'Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptates itaque autem qui quaerat vero ducimus praesentium quibusdam veniam error ut alias, numquam iste ea quos maxime consequatur ullam at a.',
            ),

            // Strong Inset Block
            _buildBlockTitle('Strong Inset Block'),
            _buildInsetBlock(
              'Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
            ),

            // Strong Inset Outline Block
            _buildBlockTitle('Strong Inset Outline Block'),
            _buildInsetOutlineBlock(
              'Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
            ),

            // Tablet Inset
            _buildBlockTitle('Tablet Inset'),
            _buildTabletInsetBlock(
              'Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
            ),

            // With Header & Footer
            _buildBlockTitle('With Header & Footer'),
            _buildBlockWithHeaderFooter(
              header: 'Block Header',
              content:
                  'Here comes paragraph within content block. Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
              footer: 'Block Footer',
              headerColor: Colors.white,
              contentColor: Colors.white,
              footerColor: Colors.white,
              headerBorderColor: Colors.white,
              footerBorderColor: Colors.white,
            ),
            _buildBlockWithHeaderFooter(
              header: 'Block Header',
              content:
                  'Here comes paragraph within content block. Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
              footer: 'Block Footer',
              headerColor: Colors.white,
              contentColor: Colors.white,
              footerColor: Colors.white,
              headerBorderColor: Colors.white,
              footerBorderColor: Colors.white,
            ),
            _buildBlockWithHeaderFooter(
              header: 'Block Header',
              content:
                  'Here comes paragraph within content block. Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
              footer: 'Block Footer',
              headerColor: const Color(0xFFE8EAF6),
              contentColor: const Color(0xFFE8EAF6),
              footerColor: const Color(0xFFE8EAF6),
              headerBorderColor: const Color(0xFFE8EAF6),
              footerBorderColor: const Color(0xFFE8EAF6),
            ),
            _buildBlockWithHeaderFooter(
              header: 'Block Header',
              content:
                  'Here comes paragraph within content block. Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
              footer: 'Block Footer',
              headerColor: Colors.white,
              contentColor: const Color(0xFFE8EAF6),
              footerColor: Colors.white,
              headerBorderColor: Colors.white,
              footerBorderColor: Colors.white,
            ),
            _buildBlockTitle('Block Title Large', fontSize: 23),
            _buildTitleLargeBlock(
              'Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
            ),
            _buildBlockTitle('Block Title Medium'),
            _buildTitleMediumBlock(
              'Donec et nulla auctor massa pharetra adipiscing ut sit amet sem. Suspendisse molestie velit vitae mattis tincidunt. Ut sit amet quam mollis, vulputate turpis vel, sagittis felis.',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockTitle(String title, {double fontSize = 18}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContentBlock(String text) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildStrongBlock(String text) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8EAF6),
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildOutlineBlock(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        border: Border(
          top: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
          left: BorderSide(color: Colors.grey[300]!, width: 1),
          right: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildInsetBlock(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 237, 248),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildInsetOutlineBlock(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildTabletInsetBlock(String text) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8EAF6),
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildBlockWithHeaderFooter({
    required String header,
    required String content,
    required String footer,
    required Color headerColor,
    required Color contentColor,
    required Color footerColor,
    required Color headerBorderColor,
    required Color footerBorderColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: headerColor,
              border: Border(
                bottom: BorderSide(color: headerBorderColor, width: 2),
              ),
            ),
            child: Text(
              header,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: contentColor,
            padding: const EdgeInsets.all(20),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: footerColor,
              border: Border(
                top: BorderSide(color: footerBorderColor, width: 2),
              ),
            ),
            child: Text(
              footer,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleLargeBlock(String text) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8EAF6),
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildTitleMediumBlock(String text) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8EAF6),
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
      ),
    );
  }
}
