import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio_web/app/app.dart';

void main() {
  testWidgets('marketplace app shows the portfolio auth design',
      (tester) async {
    await tester
        .pumpWidget(const ProviderScope(child: PortfolioMarketplaceApp()));
    await tester.pump();

    expect(find.text('YOUR STORY. YOUR WORK. YOUR SPACE.'), findsOneWidget);
    expect(find.textContaining('Your next'), findsOneWidget);
    expect(find.textContaining('Welcome back'), findsOneWidget);
    expect(find.text('One portfolio. Every part of you.'), findsOneWidget);
  });

  testWidgets('desktop auth layout renders without layout errors',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester
        .pumpWidget(const ProviderScope(child: PortfolioMarketplaceApp()));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile auth layout renders without layout errors',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester
        .pumpWidget(const ProviderScope(child: PortfolioMarketplaceApp()));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
