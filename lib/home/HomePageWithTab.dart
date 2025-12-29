import 'package:flutter/material.dart';
import 'HomePage.dart';

class HomePageWithTab extends StatelessWidget {
  final int selectedIndex;
  const HomePageWithTab({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomePageWithTabStateful(selectedIndex: selectedIndex);
  }
}

class HomePageWithTabStateful extends StatefulWidget {
  final int selectedIndex;
  const HomePageWithTabStateful({Key? key, this.selectedIndex = 0})
    : super(key: key);

  @override
  State<HomePageWithTabStateful> createState() =>
      _HomePageWithTabStatefulState();
}

class _HomePageWithTabStatefulState extends State<HomePageWithTabStateful> {
  @override
  Widget build(BuildContext context) {
    return HomePageWithInitialTab(selectedIndex: widget.selectedIndex);
  }
}

class HomePageWithInitialTab extends HomePage {
  final int selectedIndex;
  const HomePageWithInitialTab({Key? key, this.selectedIndex = 0})
    : super(key: key);

  @override
  State<HomePage> createState() => _HomePageWithInitialTabState();
}

class _HomePageWithInitialTabState extends _HomePageState {
  @override
  void initState() {
    super.initState();
    _selectedIndex = (widget as HomePageWithInitialTab).selectedIndex;
  }
}
