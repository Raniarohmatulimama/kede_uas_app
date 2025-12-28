import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buttons',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const ButtonsPage(),
    );
  }
}

class ButtonsPage extends StatelessWidget {
  const ButtonsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Buttons'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usual Buttons Section
            buildSectionTitle("Usual Buttons"),
            buildUsualButtonsSection(),

            const SizedBox(height: 26),

            // Tonal Buttons Section
            buildSectionTitle("Tonal Buttons"),
            buildTonalButtonsSection(),

            const SizedBox(height: 26),

            // Fill Buttons Section
            buildSectionTitle("Fill Buttons"),
            buildFillButtonsSection(),

            const SizedBox(height: 26),

            // Outline Buttons Section
            buildSectionTitle("Outline Buttons"),
            buildOutlineButtonsSection(),

            const SizedBox(height: 26),

            // Raised Buttons Section
            buildSectionTitle("Raised Buttons"),
            buildRaisedButtonsSection(),

            const SizedBox(height: 26),

            // Large Buttons Section
            buildSectionTitle("Large Buttons"),
            buildLargeButtonsSection(),

            const SizedBox(height: 26),

            // Small Buttons Section
            buildSectionTitle("Small Buttons"),
            buildSmallButtonsSection(),

            const SizedBox(height: 26),

            // Color Buttons Section
            buildSectionTitle("Color Buttons"),
            buildColorButtonsSection(),

            const SizedBox(height: 26),

            // Preloader Buttons Section
            buildSectionTitle("Preloader Buttons"),
            buildPreloaderButtonsSection(),

            const SizedBox(height: 26),

            // Color Fill Buttons Section
            buildSectionTitle("Color Fill Buttons"),
            buildColorFillButtonsSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildUsualButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildSimpleButton(
            "Button",
            Colors.transparent,
            Colors.white,
            false,
            borderRadius: 12,
          ),
          buildSimpleButton(
            "Button",
            Colors.transparent,
            Colors.white,
            false,
            borderRadius: 4,
          ),
          buildSimpleButton("Round", Colors.transparent, Colors.white, true),
        ],
      ),
    );
  }

  Widget buildTonalButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildSimpleButton(
            "Button",
            const Color(0xFFDDEFD8),
            Colors.white,
            false,
            borderRadius: 15,
          ),
          buildSimpleButton(
            "Button",
            const Color(0xFFDDEFD8),
            Colors.white,
            false,
            borderRadius: 15,
          ),
          buildSimpleButton(
            "Round",
            const Color(0xFFDDEFD8),
            Colors.white,
            false,
            borderRadius: 15,
          ),
        ],
      ),
    );
  }

  Widget buildFillButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildSimpleButton(
            "Button",
            const Color(0xFF48B03F),
            Colors.white,
            false,
            borderRadius: 15,
          ),
          buildSimpleButton(
            "Button",
            const Color(0xFF48B03F),
            Colors.white,
            false,
            borderRadius: 15,
          ),
          buildSimpleButton(
            "Round",
            const Color(0xFF48B03F),
            Colors.white,
            false,
            borderRadius: 15,
          ),
        ],
      ),
    );
  }

  Widget buildOutlineButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildOutlineButton("Button", false),
          buildOutlineButton("Button", false),
          buildOutlineButton("Round", false),
        ],
      ),
    );
  }

  Widget buildSimpleButton(
    String text,
    Color bgColor,
    Color textColor,
    bool round, {
    double borderRadius = 8,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(round ? 28 : borderRadius),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget buildOutlineButton(String text, bool round) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(round ? 15 : 15),
        border: Border.all(color: const Color(0xFF48B03F), width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF48B03F),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget buildRaisedButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "Button",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              buildButton(
                "Fill",
                true,
                false,
                null,
                false,
                Colors.white,
                borderRadius: 15,
                horizontalPadding: 24,
                verticalPadding: 12,
              ),
              buildButton(
                "Outline",
                false,
                true,
                const Color(0xFF48B03F),
                false,
                const Color(0xFF48B03F),
                round: false,
                borderRadius: 15,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "Button",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              buildButton(
                "Fill",
                true,
                false,
                null,
                false,
                Colors.white,
                borderRadius: 15,
                horizontalPadding: 24,
                verticalPadding: 12,
              ),
              buildButton(
                "Outline",
                false,
                true,
                const Color(0xFF48B03F),
                false,
                const Color(0xFF48B03F),
                round: false,
                borderRadius: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLargeButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: buildLargeButton("BUTTON", false, false)),
              const SizedBox(width: 12),
              Expanded(child: buildLargeButton("FILL", true, false)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildLargeButton("RAISED", false, false, raised: true),
              ),
              const SizedBox(width: 12),
              Expanded(child: buildLargeButton("RAISED FILL", true, false)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildLargeButton("ROUND", false, false, round: false),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildLargeButton(
                  "ROUND FILL",
                  true,
                  false,
                  round: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSmallButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSmallButton("Button", false, false, null),
              buildSmallButton(
                "Outline",
                false,
                true,
                const Color(0xFF48B03F),
                round: true,
              ),
              buildSmallButton("Fill", true, false, null, round: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSmallButton("Button", false, false, null),
              buildSmallButton(
                "Outline",
                false,
                true,
                const Color(0xFF48B03F),
                round: true,
              ),
              buildSmallButton("Fill", true, false, null, round: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildColorButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildColorButton("Red", Colors.red.shade100, Colors.red.shade300),
          buildColorButton(
            "Green",
            Colors.green.shade100,
            Colors.green.shade300,
          ),
          buildColorButton("Blue", Colors.blue.shade100, Colors.blue.shade300),
        ],
      ),
    );
  }

  Widget buildPreloaderButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: buildLargeButton("LOAD", false, false, round: true)),
          const SizedBox(width: 12),
          Expanded(child: buildLargeButton("LOAD", true, false, round: true)),
        ],
      ),
    );
  }



