import 'package:flutter/material.dart';
import '../../core/constants/ws_colors.dart';
import '../../core/i18n/locale_provider.dart';
import 'milestone_model.dart';
import 'milestone_card.dart';
import 'milestone_edit_dialog.dart';
import 'milestone_delete_dialog.dart';

class MilestoneList extends StatefulWidget {
  const MilestoneList({super.key});

  @override
  State<MilestoneList> createState() => _MilestoneListState();
}

class _MilestoneListState extends State<MilestoneList> {
  late List<Milestone> _milestones;

  @override
  void initState() {
    super.initState();
    _milestones = Milestone.getDefaultMilestones();
  }

  void _sortMilestones() {
    _milestones.sort((a, b) {
      if (a.priority != b.priority) {
        return a.priority.compareTo(b.priority);
      }
      return a.targetTime.compareTo(b.targetTime);
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => MilestoneEditDialog(
        onSave: (newMilestone) {
          setState(() {
            _milestones.add(newMilestone);
            _sortMilestones();
          });
        },
      ),
    );
  }

  void _showEditDialog(Milestone milestone) {
    showDialog(
      context: context,
      builder: (ctx) => MilestoneEditDialog(
        milestone: milestone,
        onSave: (updated) {
          setState(() {
            final index = _milestones.indexWhere((m) => m.id == updated.id);
            if (index != -1) {
              _milestones[index] = updated;
              _sortMilestones();
            }
          });
        },
      ),
    );
  }

  void _showDeleteDialog(String milestoneId) {
    final milestone = _milestones.firstWhere((m) => m.id == milestoneId);
    showDialog(
      context: context,
      builder: (ctx) => MilestoneDeleteDialog(
        milestoneTitle: milestone.title,
        targetTime: milestone.targetTime,
        onConfirm: () {
          setState(() {
            _milestones.removeWhere((m) => m.id == milestoneId);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.flag_outlined,
              size: 16,
              color: WsColors.accentCyan,
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
            const Spacer(),
            _buildAddButton(s),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _milestones.isEmpty
              ? _buildEmptyState(s)
              : ListView.separated(
                  itemCount: _milestones.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return MilestoneCard(
                      milestone: _milestones[index],
                      onEdit: (milestone) => _showEditDialog(milestone),
                      onDelete: (milestoneId) =>
                          _showDeleteDialog(milestoneId),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAddButton(dynamic s) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _showAddDialog,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: WsColors.accentCyan.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: WsColors.accentCyan.withAlpha(60),
            ),
          ),
          child: const Icon(
            Icons.add,
            size: 18,
            color: WsColors.accentCyan,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(dynamic s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: WsColors.textSecondary.withAlpha(60),
          ),
          const SizedBox(height: 12),
          Text(
            s.noMilestones,
            style: const TextStyle(
              fontSize: 14,
              color: WsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.addFirstMilestone,
            style: const TextStyle(
              fontSize: 12,
              color: WsColors.accentCyan,
            ),
          ),
        ],
      ),
    );
  }
}
