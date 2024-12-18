import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chat_app/model/user.dart';
import 'package:chat_app/screens/home/chatpriv_screen.dart';
import 'package:chat_app/screens/home/components/utente_card.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  String username;
  HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late IO.Socket socket;
  List<User> utenti_classe = [];

  @override
  void initState() {
    super.initState();
    socket = SocketService().getSocket();
    _setupSocketListeners();
    socket.emit('register', widget.username);
  }

  void _setupSocketListeners() {
    socket.on('users', (data) {
      setState(() {
        List<String> nome_utente = List<String>.from(data);
        utenti_classe = nome_utente
            .where((username) => username != widget.username)
            .map((username) => User(username: username))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Utenti connessi al momento",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            ...utenti_classe.map(
              (user) => GestureDetector(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: UtenteCard(
                    title: user.username,
                    iconsSrc: user.iconSrc,
                    colorl: user.color,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatPriv(selectedUser: user.username),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
