import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_event.dart';
import 'package:flutter_water_progress/core/websocket/models/connection_status.dart';
import 'package:flutter_water_progress/core/websocket/network_util.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'web_socket_connection_state.dart';

class WebSocketConnectionBloc extends Bloc<WebSocketConnectionEvent, WebSocketConnectionState> {
  late WebSocketChannel _channel;
  //Yeah. Wrong use of states. but.. usina info says to me the sensor i will only get after weekend.
  static const initialState = WebSocketConnectionState();
  WebSocketConnectionBloc() : super(initialState) {
    Future<void> _connect(OnConnect event, Emitter<WebSocketConnectionState> emit) async {
      debugPrint("Auto run esp at the network ${state.gateway}.");
      emit(state.copyWith(connectionStatus: ConnectionStatus.CONNECTING, searchingStatus: SearchingStatus.SEARCHING));
      final networkUtil = NetworkUtil("192.168.0.1", 8080);
      debugPrint("pre esp searching");
      final addressEspFound = await networkUtil.findEspUrlOnNetwork();
      debugPrint("found $addressEspFound");
      try {
        if (addressEspFound == null) {
          debugPrint("cant be searched");
          emit(state.copyWith(
              connectionStatus: ConnectionStatus.DISCONNECTED, searchingStatus: SearchingStatus.NOT_FOUND));
          throw Exception("cant search for esp");
        }
        emit(state.copyWith(
            address: addressEspFound,
            connectionStatus: ConnectionStatus.CONNECTED,
            searchingStatus: SearchingStatus.FOUND));
        debugPrint("esp found at ${addressEspFound}");
        debugPrint("trying to connect");
        final url = state.toWebSocketUrl();
        _channel = WebSocketChannel.connect(Uri.parse(url));
        _channel.sink.add("hand");
        emit(state.copyWith(connected: true));
        await emit.onEach<dynamic>(_channel.stream, onData: (data) => add(OnEspResponse(data)));
      } on WebSocketChannelException catch (e) {
        emit(state.copyWith(connected: false));
      }
    }

    void _onReceiveMessage(
      OnEspResponse event,
      Emitter<WebSocketConnectionState> emit,
    ) {
      debugPrint("esp 8266 says ${event.response}");
    }

    void _onBatteryLevel(
      OnBatteryLevelChange event,
      Emitter<WebSocketConnectionState> emit,
    ) {
      debugPrint("esp 8266 says that the battery level is ${event.batteryLevel}");
    }

    void sendMessage(
      OnEspRequest event,
      Emitter<WebSocketConnectionState> emit,
    ) {
      _channel.sink.add(event.request);
      debugPrint("Sending ${event.request}");
    }

    on<OnConnect>(_connect);
    on<OnEspResponse>(_onReceiveMessage);
    on<OnBatteryLevelChange>(_onBatteryLevel);
  }
}
