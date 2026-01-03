import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'config/firebase_config.dart';
import 'config/cloudinary_config.dart';
import 'services/auth_service.dart';
import 'sign_in/sign_in_screen.dart';

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({Key? key}) : super(key: key);

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  final TextEditingController _searchIdController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _searchIdController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Messages', style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Silakan login untuk mengirim pesan',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: const Color(0xFF4CB32B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search bar UI (logic tidak diubah)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search job here…',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(FirebaseConfig.chatsCollection)
                  .where('participants', arrayContains: currentUserId)
                  .orderBy('updatedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada percakapan. Tambahkan teman dengan ID mereka.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final chats = snapshot.data!.docs;
                final query = _searchController.text.trim().toLowerCase();
                final filteredChats = query.isEmpty
                    ? chats
                    : chats.where((c) {
                        final data = c.data();
                        final participants = List<String>.from(
                          data['participants'] ?? <String>[],
                        );
                        final otherUserId = participants.firstWhere(
                          (id) => id != currentUserId,
                          orElse: () => currentUserId,
                        );
                        final participantNames = Map<String, dynamic>.from(
                          data['participantNames'] ?? {},
                        );
                        final otherName =
                            (participantNames[otherUserId] ?? 'Teman')
                                as String;
                        final lastMessage =
                            (data['lastMessage'] ?? '') as String;
                        return otherName.toLowerCase().contains(query) ||
                            lastMessage.toLowerCase().contains(query);
                      }).toList();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 100),
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    final data = chat.data();
                    final participants = List<String>.from(
                      data['participants'] ?? <String>[],
                    );
                    final otherUserId = participants.firstWhere(
                      (id) => id != currentUserId,
                      orElse: () => currentUserId,
                    );
                    final participantNames = Map<String, dynamic>.from(
                      data['participantNames'] ?? {},
                    );
                    final participantPhotos = Map<String, dynamic>.from(
                      data['participantPhotos'] ?? {},
                    );
                    final otherName =
                        (participantNames[otherUserId] ?? 'Teman') as String;
                    final otherPhoto =
                        participantPhotos[otherUserId] as String?;
                    final lastMessage = (data['lastMessage'] ?? '') as String;
                    final lastSenderId = data['lastSenderId'] as String?;
                    final isMine =
                        lastSenderId != null &&
                        AuthService.currentUserId != null &&
                        lastSenderId == AuthService.currentUserId;
                    final isRead = (data['isRead'] as bool?) ?? false;
                    final ts = data['updatedAt'];
                    final lastTime = ts is Timestamp
                        ? DateFormat('HH:mm').format(ts.toDate())
                        : '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  chatId: chat.id,
                                  otherUserId: otherUserId,
                                  otherUserName: otherName,
                                  otherUserPhoto: otherPhoto,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: otherPhoto != null
                                      ? NetworkImage(otherPhoto)
                                      : null,
                                  child: otherPhoto == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              otherName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lastMessage.isEmpty
                                                  ? 'Tap untuk mulai chat'
                                                  : lastMessage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                lastTime,
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              if (isMine)
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.check,
                                                      size: 14,
                                                      color: isRead
                                                          ? const Color(
                                                              0xFF4CB32B,
                                                            )
                                                          : Colors
                                                                .grey
                                                                .shade500,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      isRead
                                                          ? 'Read'
                                                          : 'Pending',
                                                      style: TextStyle(
                                                        color: isRead
                                                            ? const Color(
                                                                0xFF4CB32B,
                                                              )
                                                            : Colors
                                                                  .grey
                                                                  .shade600,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFriendDialog() async {
    _searchIdController.clear();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8F5E9), Color(0xFFF7FDF7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4CB32B).withOpacity(0.12),
                        ),
                      ),
                      child: const Text(
                        'Tambah Teman',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchIdController,
                  autofocus: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Masukkan User ID',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    prefixIcon: const Icon(
                      Icons.person_add_alt,
                      color: Color(0xFF4CB32B),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.paste, color: Color(0xFF4CB32B)),
                      onPressed: () async {
                        final data = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );
                        if (data != null && data.text != null) {
                          _searchIdController.text = data.text!;
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF4CB32B),
                        width: 1.4,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Salin User ID dari profil teman, lalu tempel di sini untuk memulai chat.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _processing
                            ? null
                            : () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          foregroundColor: Colors.grey.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _processing
                            ? null
                            : () async {
                                final id = _searchIdController.text.trim();
                                if (id.isEmpty) return;
                                setState(() => _processing = true);
                                await _startChatWithUser(
                                  id,
                                  addDialogContext: dialogContext,
                                );
                                if (mounted) {
                                  setState(() => _processing = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CB32B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _processing
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Cari',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startChatWithUser(
    String targetId, {
    BuildContext? addDialogContext,
  }) async {
    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan login dulu')));
      return;
    }

    if (targetId == currentUserId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa menambahkan diri sendiri')),
      );
      return;
    }

    try {
      print('[Chat] Mencari user: $targetId');

      // Validasi bahwa ID tidak kosong
      if (targetId.isEmpty || targetId.length < 10) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User ID tidak valid')));
        return;
      }

      // Fetch user data dari Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection(FirebaseConfig.usersCollection)
          .doc(targetId)
          .get();

      if (!userDoc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User tidak ditemukan')));
        return;
      }

      final userData = userDoc.data()!;
      final targetName =
          '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'
              .trim();
      final targetPhoto =
          userData['profile_photo_path'] ?? userData['profile_photo_url'];

      if (!mounted) return;

      // Tampilkan dialog konfirmasi dengan profile user (UI diperbarui)
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8F5E9), Color(0xFFF7FDF7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4CB32B).withOpacity(0.12),
                          ),
                        ),
                        child: const Text(
                          'Tambah Teman',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    backgroundImage: targetPhoto != null
                        ? NetworkImage(targetPhoto)
                        : null,
                    child: targetPhoto == null
                        ? const Icon(Icons.person, size: 42, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    targetName.isEmpty ? 'User' : targetName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mulai chat dengan pengguna ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            foregroundColor: Colors.grey.shade800,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Tutup dialog profil lalu dialog input ID
                            Navigator.of(dialogContext).pop(true);
                            if (addDialogContext != null) {
                              Navigator.of(addDialogContext).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CB32B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Mulai Chat',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (confirm != true || !mounted) return;

      final chatId = _composeChatId(currentUserId, targetId);
      final chatRef = FirebaseFirestore.instance
          .collection(FirebaseConfig.chatsCollection)
          .doc(chatId);

      // Ambil nama dari local cache (profile user sendiri)
      final myName = await AuthService.getFullName();
      final myPhoto = await AuthService.getPhoto();

      print('[Chat] Membuat chat: $chatId');
      print('[Chat] Participants: [$currentUserId, $targetId]');

      // Buat/update chat dengan data user yang sudah di-fetch
      await chatRef.set({
        'participants': [currentUserId, targetId],
        'participantNames': {
          currentUserId: myName.isEmpty ? 'Saya' : myName,
          targetId: targetName.isEmpty ? 'User' : targetName,
        },
        'participantPhotos': {currentUserId: myPhoto, targetId: targetPhoto},
        'lastMessage': 'Mulai chat',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('[Chat] Chat berhasil dibuat');

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            chatId: chatId,
            otherUserId: targetId,
            otherUserName: targetName.isEmpty ? 'User' : targetName,
            otherUserPhoto: targetPhoto,
          ),
        ),
      );
    } catch (e) {
      print('[Chat] Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memulai chat:\n$e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _composeChatId(String a, String b) {
    final pair = [a, b]..sort();
    return '${pair[0]}_${pair[1]}';
  }
}

class ChatPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;

  const ChatPage({
    Key? key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  void _markAsRead() async {
    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) return;

    try {
      final chatRef = FirebaseFirestore.instance
          .collection(FirebaseConfig.chatsCollection)
          .doc(widget.chatId);

      final chatDoc = await chatRef.get();
      if (chatDoc.exists) {
        final chatData = chatDoc.data();
        final lastSenderId = chatData?['lastSenderId'];

        // Only mark as read if the last sender was NOT the current user
        if (lastSenderId != null && lastSenderId != currentUserId) {
          await chatRef.update({'isRead': true});
        }
      }
    } catch (e) {
      // Silent fail - not critical
      debugPrint('Error marking chat as read: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(FirebaseConfig.chatsCollection)
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data();
                    final currentTs = msg['createdAt'];

                    // Check if we need to show date header
                    bool showDateHeader = false;
                    if (index == messages.length - 1) {
                      // Always show for the first (oldest) message
                      showDateHeader = true;
                    } else {
                      // Check if date changed from next message
                      final nextMsg = messages[index + 1].data();
                      final nextTs = nextMsg['createdAt'];
                      if (currentTs is Timestamp && nextTs is Timestamp) {
                        final currentDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(currentTs.toDate());
                        final nextDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(nextTs.toDate());
                        if (currentDate != nextDate) {
                          showDateHeader = true;
                        }
                      }
                    }

                    return Column(
                      children: [
                        if (showDateHeader && currentTs is Timestamp)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  DateFormat(
                                    'EEEE, MMM d, HH:mm',
                                  ).format(currentTs.toDate()),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        _buildMessageBubble(msg),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final currentUserId = AuthService.currentUserId;
    final senderId = message['senderId'] as String?;
    final isMe = senderId == currentUserId;
    final text = (message['text'] ?? '') as String;
    final imageUrl = message['imageUrl'] as String?;
    final ts = message['createdAt'];
    final time = ts is Timestamp ? DateFormat('HH:mm').format(ts.toDate()) : '';

    if (isMe) {
      // Message from current user - right aligned
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: 180,
                        height: 190,
                      ),
                    ),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CB32B),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CB32B).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Message from other user - left aligned with profile
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: widget.otherUserPhoto != null
                      ? NetworkImage(widget.otherUserPhoto!)
                      : null,
                  child: widget.otherUserPhoto == null
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          widget.otherUserName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 180,
                              height: 180,
                            ),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _uploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.camera_alt,
                        color: Colors.grey.shade700,
                        size: 22,
                      ),
                onPressed: _uploading ? null : _pickAndSendImage,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4CB32B),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sending ? null : _sendTextMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    await _sendMessage(text: text);
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final file = File(picked.path);

      // Upload ke Cloudinary menggunakan upload preset
      print('[Chat] Mulai upload gambar ke Cloudinary...');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(CloudinaryConfig.uploadUrl),
      );
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      print('[Chat] Upload response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw 'Upload ke Cloudinary gagal: ${response.statusCode} - $errorBody';
      }

      final responseData = jsonDecode(await response.stream.bytesToString());
      final imageUrl = responseData['secure_url'] ?? responseData['url'];

      print('[Chat] Image uploaded to Cloudinary: $imageUrl');
      await _sendMessage(imageUrl: imageUrl);
    } catch (e) {
      print('[Chat] Image upload error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim gambar: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _sendMessage({String? text, String? imageUrl}) async {
    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan login dulu')));
      return;
    }

    setState(() => _sending = true);
    try {
      final chatRef = FirebaseFirestore.instance
          .collection(FirebaseConfig.chatsCollection)
          .doc(widget.chatId);

      await chatRef.collection('messages').add({
        'senderId': currentUserId,
        'text': text ?? '',
        'imageUrl': imageUrl ?? '',
        // Use client timestamp so date separators reflect the day the user sent the message
        'createdAt': Timestamp.now(),
      });

      final lastMessageText = (imageUrl != null && imageUrl.isNotEmpty)
          ? '[Foto]'
          : (text ?? '');

      await chatRef.set({
        'lastMessage': lastMessageText,
        'lastSenderId': currentUserId,
        'isRead': false,
        'updatedAt': FieldValue.serverTimestamp(),
        'participantNames': {currentUserId: await AuthService.getFullName()},
      }, SetOptions(merge: true));

      _messageController.clear();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
