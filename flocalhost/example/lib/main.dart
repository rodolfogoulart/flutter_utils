import 'package:example/src/page_client.dart';
import 'package:example/src/page_server.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auto Connect Localhost',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Auto Connect Localhost Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          //server
          SizedBox(width: MediaQuery.of(context).size.width / 2, height: MediaQuery.of(context).size.height, child: PageServer()),
          VerticalDivider(),
          //client
          Expanded(
            child: PageClient(),
          ),
        ],
      ),
    );
  }
}
