import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  String wsUrl;
  WebSocketChannel? _channel;
  final StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();

  WebSocketClient({this.wsUrl = 'ws://localhost:8080/'});

  Stream<dynamic> get stream => _controller.stream;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen(
        (data) {
          _controller.add(data);
        },
        onError: (error) {
          _controller.addError(error);
        },
        onDone: () {
          // Stream completed
        },
      );
    } catch (e) {
      _controller.addError(e);
    }
  }

  void send(dynamic data) {
    _channel?.sink.add(data);
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
