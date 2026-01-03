import 'package:flutter/material.dart';

class _PlusButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;
  final Widget? child;

  const _PlusButton({this.onTap, this.size = 56, this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF4CB32B),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: child ?? const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _NumberBubble extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _NumberBubble({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF4CB32B),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class FabDemoPage extends StatefulWidget {
  const FabDemoPage({super.key});

  static const String _lorem =
      '''Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quia, quo rem beatae, delectus eligendi est saepe molestias perferendis suscipit, commodi labore ipsa non quasi eum magnam neque ducimus! Quasi, numquam.

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

Atque qui quaerat quasi officia molestiae, molestias totam incidunt reprehenderit laboriosam facilis veritatis, non iusto! Dolore ipsam obcaecati voluptates minima maxime minus qui mollitia facere. Nostrum esse recusandae voluptatibus eligendi.''';

  @override
  State<FabDemoPage> createState() => _FabDemoPageState();
}

class _FabDemoPageState extends State<FabDemoPage>
    with SingleTickerProviderStateMixin {
  bool topLeftExpanded = false;
  bool bottomLeftExpanded = false;
  bool topRightExpanded = false;
  bool bottomRightExpanded = false;
  bool centerPressed = false;
  bool centerExpanded = false;
  late final AnimationController _centerController;

  @override
  void initState() {
    super.initState();
    _centerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
  }

  @override
  void dispose() {
    _centerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Floating Action Button',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Text(
                    FabDemoPage._lorem,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom centered Create pill button
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Create pressed')),
                    );
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CB32B),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top-left expandable + with numbered actions (stacked below when opened)
          Align(
            alignment: const Alignment(-0.85, -0.7),
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // main toggle button (X when expanded)
                  _PlusButton(
                    onTap: () =>
                        setState(() => topLeftExpanded = !topLeftExpanded),
                    size: 56,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (w, a) =>
                          ScaleTransition(scale: a, child: w),
                      child: topLeftExpanded
                          ? const Icon(
                              Icons.close,
                              key: ValueKey('x'),
                              color: Colors.black,
                            )
                          : const Icon(
                              Icons.add,
                              key: ValueKey('+'),
                              color: Colors.white,
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Animated area for numbers (appear below the main +)
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // nearest to main button
                        _NumberBubble(
                          label: '1',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Action 1')),
                              ),
                        ),
                        const SizedBox(height: 8),
                        _NumberBubble(
                          label: '2',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Action 2')),
                              ),
                        ),
                        const SizedBox(height: 8),
                        // bottom-most
                        _NumberBubble(
                          label: '3',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Action 3')),
                              ),
                        ),
                      ],
                    ),
                    crossFadeState: topLeftExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                  ),
                ],
              ),
            ),
          ),

          // Top-right expandable + (numbers appear to the left)
          Align(
            alignment: const Alignment(0.85, -0.7),
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // leftmost
                        _NumberBubble(
                          label: '3',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Top Action 3')),
                              ),
                        ),
                        const SizedBox(width: 8),
                        _NumberBubble(
                          label: '2',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Top Action 2')),
                              ),
                        ),
                        const SizedBox(width: 8),
                        // nearest to main button
                        _NumberBubble(
                          label: '1',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Top Action 1')),
                              ),
                        ),
                      ],
                    ),
                    crossFadeState: topRightExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                  ),

                  const SizedBox(width: 8),

                  _PlusButton(
                    onTap: () =>
                        setState(() => topRightExpanded = !topRightExpanded),
                    size: 56,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (w, a) =>
                          ScaleTransition(scale: a, child: w),
                      child: topRightExpanded
                          ? const Icon(
                              Icons.close,
                              key: ValueKey('trx'),
                              color: Colors.black,
                            )
                          : const Icon(
                              Icons.add,
                              key: ValueKey('tr+'),
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center larger + with four-directional expansion
          Align(
            alignment: const Alignment(0, -0.05),
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top bubble (1)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    top: centerExpanded ? 18 : 80,
                    left: 72,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: centerExpanded ? 1.0 : 0.0,
                      child: _NumberBubble(
                        label: '1',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Center Action 1')),
                        ),
                      ),
                    ),
                  ),

                  // Right bubble (2)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    top: 72,
                    left: centerExpanded ? 124 : 80,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: centerExpanded ? 1.0 : 0.0,
                      child: _NumberBubble(
                        label: '2',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Center Action 2')),
                        ),
                      ),
                    ),
                  ),

                  // Bottom bubble (3)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    top: centerExpanded ? 124 : 80,
                    left: 72,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: centerExpanded ? 1.0 : 0.0,
                      child: _NumberBubble(
                        label: '3',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Center Action 3')),
                        ),
                      ),
                    ),
                  ),

                  // Left bubble (4)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    top: 72,
                    left: centerExpanded ? 20 : 80,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: centerExpanded ? 1.0 : 0.0,
                      child: _NumberBubble(
                        label: '4',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Center Action 4')),
                        ),
                      ),
                    ),
                  ),

                  // center main button
                  AnimatedScale(
                    scale: centerExpanded ? 0.92 : 1.0,
                    duration: const Duration(milliseconds: 160),
                    child: _PlusButton(
                      onTap: () =>
                          setState(() => centerExpanded = !centerExpanded),
                      size: 64,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        transitionBuilder: (w, a) =>
                            ScaleTransition(scale: a, child: w),
                        child: centerExpanded
                            ? const Icon(
                                Icons.close,
                                key: ValueKey('cx'),
                                color: Colors.black,
                              )
                            : const Icon(
                                Icons.add,
                                key: ValueKey('c+'),
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom-left + (expand numbers stacked above when toggled)
          Align(
            alignment: const Alignment(-0.85, 0.9),
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // top-most
                        _NumberBubble(
                          label: '3',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bottom Action 3'),
                                ),
                              ),
                        ),
                        const SizedBox(height: 8),
                        _NumberBubble(
                          label: '2',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bottom Action 2'),
                                ),
                              ),
                        ),
                        const SizedBox(height: 8),
                        // nearest to main button
                        _NumberBubble(
                          label: '1',
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bottom Action 1'),
                                ),
                              ),
                        ),
                      ],
                    ),
                    crossFadeState: bottomLeftExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                  ),

                  const SizedBox(height: 8),

                  _PlusButton(
                    onTap: () => setState(
                      () => bottomLeftExpanded = !bottomLeftExpanded,
                    ),
                    size: 56,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (w, a) =>
                          ScaleTransition(scale: a, child: w),
                      child: bottomLeftExpanded
                          ? const Icon(
                              Icons.close,
                              key: ValueKey('bx'),
                              color: Colors.black,
                            )
                          : const Icon(
                              Icons.add,
                              key: ValueKey('b+'),
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom-right expandable + with labels to the left of each number
          Align(
            alignment: const Alignment(0.85, 0.9),
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated area for stacked numbered bubbles (appear above main +)
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // top-most action row (label left, bubble right)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Third Action'),
                            ),
                            const SizedBox(width: 8),
                            _NumberBubble(
                              label: '3',
                              onTap: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('BR Action 3'),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Action 2'),
                            ),
                            const SizedBox(width: 8),
                            _NumberBubble(
                              label: '2',
                              onTap: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('BR Action 2'),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Action 1'),
                            ),
                            const SizedBox(width: 8),
                            _NumberBubble(
                              label: '1',
                              onTap: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('BR Action 1'),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    crossFadeState: bottomRightExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                  ),

                  const SizedBox(height: 8),

                  _PlusButton(
                    onTap: () => setState(
                      () => bottomRightExpanded = !bottomRightExpanded,
                    ),
                    size: 56,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (w, a) =>
                          ScaleTransition(scale: a, child: w),
                      child: bottomRightExpanded
                          ? const Icon(
                              Icons.close,
                              key: ValueKey('brx'),
                              color: Colors.black,
                            )
                          : const Icon(
                              Icons.add,
                              key: ValueKey('br+'),
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
