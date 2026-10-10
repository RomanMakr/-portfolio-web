import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_marketplace/app/app.dart';

void main() {
  testWidgets('marketplace app shows brand and hero', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PortfolioMarketplaceApp()));
    await tester.pump();
    expect(find.text('Portfolia'), findsOneWidget);
    expect(find.textContaining('Your work deserves'), findsOneWidget);
  });
}
