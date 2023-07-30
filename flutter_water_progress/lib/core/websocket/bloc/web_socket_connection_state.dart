import 'package:equatable/equatable.dart';

import '../models/connection_status.dart';

class WebSocketConnectionState extends Equatable {
  final String? gateway;
  final int port;
  final String? address;
  final ConnectionStatus connectionStatus;
  final SearchingStatus searchingStatus;

  const WebSocketConnectionState(
      {this.address,
      this.gateway,
      this.port = 8080,
      this.searchingStatus = SearchingStatus.NOT_FOUND,
      this.connectionStatus = ConnectionStatus.DISCONNECTED});

  String toWebSocketUrl() => 'ws://$address:$port';

  WebSocketConnectionState copyWith(
      {String? gateway,
      int? port,
      String? address,
      bool? connected,
      ConnectionStatus? connectionStatus,
      SearchingStatus? searchingStatus}) {
    return WebSocketConnectionState(
        gateway: gateway ?? this.gateway,
        port: port ?? this.port,
        address: address ?? this.address,
        searchingStatus: searchingStatus ?? this.searchingStatus,
        connectionStatus: connectionStatus ?? this.connectionStatus);
  }

  @override
  List<Object> get props => [port, connectionStatus, searchingStatus];
}

class EspResponse extends WebSocketConnectionState {
  final dynamic response;
  const EspResponse(this.response);
  @override
  List<Object> get props => [response];
}

class EspRequest extends WebSocketConnectionState {
  final dynamic request;
  const EspRequest(this.request);
  @override
  List<Object> get props => [request];
}

class BatteryIndicator extends WebSocketConnectionState {
  final dynamic batteryLevel;
  const BatteryIndicator(this.batteryLevel);
  @override
  List<Object> get props => [batteryLevel];
}
