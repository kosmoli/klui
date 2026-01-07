import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/models/agent.dart';

/// Screen displaying list of Agents
class AgentListScreen extends ConsumerWidget {
  const AgentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Letta Agents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(agentListProvider),
          ),
        ],
      ),
      body: agentsAsync.when(
        data: (agents) {
          if (agents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No agents found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first agent to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              return _AgentListTile(agent: agent);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading agents',
                style: TextStyle(fontSize: 18, color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create agent screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create agent - Coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AgentListTile extends StatelessWidget {
  final Agent agent;

  const _AgentListTile({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(agent.name[0].toUpperCase())),
        title: Text(agent.name),
        subtitle: agent.description != null
            ? Text(
                agent.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : const Text('No description'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to agent detail screen
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Selected: ${agent.name}')));
        },
      ),
    );
  }
}
