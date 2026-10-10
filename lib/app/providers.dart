import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final templatesProvider = FutureProvider<List<dynamic>>((ref) =>
    ref.watch(apiClientProvider).templates());

final myPortfoliosProvider = FutureProvider<List<dynamic>>((ref) =>
    ref.watch(apiClientProvider).myPortfolios());