// --- FUNGSI UTAMA (BUILD BUTTONS SECTION) ---
  Widget buildColorFillButtonsSection() {
    // Warna latar belakang yang sangat muda, sesuai gambar.
    const Color containerBackgroundColor = Color(0xFFEFEFEF);

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: containerBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri untuk judul
        children: [
          // Judul: "Color Fill Buttons"
          const Text(
            "Color Fill Buttons",
            style: TextStyle(
              color: Color(0xFF4CAF50), // Warna hijau yang tepat
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Baris 1: Red, Green, Blue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: buildColorFillButton("Red", const Color(0xFFC62828))),
              const SizedBox(width: 8),
              Expanded(child: buildColorFillButton("Green", const Color(0xFF1B5E20))),
              const SizedBox(width: 8),
              Expanded(child: buildColorFillButton("Blue", const Color(0xFF0D47A1))),
            ],
          ),
          const SizedBox(height: 12),

          // Baris 2: Pink, Yellow, Orange
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: buildColorFillButton("Pink", const Color(0xFFAD1457))),
              const SizedBox(width: 8),
              // Warna Yellow yang dikoreksi (cokelat-emas gelap)
              Expanded(child: buildColorFillButton("Yellow", const Color(0xFF795548))),
              const SizedBox(width: 8),
              // Warna Orange yang dikoreksi (cokelat-oranye gelap)
              Expanded(child: buildColorFillButton("Orange", const Color(0xFF8D6E63))),
            ],
          ),
          const SizedBox(height: 12),

          // Baris 3: Black dan Tombol Kosong
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: buildColorFillButton("Black", Colors.black)),
              const SizedBox(width: 8),
              // Tombol kosong (latar belakang putih, teks transparan)
              Expanded(flex: 1, child: buildColorFillButton("", Colors.white, textColor: Colors.transparent)),
              // Expanded kosong untuk menjaga tata letak 3 kolom
              Expanded(flex: 1, child: Container()),
            ],
          ),
        ],
      ),
    );
  }

// --- FUNGSI PEMBANTU (buildColorFillButton) ---
// Fungsi ini harus ada agar kode di atas berfungsi. Pastikan hanya ada SATU definisi ini.
  Widget buildColorFillButton(String text, Color color, {Color textColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25), // Bentuk Pil
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Tambahkan logika onTap Anda di sini
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(
    String text,
    bool filled,
    bool outlined,
    Color? outlineColor,
    bool mixed,
    Color textColor, {
    bool round = false,
    double borderRadius = 8,
    bool transparent = false,
    double horizontalPadding = 20,
    double verticalPadding = 10,
  }) {
    Color bgColor;
    Color txtColor = textColor;
    BoxBorder? border;

    if (outlined) {
      bgColor = Colors.transparent;
      border = Border.all(
        color: outlineColor ?? const Color(0xFF48B03F),
        width: 1.5,
      );
      txtColor = Colors.white;
    } else if (filled) {
      bgColor = const Color(0xFF48B03F);
      txtColor = Colors.white;
    } else if (transparent) {
      bgColor = Colors.transparent;
      txtColor = textColor;
    } else {
      bgColor = Colors.white;
      txtColor = Colors.grey.shade400;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(round ? 20 : borderRadius),
        border: border,
        boxShadow: filled || outlined || transparent
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: txtColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget buildLargeButton(
    String text,
    bool filled,
    bool outlined, {
    bool round = false,
    bool raised = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: filled
            ? const Color(0xFF48B03F)
            : (raised ? Colors.white : Colors.transparent),
        borderRadius: BorderRadius.circular(round ? 24 : 12),
        border: outlined
            ? Border.all(color: const Color(0xFF48B03F), width: 1.5)
            : null,
        boxShadow: filled || outlined || raised ? [] : [],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: filled
              ? Colors.white
              : (raised ? Colors.grey.shade400 : Colors.white),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget buildSmallButton(
    String text,
    bool filled,
    bool outlined,
    Color? outlineColor, {
    bool round = false,
    bool transparent = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: filled
            ? const Color(0xFF48B03F)
            : (outlined ? Colors.transparent : Colors.white),
        borderRadius: BorderRadius.circular(round ? 20 : 8),
        border: outlined
            ? Border.all(
                color: outlineColor ?? const Color(0xFF48B03F),
                width: 1.5,
              )
            : null,
        boxShadow: filled || outlined
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: filled || transparent || outlined
              ? Colors.white
              : Colors.grey.shade400,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildColorButton(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }


}
