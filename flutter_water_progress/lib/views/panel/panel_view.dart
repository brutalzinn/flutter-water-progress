import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_connection_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_connection_state.dart';

class PanelPage extends StatelessWidget {
  const PanelPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WebSocketConnectionBloc, WebSocketConnectionState>(builder: (blocContext, state) {
        if (state.connected) {
          return Column(children: [
            Text("Connected: ${state.connected}"),
            Text("Teste message"),
          ]);
        }
        return Text("No connected.");
      }),
    );
  }
}
