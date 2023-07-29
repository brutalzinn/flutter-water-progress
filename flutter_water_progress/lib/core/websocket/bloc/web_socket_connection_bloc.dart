import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_event.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'web_socket_connection_state.dart';

class WebSocketConnectionBloc extends Bloc<WebSocketConnectionEvent, WebSocketConnectionState> {
  late WebSocketChannel _channel;
  static const initialState =
      WebSocketConnectionState(address: "192.168.0.81", gateway: "192.168.0.1", port: 8080, connected: false);

  WebSocketConnectionBloc() : super(initialState) {
    Future<void> _connect(OnConnect event, Emitter<WebSocketConnectionState> emit) async {
      final url = state.toUrl();
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel.sink.add("hand");
      final connected = _channel.closeReason == null;
      emit(state.copyWith(connected: connected));
      await emit.onEach<dynamic>(_channel.stream, onData: (data) => add(OnEspResponse(data)));
    }

    void _onReceiveMessage(
      OnEspResponse event,
      Emitter<WebSocketConnectionState> emit,
    ) {
      print("esp 8266 says ${event.response}");
    }

    void _onBatteryLevel(
      OnBatteryLevelChange event,
      Emitter<WebSocketConnectionState> emit,
    ) {
      print("esp 8266 says that the battery level is ${event.batteryLevel}");
    }

    void sendMessage(
      OnEspRequest event,
      Emitter<WebSocketConnectionState> emit,
    ) {
      _channel.sink.add(event.request);
      print("Sending ${event.request}");
    }

    on<OnConnect>(_connect);
    on<OnEspResponse>(_onReceiveMessage);
    on<OnBatteryLevelChange>(_onBatteryLevel);
  }
}
