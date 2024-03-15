import 'package:flutter/material.dart';

import 'package:extended_tooltip/extended_tooltip.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extended ToolTip Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Extended ToolTip Example'),
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
  int value = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ExtendedToolTip(
              horizontalPosition: ExtendedTooltipPosition.left,
              message: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red,
                ),
                child: const Center(child: Text('My custom Message')),
              ),
              child: Text(
                'ExtendToolTip Example',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 30),
            const ExtendedToolTip(
                horizontalPosition: ExtendedTooltipPosition.right,
                message: CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person),
                ),
                child: Icon(Icons.person)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExtendedToolTip(
                  message: IconButton(
                    onPressed: () {
                      setState(() {
                        value++;
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                  child: Text('tooltip interaction $value'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
