import 'dart:io';

import 'package:flocalhost/flocalhost.dart';
import 'package:flutter/material.dart';

class PageClient extends StatefulWidget {
  const PageClient({super.key});

  @override
  State<PageClient> createState() => _PageClientState();
}

class _PageClientState extends State<PageClient> {
  final controllerPort = TextEditingController(text: '8080');
  final controllerType = TextEditingController(text: '_myapp._tcp');
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
          Text('Client', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          SizedBox(
            width: size.width * 0.8,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                      controller: controllerType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Type of the service',
                      )),
                ),
                // const SizedBox(width: 20),
                // SizedBox(
                //   width: size.width * 0.2,
                //   child: TextFormField(
                //       controller: controllerPort,
                //       decoration: const InputDecoration(
                //         border: OutlineInputBorder(),
                //         labelText: 'Port of the server',
                //       )),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    messages = [];
                    await Client.autoStartClient(
                        handShakeType: controllerType.text,
                        // serverPort: int.parse(controllerPort.text),
                        whenReceaveData: (message) {
                          setState(() {
                            messages.add(message);
                          });
                        });
                  },
                  child: const Text('Auto Connect')),
              const SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () async {
                    await Client.closeConnection();
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
                    labelText: 'Send message to the server',
                  ),
                  onFieldSubmitted: (value) {
                    Client.sendMessage(message: controllerSendMessage.text);
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  Client.sendMessage(message: controllerSendMessage.text);
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
