import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/agents/screens/agent_list_screen.dart';
import '../../features/agents/screens/agent_detail_screen.dart';
import '../../features/agents/screens/agent_create_screen.dart';

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
        routes: [
          GoRoute(
            path: 'create',
            name: 'agent-create',
            builder: (context, state) => const AgentCreateScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'agent-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AgentDetailScreen(agentId: id);
            },
          ),
        ],
      ),
      // TODO: Add more routes
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
