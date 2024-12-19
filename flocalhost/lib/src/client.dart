import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';

class Client {
  //singleton
  static final Client _instance = Client._internal();
  factory Client() => _instance;
  Client._internal();

  static Socket? _socket;
  static BonsoirDiscovery? _discovery;

  static Future<void> autoStartClient({
    required String handShakeType,
    int? serverPort,
    required Function(String data) whenReceaveData,
    Duration? timeout,
  }) async {
    BonsoirDiscovery discovery = BonsoirDiscovery(type: handShakeType);
    await discovery.ready;
    // If you want to listen to the discovery :
    // discovery.eventStream?.asBroadcastStream().listen(
    discovery.eventStream!.listen(
      (event) async {
        if (event.service == null) return;
        // `eventStream` is not null as the discovery instance is "ready" !
        if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
          // Should be called when the user wants to connect to this service.
          await event.service!.resolve(discovery.serviceResolver);
          //
        } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
          if (event.service!.attributes['IP'] != null && _socket == null) {
            try {
              _socket = await connectToServer(
                port: serverPort ?? int.tryParse(event.service!.attributes['PORT']!)!,
                host: event.service!.attributes['IP']!,
                timeout: timeout,
              );
              _socket?.listen(
                (data) {
                  whenReceaveData.call(utf8.decode(data));
                  // whenReceaveData.call(utf8.decode(data));
                },
                onError: (error) {
                  log("Client: $error");
                  _socket?.destroy();
                  _socket = null;
                },
                onDone: () {
                  log('Client: Server left.');
                  _socket?.destroy();
                  _socket = null;
                },
              );
            } catch (e) {
              discovery.stop();
              _socket?.destroy();
              _socket = null;
              log('Error to connect: $e');
              rethrow;
            }
          }
        } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
          // print('startClient: Service discoveryServiceResolved : ${event.service?.name}');
        }
      },
      onError: (error) {
        log("Client: $error");
      },
      onDone: () {
        log('Client: Done');
      },
    );
    //
    await discovery.start();
  }

  ///stabilish the connection
  static Future<Socket?> connectToServer({
    required int port,
    required String host,
    Duration? timeout,
  }) async {
    _socket = await Socket.connect(host, port, timeout: timeout);
    return _socket;
  }

  ///send message to the server
  static void sendMessage({required String message}) async {
    if (_socket == null) {
      log('No connection with the server');
      return;
    }
    _socket?.write(String.fromCharCodes(message.codeUnits));
  }

  ///close the connection with the server
  static Future<void> closeConnection() async {
    // await _socket?.close();
    _socket?.destroy();
    _socket = null;
    await _discovery?.stop();
  }
}
