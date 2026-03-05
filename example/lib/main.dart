import 'package:flutter/material.dart';
import 'package:flutter_rotating_shining_card/flutter_rotating_shining_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotating Shining Card Demo',
      theme: ThemeData.dark(),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Rotating Shining Card')),
      body: Center(
        child: RotatingShiningCard(
          width: 240,
          height: 340,
          frontChild:
              Image.asset('assets/images/card_1.png', fit: BoxFit.cover),
          backChild: Image.asset('assets/images/card_1.png', fit: BoxFit.cover),
          borderRadius: 16.0,
          shineIntensity: 0.6,
          shineColor: Colors.white,
        ),
      ),
    );
  }
}
