import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_connection_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_connection_state.dart';

class PanelPage extends StatelessWidget {
  const PanelPage({super.key});
  @override
  Widget build(BuildContext context) {
    ///put web view to show esp 32 cam here
    return Scaffold(body:
        BlocBuilder<WebSocketConnectionBloc, WebSocketConnectionState>(
            builder: (context, state) {
      return Column(children: [
        Text("Water level ( Weight of plate ): ${state.connected}"),
        const Text("This is the panel that will show the water level weight pressure plate."),
      ]);
    }));
  }
}
