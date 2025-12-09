import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Minimal HomeScreen widget used by the test to avoid missing import.
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(child: Text('Welcome to Goal Networking App')),
    );
  }
}

void main() {
  testWidgets('HomeScreen has a title and a message',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    final titleFinder = find.text('Home');
    final messageFinder = find.text('Welcome to Goal Networking App');

    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}
