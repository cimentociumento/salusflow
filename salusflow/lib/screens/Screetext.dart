import 'package:flutter/material.dart';

class screenexercice extends StatelessWidget {
  const screenexercice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("penis longo e comprido"),),
      floatingActionButton: FloatingActionButton(onPressed: () {
        print("seu penis cresceu 1 cm");
      }, child: const Icon(Icons.add),),
    );
  }
}