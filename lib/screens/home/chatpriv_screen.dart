import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chat_app/services/socket_service.dart';

class ChatPriv extends StatefulWidget {
  final String selectedUser;

  ChatPriv({super.key, required this.selectedUser});

  @override
  State<ChatPriv> createState() => _ChatPrivState();
}

class _ChatPrivState extends State<ChatPriv> {
  late IO.Socket socket;
  Map<String, List<String>> messages = {}; // Messaggi privati
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    socket = SocketService().getSocket();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socket.on('message', (data) {
      String sender = data['sender'];
      String message = data['message'];
      setState(() {
        messages.putIfAbsent(sender, () => []).add(message);
      });
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      String message = _messageController.text.trim();
      socket.emit('private_message', {
        'recipient': widget.selectedUser,
        'message': message,
      });
      setState(() {
        messages
            .putIfAbsent(widget.selectedUser, () => [])
            .add("#123#: $message");
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.selectedUser),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context); // Torna alla schermata precedente
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages[widget.selectedUser]?.length ?? 0,
              itemBuilder: (context, index) {
                String message = messages[widget.selectedUser]![index];
                bool isSentByMe = message.contains('#123#: ');

                return Align(
                  alignment:
                      isSentByMe ? Alignment.topRight : Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSentByMe ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: isSentByMe
                              ? const Radius.circular(20)
                              : Radius.zero,
                          bottomRight: isSentByMe
                              ? Radius.zero
                              : const Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        isSentByMe
                            ? message.replaceFirst('#123#: ', '')
                            : message,
                        style: TextStyle(
                          color: isSentByMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Scrivi un messaggio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.off('message'); // Rimuovi listener per evitare memory leaks
    super.dispose();
  }
}
