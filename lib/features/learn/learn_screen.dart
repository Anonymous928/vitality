import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Content hub (Clue pattern). Sections fill in as content is written.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _Section(
          icon: Icons.fact_check_outlined,
          title: 'Self-check',
          subtitle: 'Compare your experience with the POIS criteria',
          onTap: () => context.push('/self-check'),
        ),
        _Section(
          icon: Icons.science_outlined,
          title: 'Evidence library',
          subtitle: 'What research says about each treatment type',
          onTap: () => context.push('/evidence'),
        ),
        const _Section(
          icon: Icons.self_improvement,
          title: 'Mind & coping',
          subtitle: 'Self-compassion and fog-day strategies',
        ),
        const _Section(
          icon: Icons.favorite_outline,
          title: 'Partner space',
          subtitle: 'Explaining POIS to someone close to you',
        ),
        const _Section(
          icon: Icons.local_hospital_outlined,
          title: 'Find care',
          subtitle: 'Which specialist to see, and what to ask',
        ),
        _Section(
          icon: Icons.forum_outlined,
          title: 'Community',
          subtitle: 'r/POIS and the POISCenter forum',
          onTap: () => context.push('/community'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(onTap == null ? '$subtitle · coming soon' : subtitle),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      enabled: onTap != null,
      onTap: onTap,
    );
  }
}
