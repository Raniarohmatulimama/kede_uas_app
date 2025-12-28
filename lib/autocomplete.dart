import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autocomplete Demo',
      // Mengatur tema untuk meniru warna ungu pada AppBar dan Search.
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF9F6), // Warna latar belakang yang lebih terang
      ),
      home: const AutocompletePage(),
    );
  }
}

class AutocompletePage extends StatelessWidget {
  const AutocompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Aksi kembali
          },
        ),
        title: const Text(
          'Autocomplete',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Search Bar (Meniru tampilan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6), // Latar belakang ungu muda
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Bagian Dropdown Autocomplete
              const Text(
                'Dropdown Autocomplete',
                style: TextStyle(
                  color: Colors.green, // Warna hijau untuk judul bagian
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Dropdown autocomplete is good to use as a quick and simple solution to provide more options in addition to free-type value.',
                style: TextStyle(fontSize: 14.0),
              ),
              const SizedBox(height: 16.0),

              // Simple Dropdown Autocomplete
              _buildDropdownAutocompleteField(
                label: 'Simple Dropdown Autocomplete',
                hint: 'Fruit',
              ),

              // Dropdown With All Values
              _buildDropdownAutocompleteField(
                label: 'Dropdown With All Values',
                hint: 'Fruit',
              ),

              // Dropdown With Placeholder
              _buildDropdownAutocompleteField(
                label: 'Dropdown With Placeholder',
                hint: 'Fruit',
              ),

              // Dropdown With Typeahead (Gambar kedua)
              _buildDropdownAutocompleteField(
                label: 'Dropdown With Typeahead',
                hint: 'Fruit',
              ),

              // Dropdown With Ajax-Data (Gambar kedua)
              _buildDropdownAutocompleteField(
                label: 'Dropdown With Ajax-Data',
                hint: 'Language',
              ),

              // Dropdown With Ajax-Data + Typeahead (Gambar kedua)
              _buildDropdownAutocompleteField(
                label: 'Dropdown With Ajax-Data + Typeahead',
                hint: 'Language',
              ),

              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 16.0),

              // Bagian Standalone Autocomplete
              const Text(
                'Standalone Autocomplete',
                style: TextStyle(
                  color: Colors.green, // Warna hijau untuk judul bagian
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Standalone autocomplete provides better mobile UX by opening it in a new page or popup. Good to use when you need to get strict values without allowing free-type values.',
                style: TextStyle(fontSize: 14.0),
              ),
              const SizedBox(height: 16.0),

              // Simple Standalone Autocomplete (Meniru ListTile)
              _buildStandaloneAutocompleteItem(
                label: 'Simple Standalone Autocomplete',
                value: 'Favorite Fruite',
              ),

              // Popup Autocomplete (Meniru ListTile)
              _buildStandaloneAutocompleteItem(
                label: 'Popup Autocomplete',
                value: 'Favorite Fruite',
              ),

              // Multiple Values (Meniru ListTile)
              _buildStandaloneAutocompleteItem(
                label: 'Multiple Values',
                value: 'Favorite Fruite',
              ),

              // With Ajax-Data (Meniru ListTile)
              _buildStandaloneAutocompleteItem(
                label: 'With Ajax-Data',
                value: 'Language',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk membuat tampilan Dropdown Autocomplete Field
  Widget _buildDropdownAutocompleteField({
    required String label,
    required String hint,
  }) {
    // Karena Autocomplete bawaan Flutter sedikit berbeda, kita akan
    // mensimulasikan tampilannya dengan Autocomplete dan TextField.

    // List contoh untuk Autocomplete
    final List<String> options = [
      'Apple',
      'Banana',
      'Orange',
      'Grape',
      'Mango',
      'Strawberry'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label),
        const SizedBox(height: 4.0),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              // Mengembalikan list kosong/semua option, tergantung kebutuhan
              return const Iterable<String>.empty();
            }
            return options.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0), // Latar belakang abu-abu muda
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: hint,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                cursorColor: Colors.deepPurple,
              ),
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  // Widget untuk membuat tampilan Standalone Autocomplete (mirip ListTile)
  Widget _buildStandaloneAutocompleteItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4.0),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            // Aksi saat item Standalone Autocomplete diklik (membuka page/popup baru)
          },
        ),
        const Divider(height: 1.0),
        const SizedBox(height: 16.0),
      ],
    );
  }
}