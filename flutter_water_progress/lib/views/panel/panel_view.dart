import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_connection_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_connection_state.dart';
import 'package:flutter_water_progress/core/websocket/models/connection_status.dart';

class PanelPage extends StatelessWidget {
  const PanelPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<WebSocketConnectionBloc, WebSocketConnectionState>(builder: (blocContext, state) {
          if (state.searchingStatus == SearchingStatus.SEARCHING) {
            return CircularProgressIndicator();
          }
          return Text("Connected: ${state.connectionStatus.name}");
        }),
      ),
    );
  }
}
