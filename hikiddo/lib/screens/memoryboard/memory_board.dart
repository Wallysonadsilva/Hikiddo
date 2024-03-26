import 'package:flutter/material.dart';
import 'package:hikiddo/screens/memoryboard/components/body.dart';

class MemoryBoardPage extends StatelessWidget {
  const MemoryBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      //appBar: TopNavigationBar(),
      body:  Body(),
    );
  }
}