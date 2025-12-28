import 'package:flutter/material.dart';

void main() {
  runApp(const TooltipApp());
}

class TooltipApp extends StatelessWidget {
  const TooltipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tooltip Example',
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const TooltipScreen(),
    );
  }
}

class TooltipScreen extends StatefulWidget {
  const TooltipScreen({super.key});

  @override
  State<TooltipScreen> createState() => _TooltipScreenState();
}

class _TooltipScreenState extends State<TooltipScreen> {
  OverlayEntry? _overlayEntry;

  void _showCustomTooltip(BuildContext context) {
    // Hapus tooltip sebelumnya kalau ada
    _removeTooltip();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height + 5,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
              ],
            ),
            child: const DefaultTextStyle(
              style: TextStyle(color: Colors.white, fontSize: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('one more tooltip'),
                  Text('with more text'),
                  Text(
                    'and custom formatting',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 3), _removeTooltip);
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildInfoIcon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(Icons.info_outline, size: 16.0, color: Colors.black),
    );
  }

  List<InlineSpan> _buildRichTextSpans(String text) {
    final parts = text.split('info');
    final List<InlineSpan> spans = [];
    const bodyStyle = TextStyle(
      fontSize: 16.0,
      height: 1.5,
      color: Colors.black87,
    );
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: bodyStyle));
      }
      if (i < parts.length - 1) {
        spans.add(WidgetSpan(child: _buildInfoIcon()));
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    const String firstBoxContent =
        'Tooltips display informative text when users hover over, or tap an target element.\n\n'
        'Tooltip can be positioned around any element with any HTML content inside.';

    const String secondBoxContent = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec lacinia augue urna, in tincidunt augue hendrerit ut. In nulla massa, facilisis non consectetur a, tempus semper ex. Proin eget volutpat nisl. Integer lacinia maximus nunc molestie viverra. info Etiam ullamcorper ultricies ipsum, ut congue tortor rutrum at. Vestibulum rutrum risus a orci dictum, in placerat leo finibus. Sed a congue enim, ut dictum felis. Aliquam erat volutpat. Etiam id nisi in magna egestas malesuada. Sed vitae orci sollicitudin, accumsan nisi a, bibendum felis. Maecenas risus libero, gravida ut tincidunt auctor, info aliquam non lectus. Nam laoreet turpis erat, eget bibendum leo suscipit nec.

Vestibulum info gravida dui magna, eget pulvinar ligula molestie hendrerit. Mauris vitae facilisis justo. Nam velit mi, pharetra sit amet luctus quis, consectetur a tellus. Maecenas ac magna sit amet eros aliquam rhoncus. Ut dapibus vehicula lectus, ac blandit felis ultricies at. In sollicitudin, lorem eget volutpat viverra, magna info felis tempus nisl, porta consectetur nunc neque eget risus. Phasellus vestibulum leo at ante ornare, vel congue justo tincidunt.

Praesent tempus enim id lectus porta, at rutrum purus imperdiet. Donec eget sem vulputate, scelerisque diam nec, consequat turpis. Ut vel convallis felis. Integer info neque ex, sollicitudin vitae magna eget, ultrices volutpat dui. Sed placerat odio hendrerit consequat lobortis. Fusce pulvinar facilisis rhoncus. Sed erat ipsum, consequat molestie suscipit vitae, malesuada a info massa.
''';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tooltip',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.black),
              onPressed: () => _showCustomTooltip(context),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: Colors.grey.shade300),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Kotak pertama
            Card(
              elevation: 0,
              color: const Color(0xFFF4F6FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.zero,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  firstBoxContent,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Kotak kedua (teks panjang dengan ikon i)
            Card(
              elevation: 0,
              color: const Color(0xFFF4F6FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    children: _buildRichTextSpans(secondBoxContent),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Kotak ketiga
            const SecondCardWidget(),
          ],
        ),
      ),
    );
  }
}

// --- Kotak ketiga tetap sama ---
class SecondCardWidget extends StatelessWidget {
  const SecondCardWidget({super.key});

  Widget _buildHighlightedText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(color: Colors.yellow.shade100),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          height: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: const Color(0xFFF4F6FF),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auto Initialization',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18.0,
                  height: 1.5,
                  color: Colors.black,
                ),
                children: <InlineSpan>[
                  const TextSpan(
                    text:
                        'For simple cases when you don\'t need a lot of control over the Tooltip, it can be initialized automatically with ',
                  ),
                  WidgetSpan(child: _buildHighlightedText('tooltip-init')),
                  const TextSpan(text: ' class and '),
                  WidgetSpan(child: _buildHighlightedText('data-tooltip')),
                  const TextSpan(text: ' attribute: '),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Button with Tooltip',
                style: TextStyle(fontSize: 16.0, color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
