import 'package:flutter/material.dart';

class CardItem {
  final String title;
  final String subtitle;
  final Color color;
  final String? imageUrl;
  final String? detailText;

  CardItem({
    required this.title,
    required this.subtitle,
    required this.color,
    this.imageUrl,
    this.detailText,
  });
}

class CardsExpandablePage extends StatelessWidget {
  const CardsExpandablePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<CardItem> cards = [
      CardItem(
        title: 'Framework7',
        subtitle: 'Build Mobile Apps',
        color: const Color(0xFFFF5252),
        detailText:
            'Framework7 - is a free and open source HTML mobile framework to develop hybrid mobile apps or web apps with iOS or Android (Material) native look and feel. It is also an indispensable prototyping apps tool to show working app prototype as soon as possible in case you need to. Framework7 is created by Vladimir Kharlampidi (iDangero.us).'
            '\nThe main approach of the Framework7 is to give you an opportunity to create iOS and Android (Material) apps with HTML, CSS and JavaScript easily and clear. Framework7 is full of freedom. It doesnt limit your imagination or offer ways of any solutions somehow. Framework7 gives you freedom!'
            '\nFramework7 is not compatible with all platforms. It is focused only on iOS and Android (Material) to bring the best experience and simplicity.'
            '\nFramework7 is definitely for you if you decide to build iOS and Android hybrid app (Cordova or Capacitor) or web app that looks like and feels as great native iOS or Android (Material) apps.',
      ),

      CardItem(
        title: 'Framework7',
        subtitle: 'Build Mobile Apps',
        color: const Color(0xFFFFC107),
        detailText:
            'Framework7 - is a free and open source HTML mobile framework to develop hybrid mobile apps or web apps with iOS or Android (Material) native look and feel. It is also an indispensable prototyping apps tool to show working app prototype as soon as possible in case you need to. Framework7 is created by Vladimir Kharlampidi (iDangero.us).'
            '\nThe main approach of the Framework7 is to give you an opportunity to create iOS and Android (Material) apps with HTML, CSS and JavaScript easily and clear. Framework7 is full of freedom. It doesnt limit your imagination or offer ways of any solutions somehow. Framework7 gives you freedom!'
            '\nFramework7 is not compatible with all platforms. It is focused only on iOS and Android (Material) to bring the best experience and simplicity.'
            '\nFramework7 is definitely for you if you decide to build iOS and Android hybrid app (Cordova or Capacitor) or web app that looks like and feels as great native iOS or Android (Material) apps.',
      ),
      CardItem(
        title: 'Beach, Goa',
        subtitle: '',
        color: Colors.white,
        imageUrl: 'assets/images/beach.jpg',
        detailText:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam cursus rhoncus cursus. Etiam lorem est, consectetur vitae tempor a, volutpat eget purus. Duis urna lectus, vehicula at quam id, sodales dapibus turpis. Suspendisse potenti. Proin condimentum luctus nulla, et rhoncus ante rutrum eu. Maecenas ut tincidunt diam. Vestibulum lacinia dui ligula, sit amet pulvinar nisl blandit luctus. Vestibulum aliquam ligula nulla, tincidunt rhoncus tellus interdum at. Phasellus mollis ipsum at mollis tristique. Maecenas sit amet tempus justo. Duis dolor elit, mollis quis viverra quis, vehicula eu ante. Integer a molestie risus. Vestibulum eu sollicitudin massa, sit amet dictum sem. Aliquam nisi tellus, maximus eget placerat in, porta vel lorem. Aenean tempus sodales nisl in cursus. Curabitur tincidunt turpis in nisl ornare euismod eget at libero.'
            '\nSuspendisse ligula eros, congue in nulla pellentesque, imperdiet blandit sapien. Morbi nisi sem, efficitur a rutrum porttitor, feugiat vel enim. Fusce eget vehicula odio, et luctus neque. Donec mattis a nulla laoreet commodo. Integer eget hendrerit augue, vel porta libero. Morbi imperdiet, eros at ultricies rutrum, eros urna auctor enim, eget laoreet massa diam vitae lorem. Proin eget urna ultrices, semper ligula aliquam, dignissim eros. Donec vitae augue eu sapien tristique elementum a nec nulla. Aliquam erat volutpat. Curabitur condimentum, metus blandit lobortis fringilla, enim mauris venenatis neque, et venenatis lorem urna ut justo. Maecenas neque enim, congue ac tempor quis, tincidunt ut mi. Donec venenatis ante non consequat molestie. Quisque ut rhoncus ligula. Vestibulum sodales maximus justo sit amet ornare. Nullam pulvinar eleifend nisi sit amet molestie.',
      ),
      CardItem(
        title: 'Monkeys',
        subtitle: '',
        color: Colors.white,
        imageUrl: 'assets/images/monkey.jpg',
        detailText:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam cursus rhoncus cursus. Etiam lorem est, consectetur vitae tempor a, volutpat eget purus. Duis urna lectus, vehicula at quam id, sodales dapibus turpis. Suspendisse potenti. Proin condimentum luctus nulla, et rhoncus ante rutrum eu. Maecenas ut tincidunt diam. Vestibulum lacinia dui ligula, sit amet pulvinar nisl blandit luctus. Vestibulum aliquam ligula nulla, tincidunt rhoncus tellus interdum at. Phasellus mollis ipsum at mollis tristique. Maecenas sit amet tempus justo. Duis dolor elit, mollis quis viverra quis, vehicula eu ante. Integer a molestie risus. Vestibulum eu sollicitudin massa, sit amet dictum sem. Aliquam nisi tellus, maximus eget placerat in, porta vel lorem. Aenean tempus sodales nisl in cursus. Curabitur tincidunt turpis in nisl ornare euismod eget at libero.'
            '\nSuspendisse ligula eros, congue in nulla pellentesque, imperdiet blandit sapien. Morbi nisi sem, efficitur a rutrum porttitor, feugiat vel enim. Fusce eget vehicula odio, et luctus neque. Donec mattis a nulla laoreet commodo. Integer eget hendrerit augue, vel porta libero. Morbi imperdiet, eros at ultricies rutrum, eros urna auctor enim, eget laoreet massa diam vitae lorem. Proin eget urna ultrices, semper ligula aliquam, dignissim eros. Donec vitae augue eu sapien tristique elementum a nec nulla. Aliquam erat volutpat. Curabitur condimentum, metus blandit lobortis fringilla, enim mauris venenatis neque, et venenatis lorem urna ut justo. Maecenas neque enim, congue ac tempor quis, tincidunt ut mi. Donec venenatis ante non consequat molestie. Quisque ut rhoncus ligula. Vestibulum sodales maximus justo sit amet ornare. Nullam pulvinar eleifend nisi sit amet molestie.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Cards Expandable',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: 'In addition to usual '),
                          TextSpan(
                            text: 'Cards',
                            style: TextStyle(color: Colors.green),
                          ),
                          TextSpan(
                            text:
                                ' there are also Expandable Cards that allow to store more information and illustrations about particular subject.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Cards
                    ...cards.map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ExpandableCard(card: card),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandableCard extends StatelessWidget {
  final CardItem card;

  const ExpandableCard({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.imageUrl == 'assets/images/monkey.jpg') {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardDetailPage(card: card)),
          );
        },
        child: Container(
          height: 300,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.asset(
                  card.imageUrl!,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Text(
                    'Monkeys',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
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
    } else if (card.imageUrl == null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardDetailPage(card: card)),
          );
        },
        child: Container(
          height: 300,
          width: 500,
          decoration: BoxDecoration(
            color: card.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (card.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        card.subtitle,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardDetailPage(card: card)),
          );
        },
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: card.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  card.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (card.subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            card.subtitle,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class CardDetailPage extends StatefulWidget {
  final CardItem card;

  const CardDetailPage({Key? key, required this.card}) : super(key: key);

  @override
  _CardDetailPageState createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late ScrollController _scrollController;
  bool _showCloseButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 100 && !_showCloseButton) {
      setState(() => _showCloseButton = true);
    } else if (_scrollController.position.pixels <= 100 && _showCloseButton) {
      setState(() => _showCloseButton = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color closeButtonColor;
    if (widget.card.color == const Color(0xFFFF5252)) {
      closeButtonColor = Colors.red;
    } else if (widget.card.color == const Color(0xFFFFC107)) {
      closeButtonColor = Colors.brown;
    } else {
      closeButtonColor = Colors.green;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header or Image with close button
                    if (widget.card.imageUrl != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Image.asset(
                                widget.card.imageUrl!,
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 300,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.card.imageUrl ==
                                  'assets/images/monkey.jpg')
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Text(
                                    'Monkeys',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 4,
                                          offset: const Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.card.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (widget.card.subtitle.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      widget.card.subtitle,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(color: widget.card.color),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 16,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.card.title,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (widget.card.subtitle.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        widget.card.subtitle,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.card.imageUrl == null)
                            const SizedBox(height: 16),
                          Text(
                            widget.card.detailText ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Close button at bottom - only visible when scrolled
            Visibility(
              visible: _showCloseButton,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: closeButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
