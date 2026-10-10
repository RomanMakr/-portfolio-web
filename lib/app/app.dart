import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/marketplace/presentation/marketplace_page.dart';
import '../features/portfolio_editor/presentation/dashboard_page.dart';
import '../features/public_portfolio/presentation/public_portfolio_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MarketplacePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
    GoRoute(path: '/p/:slug', builder: (context, state) =>
        PublicPortfolioPage(slug: state.pathParameters['slug']!)),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);

class PortfolioMarketplaceApp extends StatelessWidget {
  const PortfolioMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Portfolia — Portfolio Marketplace',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      scaffoldBackgroundColor: const Color(0xFFF8F7FB),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    routerConfig: appRouter,
  );
}
