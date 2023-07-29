import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_connection_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_connection_state.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_event.dart';
import 'package:flutter_water_progress/views/panel/panel_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WebSocketConnectionBloc, WebSocketConnectionState>(
      listener: (listenerContext, state) {
        if (state.connected) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PanelPage()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: FilledButton.tonal(
              onPressed: () {
                context.read<WebSocketConnectionBloc>().add(OnConnect());
              },
              child: const Text('Connect')),
        ),
      ),
    );
  }
}
