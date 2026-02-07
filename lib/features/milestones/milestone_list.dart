import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import 'milestone_model.dart';
import 'milestone_card.dart';

class MilestoneList extends StatelessWidget {
  const MilestoneList({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    final milestones = [
      Milestone(
        title: s.registrationDeadline,
        targetTime: DateTime.utc(2026, 3, 31, 16, 0, 0),
      ),
      Milestone(
        title: s.technicalDescription,
        targetTime: DateTime.utc(2026, 6, 1, 0, 0, 0),
      ),
      Milestone(
        title: s.toolboxCheck,
        targetTime: DateTime.utc(2026, 9, 2, 0, 0, 0),
      ),
      Milestone(
        title: s.infrastructureSetup,
        targetTime: DateTime.utc(2026, 9, 15, 0, 0, 0),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.flag_outlined,
              size: 16,
              color: WsColors.accentYellow,
            ),
            const SizedBox(width: 8),
            Text(
              s.keyMilestones,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WsColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: milestones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return MilestoneCard(milestone: milestones[index]);
            },
          ),
        ),
      ],
    );
  }
}
