import 'package:flutter/material.dart';
import 'acordion.dart';
import 'ActionSheet.dart';
import 'package:ionicons/ionicons.dart';
import 'buttons.dart';
import 'cards_page.dart';
import 'card_candasible.dart';
import 'chips.dart';
import 'content_blok.dart';
import 'calender_page.dart';
import 'dialog.dart';
import 'virtual_list_page.dart';
import 'togle.dart';
import 'tootlip.dart';
import 'form_storage.dart';
import 'FAB.dart';
import 'gauge.dart';
import 'grid_layout.dart';
import 'elemen_login.dart';
import 'color_picker_page.dart';

//HALAMAN DATA TABLE
// --- Data Model untuk With Inputs ---
class User {
  final int id;
  final String name;
  final String email;
  final String gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
  });
}

List<User> _users = [
  User(id: 1, name: 'John Doe', email: 'john@doe.com', gender: 'Male'),
  User(id: 2, name: 'Jane Doe', email: 'jane@doe.com', gender: 'Female'),
  User(
    id: 3,
    name: 'Vladimir Kharlampidi',
    email: 'vladimir@google.com',
    gender: 'Male',
  ),
  User(
    id: 4,
    name: 'Jennifer Doe',
    email: 'jennifer@doe.com',
    gender: 'Female',
  ),
];

// --- Data Model ---
class Dessert {
  final String name;
  final int calories;
  final double fat;
  final int carbs;
  final double protein;
  bool isSelected; // Ditambahkan untuk Selectable Rows

  Dessert({
    required this.name,
    required this.calories,
    required this.fat,
    required this.carbs,
    required this.protein,
    this.isSelected = false,
  });
}

List<Dessert> _desserts = [
  Dessert(
    name: 'Frozen yogurt',
    calories: 159,
    fat: 6.0,
    carbs: 24,
    protein: 4.0,
  ),
  Dessert(
    name: 'Ice cream sandwich',
    calories: 237,
    fat: 9.0,
    carbs: 37,
    protein: 4.4,
  ),
  Dessert(name: 'Eclair', calories: 262, fat: 16.0, carbs: 24, protein: 6.0),
  Dessert(name: 'Cupcake', calories: 305, fat: 3.7, carbs: 67, protein: 4.3),
  // Tambahan data dummy untuk simulasi 10 baris pada pagination
  Dessert(
    name: 'Gingerbread',
    calories: 356,
    fat: 3.5,
    carbs: 83,
    protein: 3.9,
  ),
  Dessert(name: 'Jelly bean', calories: 375, fat: 0.0, carbs: 94, protein: 0.0),
  Dessert(name: 'Lollipop', calories: 392, fat: 0.2, carbs: 98, protein: 0.0),
  Dessert(name: 'Honeycomb', calories: 408, fat: 3.2, carbs: 87, protein: 6.5),
  Dessert(name: 'Donut', calories: 452, fat: 25.0, carbs: 51, protein: 4.9),
  Dessert(name: 'KitKat', calories: 518, fat: 26.0, carbs: 65, protein: 7.0),
];

// --- DataTablePage (Stateful agar bisa mengelola state Checkbox) ---
class DataTablePage extends StatefulWidget {
  const DataTablePage({super.key});

  @override
  State<DataTablePage> createState() => _DataTablePageState();
}

class _DataTablePageState extends State<DataTablePage> {
  // Hanya ambil 4 item untuk Selectable Rows, untuk simulasi pagination
  List<Dessert> _selectableDesserts = _desserts.sublist(0, 4).toList();
  int _rowsPerPage = 5;

  // State untuk Sortable Columns
  int _sortColumnIndex = 0; // Index kolom yang disortir (0 = Dessert)
  bool _isAscending = true; // Arah sortir awal (naik)

  // State untuk With Inputs
  String _idFilter = 'Filter';
  String _nameFilter = 'Filter';
  String _emailFilter = 'Filter';
  String _genderFilter = 'All'; // Nilai default dropdown

  // Data user (gunakan data baru)
  List<User> _usersData = _users;

  // --- Widget Baru: Collapsible Table (List View) ---
  Widget _buildCollapsibleTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collapsible',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          'The following table will be collapsed to kind of List View on small screens:',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16.0),

        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // --- HEADER CARD (Sama seperti sebelumnya) ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nutrition',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.black54,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black54,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

