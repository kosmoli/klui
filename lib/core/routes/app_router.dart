import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/agents/screens/agent_list_screen.dart';
import '../../features/agents/screens/agent_detail_screen.dart';
import '../../features/agents/screens/agent_create_screen.dart';
import '../../features/providers/screens/provider_list_screen.dart';
import '../../features/providers/screens/provider_create_screen.dart';
import '../../features/providers/screens/provider_detail_screen.dart';
import '../extensions/context_extensions.dart';

/// Application router configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/agents',
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/agents'),
      GoRoute(
        path: '/agents',
        name: 'agents',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: AgentListScreen(),
            transitionDuration: Duration.zero,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
        routes: [
          GoRoute(
            path: 'create',
            name: 'agent-create',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                child: AgentCreateScreen(),
                transitionDuration: Duration.zero,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return child;
                },
              );
            },
          ),
          GoRoute(
            path: ':id',
            name: 'agent-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return CustomTransitionPage(
                child: AgentDetailScreen(agentId: id),
                transitionDuration: Duration.zero,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return child;
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/providers',
        name: 'providers',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: ProviderListScreen(),
            transitionDuration: Duration.zero,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
        routes: [
          GoRoute(
            path: 'create',
            name: 'provider-create',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                child: ProviderCreateScreen(),
                transitionDuration: Duration.zero,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return child;
                },
              );
            },
          ),
          GoRoute(
            path: ':id',
            name: 'provider-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return CustomTransitionPage(
                child: ProviderDetailScreen(providerId: id),
                transitionDuration: Duration.zero,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return child;
                },
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('${context.l10n.page_not_found}: ${state.uri}'))),
  );
});
