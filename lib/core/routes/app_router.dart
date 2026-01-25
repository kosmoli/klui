import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/agents/screens/agent_list_screen.dart';
import '../../features/agents/screens/agent_detail_screen.dart';
import '../../features/agents/screens/agent_create_screen.dart';
import '../../features/agents/screens/agent_edit_screen.dart';
import '../../features/providers/screens/provider_list_screen.dart';
import '../../features/providers/screens/provider_create_screen.dart';
import '../../features/providers/screens/provider_detail_screen.dart';
import '../../features/providers/screens/provider_edit_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../extensions/context_extensions.dart';
import '../providers/chat_providers.dart';

/// Application router configuration
/// Chat is now the homepage - this is an AI assistant first, management tool second
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/chat',
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/chat'),
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) {
          // ChatScreen will read agentId from selectedAgentIdProvider
          // Query param can override it temporarily
          final queryAgentId = state.uri.queryParameters['agentId'];
          return CustomTransitionPage(
            child: ChatScreen(initialAgentId: queryAgentId),
            transitionDuration: Duration.zero,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
      ),
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
            routes: [
              GoRoute(
                path: 'edit',
                name: 'agent-edit',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CustomTransitionPage(
                    child: AgentEditScreen(agentId: id),
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
            routes: [
              GoRoute(
                path: 'edit',
                name: 'provider-edit',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CustomTransitionPage(
                    child: ProviderEditScreen(providerId: id),
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
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('${context.l10n.page_not_found}: ${state.uri}'))),
  );
});
