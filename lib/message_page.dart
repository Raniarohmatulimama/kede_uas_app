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
      title: 'Messages App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MessagesListPage(),
    );
  }
}

class Message {
  final String name;
  final String message;
  final String time;
  final String status;
  final String avatarPath;

  Message({
    required this.name,
    required this.message,
    required this.time,
    required this.status,
    required this.avatarPath,
  });
}

class MessagesListPage extends StatelessWidget {
  const MessagesListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messages = [
      Message(
        name: 'Sam Verdinand',
        message: 'OK. Lorem ipsum dolor sect...',
        time: '2m ago',
        status: 'Read',
        avatarPath: 'assets/images/1.jpg',
      ),
      Message(
        name: 'Freddie Ronan',
        message: 'Roger that sir, thankyou',
        time: '2m ago',
        status: 'Pending',
        avatarPath: 'assets/images/2.jpg',
      ),
      Message(
        name: 'Ethan Jacoby',
        message: 'Lorem ipsum dolor',
        time: '2m ago',
        status: 'Read',
        avatarPath: 'assets/images/3.jpg',
      ),
      Message(
        name: 'Alfie Mason',
        message: 'Lorem ipsum dolor sect...',
        time: '2m ago',
        status: 'Pending',
        avatarPath: 'assets/images/4.jpg',
      ),
      Message(
        name: 'Archie Parker',
        message: 'OK. Lorem ipsum dolor sect...',
        time: '2m ago',
        status: '',
        avatarPath: 'assets/images/5.jpg',
      ),
      Message(
        name: 'Sam Verdinand',
        message: 'OK. Lorem ipsum dolor sect...',
        time: '2m ago',
        status: 'Read',
        avatarPath: 'assets/images/6.jpg',
      ),
      Message(
        name: 'Isaac Banford',
        message: 'Roger that sir, thankyou',
        time: '2m ago',
        status: 'Pending',
        avatarPath: 'assets/images/6.jpg',
      ),
      Message(
        name: 'Henry Hunter',
        message: 'Lorem ipsum dolor',
        time: '2m ago',
        status: 'Read',
        avatarPath: 'assets/images/7.jpg',
      ),
      Message(
        name: 'Harry Parker',
        message: 'Lorem ipsum dolor sect...',
        time: '2m ago',
        status: 'Pending',
        avatarPath: 'assets/images/8.jpg',
      ),
      Message(
        name: 'George Carson',
        message: 'Lorem ipsum dolor sect...',
        time: '2m ago',
        status: '',
        avatarPath: 'assets/images/5.jpg',
      ),
    ];

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
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search job here...',
                hintStyle: TextStyle(color: Colors.grey[800], fontSize: 16),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          name: message.name,
                          avatar: message.avatarPath,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage(message.avatarPath),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    message.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (message.status.isNotEmpty)
                                    Row(
                                      children: [
                                        Text(
                                          message.status,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: message.status == 'Read'
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.check,
                                          size: 14,
                                          color: message.status == 'Read'
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message.time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String name;
  final String avatar;

  const ChatPage({Key? key, required this.name, required this.avatar})
    : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _showGallery = false;

  // Local asset images
  final List<String> catImages = [
    'assets/images/cat1.jpg',
    'assets/images/cat2.jpg',
    'assets/images/cats3.jpg',
    'assets/images/cats4.jpg',
    'assets/images/cats5.jpg',
    'assets/images/cats6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Pesan awal
    _messages.addAll([
      ChatMessage(text: 'Hi, Kate', isMe: true, time: 'Sunday, Feb 9, 12:58'),
      ChatMessage(text: 'How are you?', isMe: true, time: ''),
      ChatMessage(
        text: 'Hi, I am good!',
        isMe: false,
        sender: 'Kate',
        time: '',
      ),
      ChatMessage(
        text: 'Hi there, I am also fine,\nthanks! And how are,\nyou?',
        isMe: false,
        sender: 'Blue Ninja',
        time: '',
      ),
      ChatMessage(
        text: 'Hey, Blue Ninja! Glad to see,\nyou ;)',
        isMe: true,
        time: '',
      ),
      ChatMessage(
        text: 'Hey, look, cutest kitten ever!',
        isMe: true,
        time: '',
        hasImage: true,
      ),
      ChatMessage(text: 'Nice!', isMe: false, sender: 'Kate', time: ''),
      ChatMessage(
        text: 'Like it very much!',
        isMe: false,
        sender: 'Kate',
        time: '',
      ),
      ChatMessage(
        text: 'Awesome!',
        isMe: false,
        sender: 'Blue Ninja',
        time: '',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, index);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final showTime = index == 0 && message.time.isNotEmpty;
    final showAvatar = !message.isMe;

    return Column(
      crossAxisAlignment: message.isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (showTime)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                message.time,
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: message.isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(
                  message.sender == 'Kate'
                      ? 'assets/images/people2.jpg'
                      : 'assets/images/people1.jpg',
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: message.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!message.isMe &&
                      message.sender.isNotEmpty &&
                      showAvatar &&
                      ((message.sender == 'Kate' &&
                              (index == 2 || index == 6 || index == 7)) ||
                          (message.sender == 'Blue Ninja' &&
                              (index == 3 || index == 8))))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 8),
                      child: Text(
                        message.sender,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: message.isMe ? Colors.green : Colors.grey[400],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  if (message.hasImage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/cat2.jpg',
                          width: 200,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showGallery)
          Container(
            height: 300,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _showGallery = !_showGallery;
                          });
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.grey),
                        onPressed: () {
                          if (_messageController.text.isNotEmpty) {
                            setState(() {
                              _messages.add(
                                ChatMessage(
                                  text: _messageController.text,
                                  isMe: true,
                                  time: '',
                                ),
                              );
                              _messageController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: catImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _messages.add(
                              ChatMessage(
                                text: 'Sent an image',
                                isMe: true,
                                time: '',
                                hasImage: true,
                              ),
                            );
                            _showGallery = false;
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            catImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        if (!_showGallery)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _showGallery = !_showGallery;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Message',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.grey),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        _messages.add(
                          ChatMessage(
                            text: _messageController.text,
                            isMe: true,
                            time: '',
                          ),
                        );
                        _messageController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String sender;
  final String time;
  final bool hasImage;

  ChatMessage({
    required this.text,
    required this.isMe,
    this.sender = '',
    this.time = '',
    this.hasImage = false,
  });
}
