import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/agents/screens/agent_list_screen.dart';

/// Application router configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/agents',
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/agents'),
      GoRoute(
        path: '/agents',
        name: 'agents',
        builder: (context, state) => const AgentListScreen(),
      ),
      // TODO: Add more routes
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
