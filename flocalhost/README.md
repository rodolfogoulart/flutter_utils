An amazing or not Auto Connect to your localhost devices. This package uses bonsoir and socket to achieve this.

bonsoir gives the handshake, allowing to broadcast your device and the socket is used to connect and send data between devices.

you can use this package to sync between devices on the same network

## Features

*Auto Connect*
 * Check for devices on network and auto connect to the server
*Send Data*

*Server side*
*Client side*

## Getting started

check the requisits of bonsoir to proper configure the handshake

## Usage

Check the example `/example` folder for more detail example.

```dart
//you can start the server as simple
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
    );

```

```dart
    //send messages
    Server.sendMessage(controllerSendMessage.text);
```

```dart
//you can start the client as simple

await Client.autoStartClient(
  handShakeType: controllerType.text,
  // serverPort: int.parse(controllerPort.text),
  whenReceaveData: (message) {
    setState(() {
      messages.add(message);
    });
  });

```

```dart
  //send message to the server
  Client.sendMessage(message: controllerSendMessage.text);
```

## Additional information

This package is made using bonsoir, socket and network_info_plus to get the local ip
the intent of this package is to create a simple localhost connection automatically, this way you can send data between devices. 

note that all data is convert to utf8 enconded

this package handle multiple connections.

the server send the message to all the clients that are listening

* **Only Tested on Windows and Android**