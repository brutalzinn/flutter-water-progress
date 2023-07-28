
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_progress/core/websocket/bloc/web_socket_connection_bloc.dart';

import 'views/home/home_view.dart';
import 'views/panel/panel_view.dart';

void main() {
  runApp(BlocProvider(
    create: (_) => WebSocketConnectionBloc(),
    child: MaterialApp(
      routes: {
        '/': (context) => const HomePage(),
        '/panel': (context) => const PanelPage()
      },
    ),
  ));
}