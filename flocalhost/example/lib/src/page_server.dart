import 'dart:io';

import 'package:flocalhost/flocalhost.dart';
import 'package:flutter/material.dart';

class PageServer extends StatefulWidget {
  const PageServer({super.key});

  @override
  State<PageServer> createState() => _PageServerState();
}

class _PageServerState extends State<PageServer> {
  final controllerName = TextEditingController(text: 'MyWonderfulServer');
  final controllerType = TextEditingController(text: '_myapp._tcp');
  final controllerPort = TextEditingController(text: '8080');
  final controllerSendMessage = TextEditingController();

  Socket? client;

  List<String> messages = [];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size / 2;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text('Server', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          SizedBox(
            width: size.width * 0.8,
            child: TextFormField(
                controller: controllerName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name of the service',
                )),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                    controller: controllerType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type of the service',
                    )),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: size.width * 0.2,
                child: TextFormField(
                    controller: controllerPort,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Port of the server',
                    )),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            // mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    messages = [];
                    //
                    Server.startConnection(
                      handShakeType: controllerType.text,
                      handShakeName: controllerName.text,
                      portSoket: int.parse(controllerPort.text),
                      whenConnected: (client) {
                        this.client = client;
                        //you can send some handshake to the client
                        client.write('Hello from server!');
                        client.write('you are connected from ${client.remoteAddress.address}:${client.port}');
                        //...
                      },
                      whenReceaveData: (client, message) {
                        setState(() {
                          messages.add(message);
                        });
                      },
                    );
                  },
                  child: const Text('Start Server')),
              const SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () {
                    Server.stopConnection();
                  },
                  child: const Text('Close Connection')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllerSendMessage,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Send message to the client',
                  ),
                  onFieldSubmitted: (value) {
                    Server.sendMessage(controllerSendMessage.text);
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  Server.sendMessage(controllerSendMessage.text);
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [...messages.map((e) => Text(e))],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
