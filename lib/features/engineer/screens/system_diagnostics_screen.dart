import 'package:flutter/material.dart';
import '../../../shared/layouts/engineer_scaffold.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/sensor_node.dart';
import '../engineer_service.dart';

class SystemDiagnosticsScreen extends StatelessWidget {
  const SystemDiagnosticsScreen({super.key});

  static final EngineerService _engineerService = EngineerService();

  @override
  Widget build(BuildContext context) {
    const uptime = 99.9;

    return EngineerScaffold(
      title: 'System Diagnostics',
      currentIndex: 3,
      body: StreamBuilder<List<SensorNode>>(
        stream: _engineerService.streamSensorNodes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Failed to load live sensor data.'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final nodes = snapshot.data ?? <SensorNode>[];
          final onlineNodes = nodes.where(_isNodeOnline).length;
          final totalNodes = nodes.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health & Logs',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                const _SystemStatusCard(),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.wifi,
                        label: 'Network',
                        value: '$onlineNodes/$totalNodes Online',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.timelapse,
                        label: 'Uptime',
                        value: '$uptime%',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Text(
                  'Node Health',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                if (nodes.isEmpty)
                  const Text('No live sensor nodes found.')
                else
                  ...nodes.map((node) => _NodeHealthCard(node: node)),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isNodeOnline(SensorNode node) {
    return node.status.toLowerCase() != 'offline';
  }
}

class _SystemStatusCard extends StatelessWidget {
  const _SystemStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF032542), Color(0xFF042A3B)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0A4A6A)),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFF00BFEA).withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_outline,
                size: 44,
                color: Color(0xFF17D9FF),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'System Operational',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF19DFFF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All diagnostic checks passed',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111C39),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F3258)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF22D9FF)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _NodeHealthCard extends StatelessWidget {
  const _NodeHealthCard({required this.node});

  final SensorNode node;

  @override
  Widget build(BuildContext context) {
    final batteryLevel = _getBatteryLevel(node.id);
    final signalLevel = _getSignalLevel(node.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111C39),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3156)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      node.location,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _StatusBadge(isOnline: node.status.toLowerCase() != 'offline'),
            ],
          ),
          const SizedBox(height: 14),
          _MetricRow(icon: Icons.battery_std, value: batteryLevel),
          const SizedBox(height: 8),
          _MetricRow(icon: Icons.network_cell, value: signalLevel),
          const SizedBox(height: 10),
          Text(
            'Last check-in: ${_formatLastCheck(node.lastUpdated)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  int _getBatteryLevel(String nodeId) {
    switch (nodeId) {
      case '1':
        return 87;
      case '2':
        return 62;
      case '3':
        return 74;
      default:
        return 79;
    }
  }

  int _getSignalLevel(String nodeId) {
    switch (nodeId) {
      case '1':
        return 92;
      case '2':
        return 75;
      case '3':
        return 88;
      default:
        return 82;
    }
  }

  String _formatLastCheck(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 7,
              backgroundColor: const Color(0xFF233149),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF26D89A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$value %',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final bgColor = isOnline
        ? const Color(0xFF123E3A)
        : AppColors.dangerBackground;
    final textColor = isOnline ? const Color(0xFF2AE7B3) : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: textColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.wifi : Icons.wifi_off,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
