import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:network_info_plus/network_info_plus.dart';

class Server {
  //singleton
  static final Server _instance = Server._internal();
  factory Server() => _instance;
  Server._internal();

  static ServerSocket? _serverSocket;
  static BonsoirBroadcast? _broadcast;
  // static Socket? _client;
  static final List<Socket> _clients = [];

  ///for [handShakeType] check the documentation: https://pub.dev/packages/bonsoir
  ///
  ///common use of [handShakeType]: _putherethenameofyourservice._tcp
  static startConnection({
    int portSoket = 8080,
    int handShakePort = 8081,
    String handShakeName = 'MyWonderfulServer',
    String handShakeType = '_myapp._tcp',
    Function(Socket client)? whenConnected,
    Function(Socket client, String message)? whenReceaveData,
  }) async {
    if (handShakeType == '_myapp._tcp') {
      log('\x1B[31mCHANGE THE NAME OF YOUR SERVICE IN THE [handShakeType] PARAMETER\x1B[3m');
    }
    _broadcast ??= await _startHandShake(port: handShakePort, type: handShakeType, name: handShakeName, portSocket: portSoket);
    _serverSocket ??= await _startSocket(port: portSoket);
    if (_serverSocket != null) {
      _listenServer(
        _serverSocket!,
        whenReceaveData: (client, message) {
          whenReceaveData?.call(client, message);
        },
        whenConnected: (client) {
          whenConnected?.call(client);
        },
      );
    }
  }

  static stopConnection() {
    _closeListen(_serverSocket);
    _broadcast?.stop();
    _broadcast = null;
    _serverSocket = null;
  }

  static sendMessage(String message) {
    for (var c in _clients) {
      try {
        c.write(String.fromCharCodes(message.codeUnits));
      } catch (e) {
        log('maybe the client is not connected: $e');
      }
    }
  }

  static Future<ServerSocket> _startSocket({required int port, String? customAdress}) async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    ServerSocket serverSocket = await ServerSocket.bind(customAdress ?? wifiIP ?? InternetAddress.anyIPv4, port);
    return serverSocket;
  }

  static void _listenServer(
    ServerSocket serverSocket, {
    required Function(Socket client) whenConnected,
    Function(Socket client, String message)? whenReceaveData,
  }) {
    serverSocket.listen(
      (Socket clientSocket) {
        log('Client connected.');
        // Add client to the list.
        clientSocket.listen(
          (data) {
            // String message = String.fromCharCodes(data);
            String message = utf8.decode(data);
            log('Received from client: $message');

            //callback
            whenReceaveData?.call(clientSocket, message);
            //
            // clientSocket.write('Hello from server! You said: $message');
          },
          onDone: () {
            clientSocket.destroy();
            log('Client left.');
            _clients.remove(clientSocket);
          },
          onError: (error) {
            clientSocket.destroy();
            _clients.remove(clientSocket);
            log("Server: $error");
          },
        );
        _clients.add(clientSocket);
        whenConnected.call(clientSocket);
        log('Client connected: ${clientSocket.remoteAddress}:${clientSocket.remotePort}');
        //
      },
      onError: (error) {
        log("Server: $error");
      },
      onDone: () {
        log('Server left.');
      },
    );
  }

  static void _closeListen(ServerSocket? serverSocket) {
    serverSocket?.close();
    for (var c in _clients) {
      c.close();
    }
    _clients.clear();
  }

  ///[type] _mywonderfulserver._tcp
  ///
  ///check the documentation: https://pub.dev/packages/bonsoir
  static Future<BonsoirBroadcast> _startHandShake({
    required int port,
    required String type,
    required name,
    required int portSocket,
  }) async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    BonsoirService service = BonsoirService(
      name: name,
      type: type,
      port: port,
      attributes: {
        'IP': wifiIP ?? InternetAddress.anyIPv4.address,
        'PORT': '$portSocket',
      },
    );

    BonsoirBroadcast broadcast = BonsoirBroadcast(service: service);

    broadcast = BonsoirBroadcast(service: service);
    await broadcast.ready;
    await broadcast.start();
    return broadcast;
  }
}