              // --- COLLAPSIBLE LIST VIEW ---
              ListView.builder(
                physics:
                    const NeverScrollableScrollPhysics(), // Menonaktifkan scroll di dalam SingleChildScrollView utama
                shrinkWrap: true,
                itemCount: _desserts.length,
                itemBuilder: (context, index) {
                  final d = _desserts[index];

                  // Mengatur padding vertical (margin) untuk setiap item
                  Widget dessertItem = Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris 1: Dessert (Header dan Nilai)
                        _buildCollapsedRow(
                          'Dessert (100g serving)',
                          d.name,
                          isBoldValue: true,
                        ),
                        const SizedBox(height: 8),

                        // Baris 2: Calories
                        _buildCollapsedRow('Calories', d.calories.toString()),

                        // Baris 3: Fat
                        _buildCollapsedRow('Fat (g)', d.fat.toString()),

                        // Baris 4: Carbs
                        _buildCollapsedRow('Carbs', d.carbs.toString()),

                        // Baris 5: Protein
                        _buildCollapsedRow('Protein (g)', d.protein.toString()),
                      ],
                    ),
                  );

                  // Menambahkan Divider di antara setiap item (kecuali yang terakhir)
                  if (index < _desserts.length - 1) {
                    return Column(
                      children: [
                        dessertItem,
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                        ),
                      ],
                    );
                  }

                  return dessertItem;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Fungsi pembantu untuk membangun setiap baris data yang diringkas
  Widget _buildCollapsedRow(
    String label,
    String value, {
    bool isBoldValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBoldValue ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Baru: Alternate header with actions ---
  Widget _buildAlternateHeaderWithActions() {
    // Data model yang digunakan tetap _selectableDesserts
    final bool isAllSelected = _selectableDesserts.every((d) => d.isSelected);

    // Fungsi untuk menandai semua baris
    void onSelectAll(bool? selected) {
      setState(() {
        for (var d in _selectableDesserts) {
          d.isSelected = selected ?? false;
        }
      });
    }

    // Widget kustom untuk meniru tampilan aksi (Add/Remove)
    Widget _buildActionText(String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: GestureDetector(
          onTap: () {
            // Logika aksi (misalnya, print atau fungsi placeholder)
            print('$text clicked');
          },
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.green, // Warna hijau
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alternate header with actions',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16.0),

        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // --- HEADER DENGAN AKSI ALTERNATIF (Add/Remove) ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Aksi di sebelah kiri
                    Row(
                      children: [
                        _buildActionText('Add'),
                        _buildActionText('Remove'),
                      ],
                    ),

                    // Ikon di sebelah kanan
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.sort, color: Colors.black54),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black54,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

              // --- DATA TABLE ---
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowMinHeight: 55,
                    dataRowMaxHeight: 55,
                    headingRowHeight: 55,

                    border: TableBorder(
                      verticalInside: BorderSide.none,
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue.withOpacity(0.1);
                      }
                      return Colors.white;
                    }),

                    // Kolom
                    columns: [
                      // Kolom 0: Checkbox Utama KUSTOM (Warna Hijau)
                      DataColumn(
                        label: Text(
                          '', // Biarkan label kosong
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Dessert (100g serving)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Calories',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Fat (g)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Carbs',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Protein (g)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],

                    // Baris
                    rows: _selectableDesserts.map((d) {
                      return DataRow(
                        selected: d.isSelected,
                        onSelectChanged: (bool? selected) {
                          setState(() {
                            d.isSelected = selected ?? false;
                          });
                        },
                        cells: [
                          const DataCell(Text('')),
                          DataCell(
                            Text(
                              d.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(Text(d.calories.toString())),
                          DataCell(Text(d.fat.toString())),
                          DataCell(Text(d.carbs.toString())),
                          DataCell(Text(d.protein.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Widget Baru: With Inputs ---
  Widget _buildWithInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'With inputs',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          'Such tables are widely used in admin interfaces\nfor filtering or search data',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16.0),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataRowMinHeight: 55,
            dataRowMaxHeight: 55,
            headingRowHeight: 80, // Tambah tinggi header untuk menampung input
            // Border yang sama dengan Plain Table
            border: TableBorder(
              verticalInside: BorderSide.none,
              horizontalInside: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
              top: BorderSide(color: Colors.grey.shade300, width: 1.0),
              bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            dataRowColor: MaterialStateProperty.resolveWith<Color>((
              Set<MaterialState> states,
            ) {
              return Colors.white;
            }),

            // Kolom dengan Input/Dropdown
            columns: [
              // Kolom ID (dengan input Text dan panah sort)
              DataColumn(
                label: SizedBox(
                  width: 50, // Sesuaikan lebar
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ID',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: _idFilter,
                                isDense: true,
                                contentPadding: const EdgeInsets.only(
                                  bottom: 0,
                                ),
                              ),
                              onChanged: (value) {
                                // Implementasi filter jika diperlukan
                              },
                            ),
                          ),
                          const Icon(Icons.arrow_drop_up, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Kolom Name (dengan input Text)
              DataColumn(
                label: SizedBox(
                  width: 150, // Sesuaikan lebar
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: _nameFilter,
                          isDense: true,
                          contentPadding: const EdgeInsets.only(bottom: 0),
                        ),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
              ),

              // Kolom Email (dengan input Text)
              DataColumn(
                label: SizedBox(
                  width: 150, // Sesuaikan lebar
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: _emailFilter,
                          isDense: true,
                          contentPadding: const EdgeInsets.only(bottom: 0),
                        ),
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
              ),

              // Kolom Gender (dengan Dropdown)
              DataColumn(
                label: SizedBox(
                  width: 80, // Sesuaikan lebar
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isDense: true,
                          value: _genderFilter,
                          items: ['All', 'Male', 'Female'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _genderFilter = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Baris
            rows: _usersData.map((u) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      u.id.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(Text(u.name)),
                  DataCell(Text(u.email)),
                  DataCell(Text(u.gender)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- Widget Baru: With title and different actions on select ---
  Widget _buildWithTitleAndActionsOnSelect() {
    // Hitung berapa baris yang saat ini dipilih
    final int selectedCount = _selectableDesserts
        .where((d) => d.isSelected)
        .length;
    final bool isAnySelected = selectedCount > 0;
    final bool isAllSelected = _selectableDesserts.every((d) => d.isSelected);

    // Fungsi untuk menandai semua baris
    void onSelectAll(bool? selected) {
      setState(() {
        for (var d in _selectableDesserts) {
          d.isSelected = selected ?? false;
        }
      });
    }

    // Fungsi untuk membangun Header Card (berubah berdasarkan selectedCount)
    Widget _buildHeader() {
      if (isAnySelected) {
        // --- HEADER KETIKA ITEM DIPILIH (Selected State) ---
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selectedCount items selected',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Warna hijau saat terpilih
                ),
              ),
              Row(
                children: [
                  // Ikon Hapus (Trash)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      // Logic untuk menghapus item yang dipilih (hanya simulasi)
                      setState(() {
                        _selectableDesserts.removeWhere((d) => d.isSelected);
                      });
                    },
                  ),
                  // Ikon More Vert
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black54),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      } else {
        // --- HEADER KETIKA TIDAK ADA ITEM DIPILIH (Default State) ---
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nutrition',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // Ikon Filter List (Sama seperti With title and actions)
                  IconButton(
                    icon: const Icon(Icons.sort, color: Colors.black54),
                    onPressed: () {},
                  ),
                  // Ikon More Vert
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black54),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'With title and different actions on select',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16.0),

        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // --- PANGGIL HEADER DINAMIS ---
              _buildHeader(),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

              // --- DATA TABLE ---
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowMinHeight: 55,
                    dataRowMaxHeight: 55,
                    headingRowHeight: 55,

                    border: TableBorder(
                      verticalInside: BorderSide.none,
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue.withOpacity(0.1);
                      }
                      return Colors.white;
                    }),

                    // Kolom
                    columns: [
                      // Kolom Checkbox Utama KUSTOM (Pilih Semua)
                      DataColumn(
                        label: Text(
                          '', // Biarkan label kosong
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Dessert (100g serving)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Calories',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Fat (g)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Carbs',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Protein (g)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],

                    // Baris
                    rows: _selectableDesserts.map((d) {
                      return DataRow(
                        selected: d.isSelected, // Highlight baris saat terpilih
                        onSelectChanged: (bool? selected) {
                          // Klik pada baris akan memicu perubahan state isSelected
                          setState(() {
                            d.isSelected = selected ?? false;
                          });
                        },
                        cells: [
                          // DataCell Checkbox KUSTOM (Warna Hijau dan Fungsi Klik)
                          const DataCell(Text('')),
                          DataCell(
                            Text(
                              d.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(Text(d.calories.toString())),
                          DataCell(Text(d.fat.toString())),
                          DataCell(Text(d.carbs.toString())),
                          DataCell(Text(d.protein.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Widget Baru: Sortable columns ---
  Widget _buildSortableColumns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sortable columns',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16.0),

        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // --- HEADER DENGAN JUDUL DAN AKSI ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nutrition',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.sort, color: Colors.black54),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black54,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

              // --- DATA TABLE ---
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowMinHeight: 55,
                    dataRowMaxHeight: 55,
                    headingRowHeight: 55,

                    // PROPERTI SORTING UTAMA
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _isAscending,

                    border: TableBorder(
                      verticalInside: BorderSide.none,
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      // Memberikan warna latar belakang pada baris yang dipilih (seperti di template)
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue.withOpacity(0.1);
                      }
                      return Colors.white;
                    }),

                    // Kolom dengan OnSort
                    columns: [
                      // Kolom 0: Dessert (dengan panah awal)
                      DataColumn(
                        label: const Text(
                          'Dessert (100g serving)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        onSort: (columnIndex, ascending) {
                          // Hanya mengubah tampilan, tidak benar-benar mengurutkan data
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _isAscending = ascending;
                          });
                        },
                      ),
                      // Kolom 1: Calories
                      DataColumn(
                        label: const Text(
                          'Calories',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _isAscending = ascending;
                          });
                        },
                      ),
                      // Kolom 2: Fat (g)
                      DataColumn(
                        label: const Text(
                          'Fat (g)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _isAscending = ascending;
                          });
                        },
                      ),
                      // Kolom 3: Carbs
                      DataColumn(
                        label: const Text(
                          'Carbs',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _isAscending = ascending;
                          });
                        },
                      ),
                      // Kolom 4: Protein (g)
                      DataColumn(
                        label: const Text(
                          'Protein (g)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                            _isAscending = ascending;
                          });
                        },
                      ),
                    ],

                    // Baris (Gunakan data _desserts asli)
                    rows: _desserts.sublist(0, 4).map((d) {
                      // Tambahkan logika untuk menyorot Ice Cream Sandwich (index 1) agar persis template
                      bool isSelectedRow = (d.name == 'Ice cream sandwich');

                      return DataRow(
                        selected: isSelectedRow, // Menyorot baris ini
                        onSelectChanged: (bool? selected) {
                          // Biarkan kosong, karena ini hanya contoh tampilan sortir
                        },
                        cells: [
                          DataCell(
                            Text(
                              d.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(Text(d.calories.toString())),
                          DataCell(Text(d.fat.toString())),
                          DataCell(Text(d.carbs.toString())),
                          DataCell(Text(d.protein.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Widget Baru: Within card with title and actions ---
  Widget _buildCardWithTitleAndActions() {
    // Cek apakah semua item dipilih (sama seperti Selectable Rows)
    final bool isAllSelected = _selectableDesserts.every((d) => d.isSelected);

    // Fungsi untuk menandai semua baris
    void onSelectAll(bool? selected) {
      setState(() {
        for (var d in _selectableDesserts) {
          d.isSelected = selected ?? false;
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Within card with title and actions',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16.0),

        Card(
          elevation: 0, // Card tanpa bayangan
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade300,
            ), // Border tipis di sekitar Card
          ),
          child: Column(
            children: [
              // --- HEADER DENGAN JUDUL DAN AKSI ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nutrition',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.sort, color: Colors.black54),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black54,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE0E0E0),
              ), // Pemisah setelah header
              // --- DATA TABLE ---
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowMinHeight: 55,
                    dataRowMaxHeight: 55,
                    headingRowHeight: 55,

                    // Border tabel di dalam Card
                    border: TableBorder(
                      verticalInside: BorderSide.none,
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                      top: BorderSide.none, // Dihapus karena sudah ada Divider
                      bottom:
                          BorderSide.none, // Dihapus karena ini di dalam Card
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith<Color>((
                      Set<MaterialState> states,
                    ) {
                      // Memberikan warna latar belakang pada baris yang dipilih (seperti di template)
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue.withOpacity(0.1);
                      }
                      return Colors.white;
                    }),

                    // Kolom
                    columns: [
                      // Kolom Checkbox Utama
                      DataColumn(
                        label: Text(
                          '', // Biarkan label kosong
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const DataColumn(
                        label: Text(
                          'Dessert (100g serving)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Calories',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Fat (g)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Carbs',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const DataColumn(
                        label: Text(
                          'Protein (g)',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],

                    // Baris
                    rows: _selectableDesserts.map((d) {
                      return DataRow(
                        selected: d.isSelected,
                        onSelectChanged: (bool? selected) {
                          setState(() {
                            d.isSelected = selected ?? false;
                          });
                        },
                        cells: [
                          const DataCell(Text('')),
                          DataCell(
                            Text(
                              d.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(Text(d.calories.toString())),
                          DataCell(Text(d.fat.toString())),
                          DataCell(Text(d.carbs.toString())),
                          DataCell(Text(d.protein.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Widget Builders Sebelumnya ---

  Widget _buildPlainDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowMinHeight: 55,
        dataRowMaxHeight: 55,
        headingRowHeight: 55,
        border: TableBorder(
          verticalInside: BorderSide.none,
          horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1.0),
          top: BorderSide(color: Colors.grey.shade300, width: 1.0),
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        dataRowColor: MaterialStateProperty.resolveWith<Color>((
          Set<MaterialState> states,
        ) {
          return Colors.white;
        }),
        columns: const [
          DataColumn(
            label: Text(
              'Dessert (100g serving)',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          DataColumn(
            label: Text(
              'Calories',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          DataColumn(
            label: Text(
              'Fat (g)',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          DataColumn(
            label: Text(
              'Carbs',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          DataColumn(
            label: Text(
              'Protein (g)',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
        ],
        rows: _desserts.sublist(0, 4).map((d) {
          // Hanya ambil 4 item agar sesuai template
          return DataRow(
            cells: [
              DataCell(
                Text(
                  d.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(Text(d.calories.toString())),
              DataCell(Text(d.fat.toString())),
              DataCell(Text(d.carbs.toString())),
              DataCell(Text(d.protein.toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardDataTable() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataRowMinHeight: 55,
            dataRowMaxHeight: 55,
            headingRowHeight: 55,
            border: TableBorder(
              verticalInside: BorderSide.none,
              horizontalInside: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
              top: BorderSide.none,
              bottom: BorderSide.none,
            ),
            dataRowColor: MaterialStateProperty.resolveWith<Color>((
              Set<MaterialState> states,
            ) {
              return Colors.white;
            }),
            columns: const [
              DataColumn(
                label: Text(
                  'Dessert (100g serving)',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              DataColumn(
                label: Text(
                  'Calories',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fat (g)',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              DataColumn(
                label: Text(
                  'Carbs',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              DataColumn(
                label: Text(
                  'Protein (g)',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
            ],
            rows: _desserts.sublist(0, 4).map((d) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      d.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(Text(d.calories.toString())),
                  DataCell(Text(d.fat.toString())),
                  DataCell(Text(d.carbs.toString())),
                  DataCell(Text(d.protein.toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // --- Widget Baru: Footer Pagination ---

  Widget _buildFooterPagination() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'With Footer Pagination',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16.0),

        // Tabel utama (menggunakan 5 item pertama untuk simulasi)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataRowMinHeight: 55,
            dataRowMaxHeight: 55,
            headingRowHeight: 55,
            border: TableBorder(
              verticalInside: BorderSide.none,
              horizontalInside: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
              top: BorderSide(color: Colors.grey.shade300, width: 1.0),
              bottom: BorderSide
                  .none, // Border bottom dihilangkan karena ada footer
            ),
            dataRowColor: MaterialStateProperty.resolveWith<Color>((
              Set<MaterialState> states,
            ) {
              return Colors.white;
            }),
            columns: const [
              DataColumn(
                label: Text(
                  'Dessert (100g serving)',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              DataColumn(
                label: Text(
                  'Calories',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fat (g)',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              DataColumn(
                label: Text(
                  'Carbs',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              DataColumn(
                label: Text(
                  'Protein (g)',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
            ],
            rows: _desserts.sublist(0, 5).map((d) {
              // Ambil 5 item
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      d.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(Text(d.calories.toString())),
                  DataCell(Text(d.fat.toString())),
                  DataCell(Text(d.carbs.toString())),
                  DataCell(Text(d.protein.toString())),
                ],
              );
            }).toList(),
          ),
        ),

        // Footer Pagination Kustom
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1.0),
              bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Rows per page:'),
              const SizedBox(width: 8),
              // Dropdown untuk Rows per page
              DropdownButton<int>(
                value: _rowsPerPage,
                items: [5, 10].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _rowsPerPage = newValue ?? 5;
                  });
                },
              ),
              const SizedBox(width: 20),
              // Info Baris
              const Text('1-5 of 10'),
              const SizedBox(width: 20),
              // Tombol Pagination
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.green,
                    ), // Warna hijau pada tombol aktif
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Widget Baru: Selectable Rows ---

  Widget _buildSelectableRows() {
    // Fungsi untuk menandai semua baris
    void onSelectAll(bool? selected) {
      setState(() {
        for (var d in _selectableDesserts) {
          d.isSelected = selected ?? false;
        }
      });
    }

    // Cek apakah semua item sudah dipilih
    final bool isAllSelected = _selectableDesserts.every((d) => d.isSelected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selectable rows',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16.0),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataRowMinHeight: 55,
            dataRowMaxHeight: 55,
            headingRowHeight: 55,
            // Border yang sama dengan Plain Table
            border: TableBorder(
              verticalInside: BorderSide.none,
              horizontalInside: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
              top: BorderSide(color: Colors.grey.shade300, width: 1.0),
              bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            dataRowColor: MaterialStateProperty.resolveWith<Color>((
              Set<MaterialState> states,
            ) {
              return Colors.white;
            }),

            // Kolom
            columns: [
              // Kolom Checkbox Utama
              DataColumn(
                label: Text(
                  '', // Biarkan label kosong
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Dessert (100g serving)',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Calories',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Fat (g)',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Carbs',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
              const DataColumn(
                label: Text(
                  'Protein (g)',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ),
            ],

            // Baris
            rows: _selectableDesserts.map((d) {
              return DataRow(
                // Properti untuk menandai baris sebagai terpilih
                selected: d.isSelected,
                onSelectChanged: (bool? selected) {
                  setState(() {
                    d.isSelected = selected ?? false;
                  });
                },
                cells: [
                  // DataCell Checkbox individual
                  const DataCell(Text('')),
                  DataCell(
                    Text(
                      d.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(Text(d.calories.toString())),
                  DataCell(Text(d.fat.toString())),
                  DataCell(Text(d.carbs.toString())),
                  DataCell(Text(d.protein.toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  // --- Widget Baru: Tablet-only columns ---

  Widget _buildTabletOnlyColumns() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Logika untuk menentukan apakah kolom "Comments" harus terlihat
        // Kita asumsikan lebar Tablet/Desktop adalah >= 768px
        final bool showTabletColumn = constraints.maxWidth >= 768;

        // Daftar Kolom Utama
        List<DataColumn> columns = [
          // Kolom Checkbox Utama
          DataColumn(
            label: Checkbox(
              value: false, // Tidak perlu mengelola state di sini
              onChanged: (bool? selected) {},
            ),
          ),
          const DataColumn(
            label: Text(
              'Dessert (100g serving)',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          const DataColumn(
            label: Text(
              'Calories',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          const DataColumn(
            label: Text(
              'Fat (g)',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          const DataColumn(
            label: Text(
              'Carbs',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
          const DataColumn(
            label: Text(
              'Protein (g)',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
          ),
        ];

        // Tambahkan kolom "Comments" jika lebar mencukupi
        if (showTabletColumn) {
          columns.add(
            const DataColumn(
              label: Text(
                'Comments',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              ),
            ),
          );
        }

        // Fungsi untuk membuat sel data, menyertakan sel "Comments" jika perlu
        List<DataCell> buildCells(Dessert d) {
          List<DataCell> cells = [
            // Sel Checkbox
            DataCell(Checkbox(value: false, onChanged: (bool? selected) {})),
            DataCell(
              Text(d.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            DataCell(Text(d.calories.toString())),
            DataCell(Text(d.fat.toString())),
            DataCell(Text(d.carbs.toString())),
            DataCell(Text(d.protein.toString())),
          ];

          // Tambahkan sel "Comments" jika lebar mencukupi
          if (showTabletColumn) {
            // Contoh data dummy untuk kolom Comments
            String comment = (d.calories > 300) ? 'High' : 'Low';
            cells.add(DataCell(Text(comment)));
          }
          return cells;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tablet-only columns',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              '"Comments" column will be visible only on\ndevices with screen width >= 768px (tablets)',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16.0),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMinHeight: 55,
                dataRowMaxHeight: 55,
                headingRowHeight: 55,
                border: TableBorder(
                  verticalInside: BorderSide.none,
                  horizontalInside: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                  top: BorderSide(color: Colors.grey.shade300, width: 1.0),
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
                ),
                dataRowColor: MaterialStateProperty.resolveWith<Color>((
                  Set<MaterialState> states,
                ) {
                  return Colors.white;
                }),

                // Menggunakan daftar kolom yang telah dibuat
                columns: columns,

                // Baris
                rows: _selectableDesserts.map((d) {
                  // Menggunakan 4 item pertama
                  return DataRow(
                    cells: buildCells(d), // Menggunakan fungsi buildCells
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- BUILD UTAMA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Jika kita ingin memastikan kembali ke halaman User dari mana pun
            // halaman ini dipanggil, gunakan named route '/user' yang didefinisikan di main.dart
            Navigator.pushReplacementNamed(context, '/user');
          },
        ),
        title: const Text(
          'Data Table',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Plain table
              const Text(
                'Plain table',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildPlainDataTable(),

              const SizedBox(height: 32.0),

              // 2. Within card
              const Text(
                'Within card',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildCardDataTable(),

              const SizedBox(height: 32.0),

              // 3. With Footer Pagination (BARU)
              _buildFooterPagination(),

              const SizedBox(height: 32.0),

              // 4. Selectable Rows (BARU)
              _buildSelectableRows(),

              const SizedBox(height: 32.0),

              // 5. Tablet-only columns (BARU)
              _buildTabletOnlyColumns(),

              const SizedBox(height: 32.0),

              // 6. With Inputs (BARU)
              _buildWithInputs(),

              const SizedBox(height: 32.0),

              // 7. Within card with title and actions (BARU)
              _buildCardWithTitleAndActions(),

              const SizedBox(height: 32.0),

              // 8. Sortable columns (BARU)
              _buildSortableColumns(),

              const SizedBox(height: 32.0),

              // 9. With title and different actions on select (BARU)
              _buildWithTitleAndActionsOnSelect(),

              const SizedBox(height: 32.0),

              // 10. Alternate header with actions (FINAL)
              _buildAlternateHeaderWithActions(),

              const SizedBox(height: 32.0),

              // 11. Collapsible (FINAL)
              _buildCollapsibleTable(),

              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
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
          onPressed: () => Navigator.pop(context),
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
    // List contoh untuk Autocomplete
    final List<String> options = [
      'Apple',
      'Banana',
      'Orange',
      'Grape',
      'Mango',
      'Strawberry',
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
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          fieldViewBuilder:
              (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF0F0F0,
                    ), // Latar belakang abu-abu muda
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
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    cursorColor: Colors.deepPurple,
                  ),
                );
              },
          optionsViewBuilder:
              (
                BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options,
              ) {
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
                            child: ListTile(title: Text(option)),
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

class BadgePage extends StatelessWidget {
  const BadgePage({Key? key}) : super(key: key);

  Widget _buildIconWithBadge({
    required IconData icon,
    required int count,
    required String label,
    Color? activeColor,
    Color? bgColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: activeColor ?? Colors.grey.shade700, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: activeColor ?? Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 8,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Badge'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.person, size: 40),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: const Text(
                      '5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                BadgeListItem(
                  name: 'Foo Bar',
                  badge: BadgeWidget(
                    text: '0',
                    backgroundColor: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                BadgeListItem(
                  name: 'Ivan Petrov',
                  badge: BadgeWidget(
                    text: 'CEO',
                    backgroundColor: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                BadgeListItem(
                  name: 'John Doe',
                  badge: BadgeWidget(
                    text: '5',
                    backgroundColor: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                BadgeListItem(
                  name: 'Jane Doe',
                  badge: BadgeWidget(
                    text: 'NEW',
                    backgroundColor: Colors.brown.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildIconWithBadge(
                      icon: Ionicons.mail_outline,
                      count: 5,
                      label: 'Inbox',
                      activeColor: Colors.green.shade900,
                      bgColor: Colors.green.shade100,
                    ),
                    _buildIconWithBadge(
                      icon: Ionicons.calendar_outline,
                      count: 7,
                      label: 'Calendar',
                    ),
                    _buildIconWithBadge(
                      icon: Ionicons.cloud_upload_outline,
                      count: 1,
                      label: 'Upload',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LazyLoadPage extends StatelessWidget {
  const LazyLoadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9), // warna latar seperti di gambar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: const Text(
          'Not found',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Sorry',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              'Requested content not found.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeListItem extends StatelessWidget {
  final String name;
  final Widget badge;

  const BadgeListItem({Key? key, required this.name, required this.badge})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/images/logo-icon.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          badge,
        ],
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  final String text;
  final Color backgroundColor;

  const BadgeWidget({
    Key? key,
    required this.text,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final Color badgeColor;
  final bool isSelected;

  const BottomNavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.badgeCount,
    required this.badgeColor,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.green.shade700
                    : Colors.grey.shade700,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 8,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              badgeCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9), // warna latar seperti di gambar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: const Text(
          'Not found',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Sorry',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              'Requested content not found.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 8),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 25),
              Text(
                'Welcome to Framework7',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Framework7 – is a free and open source HTML mobile framework to develop hybrid mobile apps or web apps with iOS or Android (Material) native look and feel. It is also an indispensable prototyping apps tool to show working app prototype as soon as possible in case you need to. Framework7 is created by Vladimir Kharlampidi.\n\n'
                'The main approach of the Framework7 is to give you an opportunity to create iOS and Android (Material) apps with HTML, CSS and JavaScript easily and clear. Framework7 is full of freedom. It doesn’t limit your imagination or offer ways of any solutions somehow. Framework7 gives you freedom!\n\n'
                'Framework7 is not compatible with all platforms. It is focused only on iOS and Android (Material) to bring the best experience and simplicity.\n\n'
                'Framework7 is definitely for you if you decide to build iOS and Android hybrid app (Cordova or Capacitor) or web app that looks like and feels as great native iOS or Android (Material) apps.',
                style: TextStyle(
                  fontSize: 20,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Framework7Page extends StatelessWidget {
  const Framework7Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(child: Text('Framework7')),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            '',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/logo-icon.png',
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'About Framework7',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Components',
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccordionPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Accordion',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActionSheetPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Action Sheet',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotFoundPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Appbar',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AutocompletePage(), // Arahkan ke AutocompletePage
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Autocomplete',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BadgePage()),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Badge',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ButtonsPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Buttons',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Calendar / Date Picker',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CardsPage()),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Cards',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CardsExpandablePage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Cards Expandable',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckboxPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Checkbox',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChipsPage()),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Chips / Tags',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                // BARU: Color Picker
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ColorPickerPage(), // Navigasi ke ColorPickerPage
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.colorize_outlined, // Ikon untuk Color Picker
                    title: 'Color Picker',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactsListPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Contacts List',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContentBlockPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Content Block',
                    backgroundColor: Colors.transparent,
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      // PASTIKAN ANDA MENGGUNAKAN KELAS DataTablePage DI SINI
                      builder: (context) => const DataTablePage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Data Table',
                    backgroundColor: Colors.transparent,
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DialogPage()),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Dialog',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotFoundPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Elevation',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FabDemoPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'FAB',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FabMorphPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'FAB Morph',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormStoragePage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Form Storage',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GaugePage()),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Gauge',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GridLayoutPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Grid/Layout Grid',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Icons',
                  backgroundColor: Colors.transparent,
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfiniteScrollPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Infinite Scroll',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Inputs',
                  backgroundColor: Colors.transparent,
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LazyLoadPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Lazy Load',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LazyLoadPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'List View',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'List Index',
                  backgroundColor: Colors.transparent,
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginMenuPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Login Screen',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LazyLoadPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.android,
                    title: 'Menu',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Messages',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Navbar',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Notifications',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Panel / Side Panels',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Photo Browser',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Picker',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Popover',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Popup',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Preloader',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Progress Bar',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Full To Refresh',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Radio',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Range Slider',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Searchbar',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Searchbar Expandable',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Sheet Modal',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Skeleton (Ghost) Layouts',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Smart Select',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Sortable List',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Stepper',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Subnavbar',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Swipeout (Swipe To Delete)',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.android,
                  title: 'Swiper Slider',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.videocam,
                  title: 'Tabs',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.videocam,
                  title: 'Text Editor',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.videocam,
                  title: 'Timeline',
                  backgroundColor: Colors.transparent,
                ),
                ComponentListItem(
                  icon: Icons.videocam,
                  title: 'Toast',
                  backgroundColor: Colors.transparent,
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ToggleScreen(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.videocam,
                    title: 'Toggle',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                ComponentListItem(
                  icon: Icons.videocam,
                  title: 'Toolbar & Tabbar',
                  backgroundColor: Colors.transparent,
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TooltipScreen(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.videocam,
                    title: 'Tooltip',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                ComponentListItem(
                  icon: Icons.videocam,
                  title: 'Treeview',
                  backgroundColor: Colors.transparent,
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VirtualListPage(),
                    ),
                  ),
                  child: ComponentListItem(
                    icon: Icons.videocam,
                    title: 'Virtual List',
                    backgroundColor: Colors.transparent,
                  ),
                ),
                ComponentListItem(
                  icon: Icons.videocam,
                  title: 'vi - Mobile Video SSP',
                  backgroundColor: Colors.transparent,
                  iconColor: Colors.white,
                  imagePath: 'assets/images/vi-icon.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Teks panjang untuk halaman FAB Morph

// DEFINISI ComponentListItem yang Diberikan Pengguna
class ComponentListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color backgroundColor;
  final Color iconColor;
  final String? imagePath;

  const ComponentListItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.imagePath = 'assets/images/logo-icon.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              // PERBAIKAN LOGIKA: Jika imagePath kosong atau null, gunakan Icon.
              // Ini mencegah Asset Not Found Error jika gambar default tidak ada.
              (imagePath == null || imagePath!.isEmpty)
              ? Icon(icon, color: iconColor, size: 24)
              : Image.asset(
                  imagePath!,
                  width: 24,
                  height: 24,
                  color: iconColor,
                ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ),
    );
  }
}

// --- Konstanta Teks Lorem Ipsum ---
const String LOREM_IPSUM_TEXT = """
Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quia, quo rem beatae, delectus eligendi est saepe molestias perferendis suscipit, commodi labore ipsa non quasi eum magnam neque ducimus! Quasi, numquam.

Maiores culpa, itaque! Eaque natus ab cum ipsam numquam blanditiis a, quia, molestiae aut laudantium recusandae ipsa. Ad iste ex asperiores ipsa, mollitia perferendis consectetur quam eaque, voluptate laboriosam unde.

Sed odit quis aperiam temporibus vitae necessitatibus, laboriosam, exercitationem dolores odio sapiente provident. Accusantium id, itaque aliquam libero ipsum eos fugiat distinctio laboriosam exercitationem sequi facere quas quidem magnam reprehenderit.

Pariatur corporis illo, amet doloremque. Ab veritatis sunt nisi consectetur error modi, nam illo et nostrum quia aliquam ipsam vitae facere voluptates atque similique odit mollitia, rerum placeat nobis est.

Et impedit soluta minus a autem adipisci cupiditate eius dignissimos nihil officia dolore voluptatibus aperiam reprehenderit esse facilis labore qui, officiis consectetur. Ipsa obcaecati aspernatur odio assumenda veniam, ipsum alias.

Lorem ipsum dolor sit amet, consectetur adipisicing elit. Culpa ipsa debitis sed nihil eaque dolore cum iste quibusdam, accusamus doloribus, tempora quia quos voluptatibus corporis officia at quas dolorem earum!

Quod soluta eos inventore magnam suscipit enim at hic in maiores temporibus pariatur tempora minima blanditiis vero autem est perspiciatis totam dolorum, itaque repellat? Nobis necessitatibus aut odit aliquam adipisci.

Tenetur delectus perspiciatis ex numquam, unde corrupti velit! Quam aperiam, animi fuga veritatis consectetur, voluptatibus atque consequuntur dignissimos itaque, sint impedit cum cumque at. Adipisci sint, iusto blanditiis ullam? Vel?

Dignissimos velit officia quibusdam! Eveniet beatae, aut, omnis temporibus consequatur expedita eaque aliquid quos accusamus fugiat id iusto autem obcaecati repellat fugit cupiditate suscipit natus quas doloribus? Temporibus necessitatibus, libero.

Architecto quisquam ipsa fugit facere, repudiandae asperiores vitae obcaecati possimus, labore excepturi reprehenderit consectetur perferendis, ullam quidem hic, repellat fugiat eaque fuga. Consectetur in eveniet, deleniti recusandae omnis eum quas?

Quos nulla consequatur quo, officia quaerat. Nulla voluptatum, assumenda quibusdam, placeat cum aut illo deleniti dolores commodi odio ipsam, recusandae est pariatur veniam repudiandae blanditiis. Voluptas unde deleniti quisquam, nobis?

Atque qui quaerat quasi officia molestiae, molestias totam incidunt reprehenderit laboriosam facilis veritatis, non iusto! Dolore ipsam obcaecati voluptates minima maxime minus qui mollitia facere. Nostrum esse recusandae voluptatibus eligendi.
""";
// ---------------------------------------------

// Daftar Link untuk Menu (FAB 1)
const List<String> MENU_LINKS = ['Link 1', 'Link 2', 'Link 3', 'Link 4'];

// Daftar Item untuk NavBar (FAB 3)
const List<Map<String, dynamic>> NAV_ITEMS = [
  {'icon': Icons.inbox, 'label': 'Inbox'},
  {'icon': Icons.calendar_today, 'label': 'Calendar'},
  {'icon': Icons.cloud_upload, 'label': 'Upload'},
];

// Nilai konstanta untuk FAB dan NavBar
const double FAB_SIZE = 56.0;
const double FAB_SPACING = 95.0;
const double NAV_BAR_HEIGHT = 70.0;
const double FAB_BOTTOM_POSITION = NAV_BAR_HEIGHT + 15.0;

void main() {
  runApp(const FabMorphApp());
}

class FabMorphApp extends StatelessWidget {
  const FabMorphApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAB Morph Demo',
      theme: ThemeData(
        useMaterial3: true,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue.shade100.withOpacity(0.9),
          foregroundColor: Colors.blue.shade700,
          elevation: 0,
        ),
      ),
      home: const FabMorphPage(),
    );
  }
}

class FabMorphPage extends StatefulWidget {
  const FabMorphPage({super.key});

  @override
  State<FabMorphPage> createState() => _FabMorphPageState();
}

class _FabMorphPageState extends State<FabMorphPage> {
  bool _isMenuOpen = false;
  bool _isNavBarOpen = false;

  void _toggleMenu() {
    setState(() {
      _isNavBarOpen = false;
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _toggleNavBar() {
    setState(() {
      _isMenuOpen = false;
      _isNavBarOpen = !_isNavBarOpen;
    });
  }

  // --- WIDGET FAB 1 MORPH (Menu Link) ---
  Widget _buildDefaultFab1() {
    return FloatingActionButton(
      heroTag: 'fab1_add',
      onPressed: _toggleMenu,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildMenuLinks() {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: MENU_LINKS.map((link) {
          return InkWell(
            onTap: _toggleMenu,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(link, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMorphingFab1(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: _isMenuOpen ? _buildMenuLinks() : _buildDefaultFab1(),
      key: ValueKey<bool>(_isMenuOpen),
    );
  }

  // --- WIDGET FAB 3 MORPH (Menghilang saat NavBar terbuka) ---

  Widget _buildDefaultFab3() {
    return FloatingActionButton(
      heroTag: 'fab3_add',
      onPressed: _toggleNavBar,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildMorphingFab3() {
    // 🚨 KOREKSI LOGIKA: FAB 3 menghilang ketika NavBar terbuka.
    // Menggunakan AnimatedSwitcher untuk transisi menghilang.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Menggunakan FadeTransition untuk transisi menghilang/muncul
        return FadeTransition(opacity: animation, child: child);
      },
      child: _isNavBarOpen
          ? const SizedBox.shrink(
              key: ValueKey<bool>(true),
            ) // Widget Kosong (Menghilang)
          : _buildDefaultFab3(), // FAB Normal (Muncul)
      key: ValueKey<bool>(_isNavBarOpen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Padding bawah disesuaikan dengan tinggi NavBar jika terbuka
    final double contentBottomPadding = _isNavBarOpen
        ? NAV_BAR_HEIGHT + 16.0
        : FAB_BOTTOM_POSITION + FAB_SIZE + 16.0;

    const double totalFabWidth = FAB_SIZE * 3 + FAB_SPACING * 2;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Floating Action Button ...'),
      ),

      // MENGGUNAKAN STACK UNTUK FAB FIXED DAN NAVBAR FIXED
      body: Stack(
        children: [
          // 1. Konten yang dapat digulir (Base Layer)
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                contentBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    LOREM_IPSUM_TEXT,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          // 2. Tiga FAB FIXED (Overlay Layer)
          Positioned(
            left: 0,
            right: 0,
            bottom: FAB_BOTTOM_POSITION,
            child: Center(
              child: SizedBox(
                width: totalFabWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // FAB 1 (Morphing Menu)
                    SizedBox(
                      width: FAB_SIZE,
                      height: FAB_SIZE,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: _buildMorphingFab1(context),
                          ),
                        ],
                      ),
                    ),

                    // FAB 2 (Tetap)
                    FloatingActionButton(
                      heroTag: 'fab2',
                      onPressed: () {},
                      child: const Icon(Icons.add),
                    ),

                    // FAB 3 (Morphing Menghilang)
                    SizedBox(
                      width: FAB_SIZE,
                      height: FAB_SIZE,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: _buildMorphingFab3(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. NAVBAR FIXED (Muncul dari bawah)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: _isNavBarOpen ? 0 : -NAV_BAR_HEIGHT,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: NAV_BAR_HEIGHT,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: NAV_ITEMS.map((item) {
                  return InkWell(
                    onTap:
                        _toggleNavBar, // 🚨 NAVBAR TUTUP JIKA SALAH SATU ITEM DIKLIK (Logika Default)
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: Colors.blue.shade700,
                          ),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: null,
      floatingActionButtonLocation: null,
    );
  }
}

class CheckboxPage extends StatefulWidget {
  const CheckboxPage({super.key});

  @override
  State<CheckboxPage> createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  // State untuk Checkbox Group tambahan
  bool booksCheckedLeft = true;
  bool moviesCheckedGroupLeft = false;
  bool foodCheckedLeft = false;
  bool drinksCheckedLeft = false;

  // State untuk Checkbox Group kanan
  bool booksCheckedRight = false;
  bool moviesCheckedGroupRight = false;
  bool foodCheckedRight = false;

  // State untuk inline checkboxes
  bool inlineCheckbox1 = false;
  bool inlineCheckbox2 = false;

  // State untuk indeterminate checkbox (movies)
  bool? moviesChecked = null;

  // State untuk movies child
  bool movie1Checked = true;
  bool movie2Checked = false;

  // Dummy data untuk media lists
  List<MediaItem> mediaItems = [
    MediaItem(
      source: 'Facebook',
      time: '17:14',
      title: 'New messages from John Doe',
      content:
          'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit. Nulla sagittis tellus ut turpi...',
    ),
    MediaItem(
      source: 'John Doe (via Twitter)',
      time: '17:11',
      title: 'John Doe (@_johndoe) mentioned you o...',
      content:
          'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit. Nulla sagittis tellus ut turpi...',
    ),
    MediaItem(
      source: 'Facebook',
      time: '16:48',
      title: 'New messages from John Doe',
      content:
          'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit. Nulla sagittis tellus ut turpi...',
    ),
    MediaItem(
      source: 'John Doe (via Twitter)',
      time: '15:32',
      title: 'John Doe (@_johndoe) mentioned you o...',
      content:
          'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit. Nulla sagittis tellus ut turpi...',
    ),
  ];

  // State untuk media list checkbox
  List<bool> checkedMedia = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkbox'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inline Title
                Text(
                  "Inline",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),

                // Inline Text dengan checkbox di dalam paragraf
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    children: [
                      const TextSpan(text: "Lorem "),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Checkbox(
                          value: inlineCheckbox1,
                          activeColor: Colors.green[700],
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onChanged: (val) {
                            setState(() {
                              inlineCheckbox1 = val!;
                            });
                          },
                        ),
                      ),
                      const TextSpan(
                        text:
                            " ipsum dolor sit amet, consectetur adipisicing elit. Alias beatae illo nihil aut eius commodi sint eveniet aliquid eligendi",
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Checkbox(
                          value: inlineCheckbox2,
                          activeColor: Colors.green[700],
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onChanged: (val) {
                            setState(() {
                              inlineCheckbox2 = val!;
                            });
                          },
                        ),
                      ),
                      const TextSpan(
                        text:
                            " ad delectus impedit tempore nemo, enim vel praesentium consequatur nulla mollitia!",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Inline Title
                Text(
                  "Checkbox Group",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),

                // Checkbox Group kiri dengan checkbox di sebelah kiri
                Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.green[700],
                      value: booksCheckedLeft,
                      title: const Text("Books"),
                      onChanged: (val) =>
                          setState(() => booksCheckedLeft = val!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.green[700],
                      value: moviesCheckedGroupLeft,
                      title: const Text("Movies"),
                      onChanged: (val) =>
                          setState(() => moviesCheckedGroupLeft = val!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.green[700],
                      value: foodCheckedLeft,
                      title: const Text("Food"),
                      onChanged: (val) =>
                          setState(() => foodCheckedLeft = val!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.green[700],
                      value: drinksCheckedLeft,
                      title: const Text("Drinks"),
                      onChanged: (val) =>
                          setState(() => drinksCheckedLeft = val!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Checkbox Group kanan dengan checkbox di sebelah kanan
                Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Books"),
                      trailing: Checkbox(
                        activeColor: Colors.green[700],
                        value: booksCheckedRight,
                        onChanged: (val) =>
                            setState(() => booksCheckedRight = val!),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Movies"),
                      trailing: Checkbox(
                        activeColor: Colors.green[700],
                        value: moviesCheckedGroupRight,
                        onChanged: (val) =>
                            setState(() => moviesCheckedGroupRight = val!),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Food"),
                      trailing: Checkbox(
                        activeColor: Colors.green[700],
                        value: foodCheckedRight,
                        onChanged: (val) =>
                            setState(() => foodCheckedRight = val!),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Drinks"),
                      trailing: Checkbox(
                        activeColor: Colors.green[700],
                        value: foodCheckedRight,
                        onChanged: (val) =>
                            setState(() => foodCheckedRight = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Indeterminate State Text
                Text(
                  "Indeterminate State",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),

                // Movies with indeterminate checkbox
                Row(
                  children: [
                    Checkbox(
                      tristate: true,
                      value: moviesChecked,
                      activeColor: Colors.green[700],
                      onChanged: (bool? value) {
                        setState(() {
                          moviesChecked = value;
                          if (value == true) {
                            movie1Checked = true;
                            movie2Checked = true;
                          } else if (value == false) {
                            movie1Checked = false;
                            movie2Checked = false;
                          }
                        });
                      },
                    ),
                    const Text("Movies"),
                  ],
                ),

                // Movie 1
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: movie1Checked,
                        activeColor: Colors.green[700],
                        onChanged: (bool? value) {
                          setState(() {
                            movie1Checked = value ?? false;
                            _refreshMoviesCheckboxState();
                          });
                        },
                      ),
                      const Text("Movie 1"),
                    ],
                  ),
                ),

                // Divider between movies
                const Divider(
                  height: 0,
                  indent: 40,
                  endIndent: 0,
                  thickness: 1,
                  color: Colors.grey,
                ),

                // Movie 2
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: movie2Checked,
                        activeColor: Colors.green[700],
                        onChanged: (bool? value) {
                          setState(() {
                            movie2Checked = value ?? false;
                            _refreshMoviesCheckboxState();
                          });
                        },
                      ),
                      const Text("Movie 2"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // With Media Lists Title
                Text(
                  "With Media Lists",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),

                // Media list with checkbox
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mediaItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final media = mediaItems[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: checkedMedia[index],
                          activeColor: Colors.green[700],
                          onChanged: (bool? value) {
                            setState(() {
                              checkedMedia[index] = value ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      media.source,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    media.time,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                media.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                media.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Menyinkronkan status checkbox utama movies dengan anak-anaknya
  void _refreshMoviesCheckboxState() {
    if (movie1Checked && movie2Checked) {
      moviesChecked = true;
    } else if (!movie1Checked && !movie2Checked) {
      moviesChecked = false;
    } else {
      moviesChecked = null;
    }
  }
}

class MediaItem {
  final String source;
  final String time;
  final String title;
  final String content;

  MediaItem({
    required this.source,
    required this.time,
    required this.title,
    required this.content,
  });
}

class Contact {
  final String name;
  final bool isHeader;

  const Contact(this.name, {this.isHeader = false});
}

// Data kontak statis yang meniru tampilan di template
// Termasuk header huruf (A, B, C, V) sebagai item list.
final List<Contact> _contacts = const [
  // --- Group A ---
  Contact('A', isHeader: true),
  Contact('Aaron'),
  Contact('Abbie'),
  Contact('Adam'),
  Contact('Adele'),
  Contact('Agatha'),
  Contact('Agnes'),
  Contact('Albert'),
  Contact('Alexander'),

  // --- Group B ---
  Contact('B', isHeader: true),
  Contact('Bailey'),
  Contact('Barclay'),
  Contact('Bartolo'),
  Contact('Bellamy'),
  Contact('Belle'),
  Contact('Benjamin'),

  // --- Group C ---
  Contact('C', isHeader: true),
  Contact('Caiden'),
  Contact('Calvin'),
  Contact('Candy'),
  Contact('Carl'),
  Contact('Cherilyn'),
  Contact('Chester'),
  Contact('Chloe'),

  // --- Kontak Tambahan untuk memastikan scroll dan grup V terlihat ---
  Contact('D', isHeader: true),
  Contact('Dahlia'),
  Contact('Daniel'),
  Contact('E', isHeader: true),
  Contact('Edward'),
  Contact('Ester'),
  Contact('F', isHeader: true),
  Contact('Felix'),
  Contact('Fiona'),

  // --- Group V (sesuai screenshot kedua) ---
  Contact('V', isHeader: true),
  Contact('Vladimir'),
];

class ContactsListPage extends StatelessWidget {
  const ContactsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sudah sesuai dengan yang Anda berikan
      appBar: AppBar(
        title: const Text('Contacts List'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: Colors.white,

      // Mengganti body yang sebelumnya hanya menampilkan teks
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];

          if (contact.isHeader) {
            // Jika item adalah header (Huruf A, B, C, V)
            return Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                bottom: 8.0,
              ),
              child: Text(
                contact.name,
                style: const TextStyle(
                  color: Colors.green, // Warna hijau untuk huruf header
                  fontSize: 20, // Ukuran huruf lebih besar
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            // Jika item adalah nama kontak
            return Padding(
              // Memberi jarak ke kiri seperti di template
              padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
              child: Text(
                contact.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16, // Ukuran huruf kontak biasa
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class InfiniteScrollPage extends StatefulWidget {
  const InfiniteScrollPage({Key? key}) : super(key: key);

  @override
  _InfiniteScrollPageState createState() => _InfiniteScrollPageState();
}

class _InfiniteScrollPageState extends State<InfiniteScrollPage> {
  final ScrollController _scrollController = ScrollController();
  final int _maxItems = 200;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Infinite Scroll'),
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _scrollToBottom,
              child: Text(
                'Scroll bottom',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _maxItems,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Item ${index + 1}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
