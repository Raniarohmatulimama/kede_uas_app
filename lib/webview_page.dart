import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'user/user_page.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;
  bool _isPageReady = false;
  bool _isSearching = false;
  Timer? _readyTimer;
  int _readyAttempts = 0;
  final TextEditingController _searchController = TextEditingController();

  final String baseUrl =
      'https://kede.dexignzone.com/xhtml/index.html#!/elements/';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async => await _forceKillPreloader(),
          onProgress: (progress) async {
            if (progress > 20) await _forceKillPreloader();
          },
          onPageFinished: (url) async => await _forceKillPreloader(),
          onNavigationRequest: (request) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(baseUrl));

    _readyTimer = Timer.periodic(const Duration(milliseconds: 300), (t) async {
      _readyAttempts++;
      try {
        final result = await _controller.runJavaScriptReturningResult(r"""
          (function(){
            try{
              const sel = '.preloader, .splash, #preloader, .page-loader, .loading-area';
              const els = document.querySelectorAll(sel);
              let preloaderVisible = false;
              if(els.length > 0){
                for(let i=0;i<els.length;i++){
                  const e = els[i];
                  const s = window.getComputedStyle(e);
                  if(s && s.display !== 'none' && s.visibility !== 'hidden' && s.opacity !== '0') { preloaderVisible = true; break; }
                }
              }
              const bodyText = (document.body && document.body.innerText) ? document.body.innerText.trim() : '';
              const contentReady = (!preloaderVisible) && (bodyText.length > 200);
              return contentReady;
            } catch(e) { return false; }
          })()
        """);

        final ok =
            result == true ||
            result == 'true' ||
            result == 'True' ||
            result == '1';
        if (ok) {
          setState(() => _isPageReady = true);
          t.cancel();
        }
      } catch (_) {}

      if (_readyAttempts > 50) {
        _readyTimer?.cancel();
        if (mounted) setState(() => _isPageReady = true);
      }
    });
  }

  Future<void> _forceKillPreloader() async {
    const js = r"""
      (function() {
        try {
          const selectors = [
            '.preloader', '.splash', '#preloader', '.page-loader', '.loading-area', 
            '.loader', '.loading', '.spinner', '[class*="loader"]', '[id*="loader"]'
          ];
          const headerSelectors = [
            'header', '.navbar', '.page-navbar', '.navbar-inner', 
            '.page-header', '.toolbar-top', '.view .navbar'
          ];
          const hideElements = (arr) => {
            arr.forEach(sel => {
              document.querySelectorAll(sel).forEach(el => {
                el.style.display = 'none';
                el.style.visibility = 'hidden';
                el.remove();
              });
            });
          };
          hideElements(selectors);
          hideElements(headerSelectors);
          document.body.style.marginTop = '0';
          document.body.style.paddingTop = '0';
          document.documentElement.style.scrollBehavior = 'auto';
        } catch (e) { console.log('forceKillPreloader error', e); }
      })();
    """;
    await _controller.runJavaScript(js);
  }

  Future<bool> _handleBack() async {
    final currentUrl = await _controller.currentUrl();
    if (currentUrl != null && !currentUrl.contains('/elements/')) {
      await _controller.loadRequest(Uri.parse(baseUrl));
      return false;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
    return false;
  }

  Future<void> _searchInWeb(String query) async {
    if (query.isEmpty) {
      await _controller.runJavaScript(r"""
        (function(){
          document.querySelectorAll('.flutterSearchHighlight').forEach(el=>{
            el.style.backgroundColor = '';
            el.classList.remove('flutterSearchHighlight');
          });
        })();
      """);
      return;
    }

    final escaped = query.replaceAll("'", "\\'");
    await _controller.runJavaScript("""
      (function(){
        document.querySelectorAll('.flutterSearchHighlight').forEach(el=>{
          el.style.backgroundColor = '';
          el.classList.remove('flutterSearchHighlight');
        });
        const bodyTextNodes = [];
        const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
        while(walker.nextNode()) bodyTextNodes.push(walker.currentNode);
        bodyTextNodes.forEach(node=>{
          if(node.nodeValue.toLowerCase().includes('${escaped.toLowerCase()}')){
            const span = document.createElement('span');
            span.textContent = node.nodeValue;
            span.innerHTML = span.innerHTML.replace(new RegExp('${escaped}', 'gi'), m => '<mark class="flutterSearchHighlight" style="background:yellow;">'+m+'</mark>');
            const frag = document.createRange().createContextualFragment(span.innerHTML);
            node.parentNode.replaceChild(frag, node);
          }
        });
      })();
    """);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            color: const Color(0xFFE0E6FF),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                        ),
                        onPressed: _handleBack,
                      ),
                      if (_isSearching)
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Search components',
                              border: InputBorder.none,
                            ),
                            onChanged: _searchInWeb,
                          ),
                        )
                      else
                        const Spacer(),
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isSearching) {
                              _isSearching = false;
                              _searchController.clear();
                              _searchInWeb('');
                            } else {
                              _isSearching = true;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (!_isSearching)
                    const Text(
                      'Framework7',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (!_isPageReady)
                Positioned.fill(
                  child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _readyTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
