
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final _ctrl = TextEditingController();

  final _msgs = <Map<String, dynamic>>[
    {
      'me': false,
      'text':
          "Hi! I'm the Skintel ChatBot. How can I help with your skin today?"
    }
  ];

  bool _loading = false;

  // Send message to Skintel AI
  Future<void> _send() async {
    final t = _ctrl.text.trim();

    if (t.isEmpty || _loading) return;

    setState(() {
      _msgs.add({
        'me': true,
        'text': t,
      });
      _loading = true;
    });

    _ctrl.clear();

    try {
      // Get AI response from Supabase Edge Function
      final reply = await ApiService().sendChatMessage(t);

      if (!mounted) return;

      setState(() {
        _msgs.add({
          'me': false,
          'text': reply,
        });
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _msgs.add({
          'me': false,
          'text': 'AI Error: $e',
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                final me = m['me'] as bool;

                return Align(
                  alignment: me
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      maxWidth: 280,
                    ),
                    decoration: BoxDecoration(
                      color: me
                          ? Colors.black
                          : const Color(0xFFF5EFEC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      m['text'].toString(),
                      style: TextStyle(
                        color: me ? Colors.white : Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'typing...',
                style: TextStyle(fontSize: 11),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        filled: true,
                        fillColor: const Color(0xFFF5EFEC),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: IconButton(
                      onPressed: _loading ? null : _send,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
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