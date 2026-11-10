import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonte_pos/core/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders title, message, icon, and action button',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Data Kosong',
              message: 'Silakan tambah data baru',
              action: ElevatedButton(
                onPressed: () {},
                child: const Text('Aksi'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Data Kosong'), findsOneWidget);
      expect(find.text('Silakan tambah data baru'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(find.text('Aksi'), findsOneWidget);
    });
  });
}

