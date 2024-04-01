import 'package:flutter/material.dart';
import 'package:hikiddo/screens/voicerecord/components/body.dart';

class RecordVoicePage extends StatelessWidget {
  const RecordVoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      //appBar: TopNavigationBar(),
      body:  Body(),
    );
  }
}