import 'package:flutter/material.dart';

import 'package:a_dropdown/a_dropdown.dart';

void main() {
  runApp(const MainApp());
}

enum Division { at, nt }

class Books {
  String name;
  Division division;
  Books({
    required this.name,
    required this.division,
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Books> bibleBooks = [
      Books(name: 'Genesis', division: Division.at),
      Books(name: 'Exodos', division: Division.at),
      Books(name: 'Leviticos', division: Division.at),
      Books(name: 'Numeros', division: Division.at),
      Books(name: 'Deuteronomio', division: Division.at),
      Books(name: 'Mateus', division: Division.nt),
      Books(name: 'Marcos', division: Division.nt),
      Books(name: 'Lucas', division: Division.nt),
      Books(name: 'João', division: Division.nt),
      Books(name: 'Atos', division: Division.nt),
      Books(name: 'Romanos', division: Division.nt),
      Books(name: 'I Corintios', division: Division.nt),
      Books(name: 'II Corintios', division: Division.nt),
      Books(name: 'Galátas', division: Division.nt),
      Books(name: 'Efésios', division: Division.nt),
    ];

    ControllerADropDown<Books> controller = ControllerADropDown(itens: []);
    //build the items
    for (var item in bibleBooks) {
      controller.addItem(
        ADropDownItem<Books>(
          value: item,
        ),
      );
    }

    return MaterialApp(
      title: 'ADropDown Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ADropDown Example'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('This example sow a Multi List Menu on DropDown'),
            const Divider(),
            ADropDown<Books>(
              controller: controller,
              // decorationMenu: BoxDecoration(
              //     border: Border.all(
              //       color: Colors.black,
              //     ),
              //     borderRadius: BorderRadius.circular(25),
              //     gradient: const LinearGradient(colors: [Colors.blue, Colors.grey, Colors.blueGrey])),
              menuBackgroundBuilder: (context, child) {
                return Container(
                  decoration: const BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber,
                          Colors.blue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                      )),
                  child: child,
                );
              },
              menuItemBuilder: (context, items) {
                List<Widget> nt = [];
                List<Widget> at = [];
                Widget buildWidget(Books book) {
                  return TextButton(
                    onPressed: () {
                      controller.setValue(book);
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(book.division.name),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(book.name),
                      ],
                    ),
                  );
                }

                for (var element in items) {
                  if (element.value.division == Division.at) {
                    at.add(buildWidget(element.value));
                  } else {
                    nt.add(buildWidget(element.value));
                  }
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ...at.map((e) {
                              return e;
                            })
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(thickness: 3),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ...nt.map((e) {
                              return e;
                            })
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
              buttonBuilder: (context, value) {
                return SizedBox(width: 300, child: Center(child: Text(value.name)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
