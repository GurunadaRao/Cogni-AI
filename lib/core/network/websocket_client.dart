import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class AppWebSocketClient {
  String wsUrl;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  WsConnectionState _connectionState = WsConnectionState.disconnected;
  final StreamController<WsConnectionState> _stateController = StreamController<WsConnectionState>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();

  bool _isDisposed = false;
  bool _manualDisconnect = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  AppWebSocketClient({required this.wsUrl});

  WsConnectionState get connectionState => _connectionState;
  Stream<WsConnectionState> get stateStream => _stateController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect({String? overrideUrl}) {
    if (overrideUrl != null) {
      wsUrl = overrideUrl;
    }
    if (_connectionState == WsConnectionState.connected || _connectionState == WsConnectionState.connecting) {
      return;
    }
    _manualDisconnect = false;
    _updateState(WsConnectionState.connecting);

    try {
      final uri = Uri.parse(wsUrl);
      _channel = WebSocketChannel.connect(uri);
      
      _subscription = _channel!.stream.listen(
        (data) {
          if (_connectionState != WsConnectionState.connected) {
            _reconnectAttempts = 0;
            _updateState(WsConnectionState.connected);
          }
          try {
            final parsed = jsonDecode(data.toString());
            if (parsed is Map<String, dynamic>) {
              _messageController.add(parsed);
            }
          } catch (e) {
            _messageController.add({
              'type': 'error',
              'message': 'Malformed JSON received',
              'raw': data.toString(),
            });
          }
        },
        onError: (error) {
          _handleDisconnect(error: error);
        },
        onDone: () {
          _handleDisconnect();
        },
      );
    } catch (e) {
      _handleDisconnect(error: e);
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null && _connectionState == WsConnectionState.connected) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void _handleDisconnect({dynamic error}) {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;

    if (_manualDisconnect || _isDisposed) {
      _updateState(WsConnectionState.disconnected);
      return;
    }

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      _updateState(WsConnectionState.reconnecting);
      final delaySeconds = pow(2, _reconnectAttempts).toInt();
      Timer(Duration(seconds: delaySeconds), () {
        if (!_manualDisconnect && !_isDisposed) {
          connect();
        }
      });
    } else {
      _updateState(WsConnectionState.disconnected);
      _messageController.add({
        'type': 'connection.status',
        'status': 'reconnect_failed',
        'message': 'Max reconnection attempts reached.',
      });
    }
  }

  void disconnect() {
    _manualDisconnect = true;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _updateState(WsConnectionState.disconnected);
  }

  void _updateState(WsConnectionState state) {
    _connectionState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _stateController.close();
    _messageController.close();
  }
}
