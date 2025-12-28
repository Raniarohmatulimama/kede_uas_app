import 'package:flutter/material.dart';

class VirtualListPage extends StatefulWidget {
  const VirtualListPage({super.key});

  @override
  State<VirtualListPage> createState() => _VirtualListPageState();
}

class _VirtualListPageState extends State<VirtualListPage> {
  late final List<Map<String, String>> _allItems;
  List<Map<String, String>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _allItems = List.generate(
      10000,
      (index) => {
        'title': 'Item ${index + 1}',
        'subtitle': 'Subtitle ${index + 1}',
      },
    );
    _filteredItems = _allItems;
  }

  Widget _buildListItem(Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on ${item['title']}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        title: Text(
          item['title']!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(item['subtitle']!),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        tileColor: const Color(0xFFF4F6FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Virtual List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // 🔹 Bagian atas (teks + tombol)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search',
                      filled: true,
                      fillColor: const Color(0xFFECEEFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Virtual List allows to render lists with huge amount of elements '
                    'without loss of performance. And it is fully compatible with all '
                    'Framework7 list components such as Search Bar, Infinite Scroll, '
                    'Pull To Refresh, Swipeouts (swipe-to-delete), and Sortable.\n\n'
                    'Here is the example of virtual list with 10,000 items:',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VirtualListVDOMPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEEFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Virtual List VDOM',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 🔹 List item 10.000
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = _filteredItems[index];
              return _buildListItem(item);
            }, childCount: _filteredItems.length),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🔹 Halaman Kedua: Virtual List VDOM (scrollable penuh)
// ============================================================================
class VirtualListVDOMPage extends StatefulWidget {
  const VirtualListVDOMPage({super.key});

  @override
  State<VirtualListVDOMPage> createState() => _VirtualListVDOMPageState();
}

class _VirtualListVDOMPageState extends State<VirtualListVDOMPage> {
  final TextEditingController _searchController = TextEditingController();
  late final List<Map<String, String>> _allItems;
  List<Map<String, String>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _allItems = List.generate(
      10000,
      (index) => {
        'title': 'Item ${index + 1}',
        'subtitle': 'Subtitle ${index + 1}',
      },
    );
    _filteredItems = _allItems;
    _searchController.addListener(_filterList);
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems
          .where(
            (item) =>
                item['title']!.toLowerCase().contains(query) ||
                item['subtitle']!.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildListItem(Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on ${item['title']}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        title: Text(
          item['title']!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(item['subtitle']!),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        tileColor: const Color(0xFFF4F6FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Virtual List VDOM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // 🔹 Bagian atas (search + deskripsi)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search',
                      filled: true,
                      fillColor: const Color(0xFFECEEFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This example shows how to use Virtual List with external renderer, '
                    'like with built-in Virtual DOM',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 🔹 List item scrollable
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = _filteredItems[index];
              return _buildListItem(item);
            }, childCount: _filteredItems.length),
          ),
        ],
      ),
    );
  }
}
