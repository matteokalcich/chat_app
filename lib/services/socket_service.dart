import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    _connectToServer();
  }

  void _connectToServer() {
    socket = IO.io(
      'http://192.168.1.9:12345',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('Connesso al server');
    });

    socket.onDisconnect((_) {
      print('Disconnesso dal server');
    });
  }

  IO.Socket getSocket() {
    return socket;
  }
}
