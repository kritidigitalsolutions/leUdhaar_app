import 'package:flutter/material.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0; // 0 = Lending, 1 = Borrowing
  String _selectedPeriod = 'This Week';

  final List<String> _periods = ['This Week', 'This Month', 'This Year'];

  // Lending data
  final _lendingStats = {
    'totalLent': '₹4,650',
    'recovered': '₹2,000',
    'pending': '₹1,650',
    'overdue': '₹1,000',
  };

  // Borrowing data
  final _borrowingStats = {
    'totalOwed': '₹4,650',
    'repaid': '₹2,000',
    'remaining': '₹1,650',
    'nextDue': '₹1,000',
  };

  final List<Map<String, dynamic>> _lendingPeople = [
    {
      'name': 'Amit Bhai',
      'initials': 'AB',
      'amount': '₹500',
      'due': 'Due 15 May',
      'status': 'Active',
    },
    {
      'name': 'Priya Didi',
      'initials': 'PD',
      'amount': '₹1000',
      'due': 'Due 10 May',
      'status': 'Overdue',
    },
    {
      'name': 'Amit Bhai',
      'initials': 'AB',
      'amount': '₹500',
      'due': 'Due 15 May',
      'status': 'Active',
    },
    {
      'name': 'Priya Didi',
      'initials': 'PD',
      'amount': '₹1000',
      'due': 'Due 10 May',
      'status': 'Overdue',
    },
  ];

  final List<Map<String, dynamic>> _borrowingPeople = [
    {
      'name': 'Amit Bhai',
      'initials': 'AB',
      'amount': '₹500',
      'due': 'Due 15 May',
      'status': 'Auto',
    },
    {
      'name': 'Priya Didi',
      'initials': 'PD',
      'amount': '₹1000',
      'due': 'Due 10 May',
      'status': 'Wanted',
    },
    {
      'name': 'Amit Bhai',
      'initials': 'AB',
      'amount': '₹500',
      'due': 'Due 15 May',
      'status': 'Auto',
    },
    {
      'name': 'Priya Didi',
      'initials': 'PD',
      'amount': '₹1000',
      'due': 'Due 10 May',
      'status': 'Manual',
    },
  ];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF27AE60);
      case 'overdue':
        return AppColors.error;
      case 'auto':
        return AppColors.button;
      case 'wanted':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLending = _selectedTab == 0;
    final stats = isLending ? _lendingStats : _borrowingStats;
    final people = isLending ? _lendingPeople : _borrowingPeople;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 10,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    backButton(),
                    const SizedBox(width: 12),
                    Text(
                      'Dashboard',
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab switcher
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _tabButton('Lending', 0),
                      _tabButton('Borrowing', 1),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLending
                ? _lendingStatsGrid(stats)
                : _borrowingStatsGrid(stats),
          ),
          const SizedBox(height: 16),

          // People section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isLending ? 'People you lent to' : 'People you Owe to',
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Period filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: _periods.map((p) => _periodChip(p)).toList()),
          ),
          const SizedBox(height: 10),

          // People list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: people.length,
              itemBuilder: (_, i) => _personTile(people[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? AppColors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 1,
              color: selected ? AppColors.primary : AppColors.button,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: text14(fontWeight: FontWeight.w600, color: AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget _lendingStatsGrid(Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Total lent',
                stats['totalLent']!,
                AppColors.white,
                AppColors.textPrimary,
                AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Recovered',
                stats['recovered']!,
                const Color(0xFFE8F5E9),
                const Color(0xFF27AE60),
                const Color(0xFF27AE60),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Pending',
                stats['pending']!,
                const Color(0xFFFFF8E1),
                const Color(0xFFF59F00),
                const Color(0xFFF59F00),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Overdue',
                stats['overdue']!,
                const Color(0xFFFFEBEB),
                AppColors.error,
                AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _borrowingStatsGrid(Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Total owed',
                stats['totalOwed']!,
                AppColors.white,
                AppColors.textPrimary,
                AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Repaid',
                stats['repaid']!,
                const Color(0xFFE8F5E9),
                const Color(0xFF27AE60),
                const Color(0xFF27AE60),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Remaining',
                stats['remaining']!,
                const Color(0xFFFFF8E1),
                const Color(0xFFF59F00),
                const Color(0xFFF59F00),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Next due',
                stats['nextDue']!,
                const Color(0xFFFFEBEB),
                AppColors.error,
                AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    Color bg,
    Color valueColor,
    Color labelColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text12(color: labelColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: text18(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _periodChip(String label) {
    final selected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.button : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.button : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: text12(
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _personTile(Map<String, dynamic> person) {
    final status = person['status'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Text(
              person['initials'],
              style: text13(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person['name'],
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  person['due'],
                  style: text12(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                person['amount'],
                style: text14(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: text11(
                    fontWeight: FontWeight.w600,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
