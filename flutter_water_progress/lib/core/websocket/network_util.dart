import 'dart:async';
import 'dart:isolate';
import 'package:http/http.dart' as http;

class NetworkUtil {
  final String gateway;
  final int port;

  /// like 192.168.0.1
  String _gatewayIp = "";

  /// like 192.168.0.{possible_point}
  NetworkUtil(this.gateway, this.port);

  Future<String?> findEspUrlOnNetwork() async {
    final gatewayIpSplit = gateway.split('.');
    gatewayIpSplit.removeLast();
    _gatewayIp = gatewayIpSplit.join(".");
    List<String> ipAddresses = [];
    for (var i = 1; i < 255; i++) {
      final ip = _gatewayIp + ".$i";
      ipAddresses.add(ip);
    }

    ///goroutines its less complicated that implement low level paralelism with dart
    /// thanks chat gpt for really help it.
    /// no. this is not the same that we already done with simple robot and web socket connection.
    /// The flutter performace analyzer its ok to use with this at ios emulator.
    final completer = Completer<String?>();
    void handleResponse(String? ipAddress) {
      if (!completer.isCompleted && ipAddress != null) {
        completer.complete(ipAddress);
      }
    }

    void cancelIsolates(List<Isolate> isolates) {
      for (final isolate in isolates) {
        isolate.kill(priority: Isolate.immediate);
      }
    }

    int completedIsolates = 0;
    final List<Isolate> isolates = [];
    for (final ipAddress in ipAddresses) {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(_performHttpGet, {'ipAddress': ipAddress, 'sendPort': receivePort.sendPort});
      isolates.add(isolate);
      receivePort.listen((message) {
        if (message is String) {
          handleResponse(message);
          cancelIsolates(isolates);
        } else {
          completedIsolates++;
          if (completedIsolates == ipAddresses.length && !completer.isCompleted) {
            completer.complete(null);
          }
        }
        receivePort.close();
      });
    }
    return completer.future;
  }

  void _performHttpGet(Map<String, dynamic> message) async {
    final String ipAddress = message['ipAddress'];
    final SendPort sendPort = message['sendPort'];
    final client = http.Client();
    try {
      final url = Uri.parse('http://$ipAddress:$port/ping');
      final response = await client.get(url);
      if (response.statusCode == 200) {
        sendPort.send(ipAddress);
      } else {
        sendPort.send(null);
      }
    } catch (e) {
      sendPort.send(null);
    } finally {
      client.close();
    }
  }
}
