import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/profile_models/dashboard_res_model.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/profile_controller/finance_controller/finance_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.put(DashboardController());

  int _selectedTab = 0; // 0 = Lending, 1 = Borrowing
  String _selectedPeriod = 'This Week';

  final List<String> _periods = ['This Week', 'This Month', 'This Year'];
  final List<String> _periodKeys = ['this_week', 'this_month', 'this_year'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // API called only once
  void _loadInitialData() {
    controller.dashboardData();
  }

  // Period change - No API call (using already fetched data)
  void _onPeriodChanged(String newPeriod) {
    setState(() => _selectedPeriod = newPeriod);
    // TODO: Add client-side filtering later if backend returns all periods data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final apiResponse = controller.dashBoardRes.value;

        if (apiResponse.status == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (apiResponse.status == Status.error || apiResponse.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${apiResponse.message ?? "Something went wrong"}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadInitialData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final dashboardData = apiResponse.data!.data;
        final isLending = _selectedTab == 0;

        // Safe Section Handling
        final Lending? lendingSection = isLending
            ? dashboardData?.lending
            : null;
        final Borrowing? borrowingSection = !isLending
            ? dashboardData?.borrowing
            : null;

        final dynamic cards = isLending
            ? lendingSection?.cards
            : borrowingSection?.cards;

        // Fixed: Handle both Lending (List<Person>) and Borrowing (List<dynamic>)
        final List<Person> peopleList = isLending
            ? (lendingSection?.people ?? [])
            : (borrowingSection?.people ?? [])
                  .map(
                    (item) => item is Map<String, dynamic>
                        ? Person.fromJson(item)
                        : item as Person,
                  )
                  .toList();

        final String peopleTitle = isLending
            ? (lendingSection?.peopleTitle ?? 'People you lent to')
            : (borrowingSection?.peopleTitle ?? 'People you Owe to');

        return Column(
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
                  ? _lendingStatsGrid(cards as LendingCards?)
                  : _borrowingStatsGrid(cards as BorrowingCards?),
            ),
            const SizedBox(height: 16),

            // People section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    peopleTitle,
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
              child: Row(
                children: _periods.map((p) => _periodChip(p)).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // People list
            Expanded(
              child: peopleList.isEmpty
                  ? const Center(
                      child: Text('No transactions found for this period'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: peopleList.length,
                      itemBuilder: (_, i) => _personTile(peopleList[i]),
                    ),
            ),
          ],
        );
      }),
    );
  }

  // Tab Button
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

  // Lending Stats Grid
  Widget _lendingStatsGrid(LendingCards? cards) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Total lent',
                '₹${cards?.totalLent ?? 0}',
                AppColors.white,
                AppColors.textPrimary,
                AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Recovered',
                '₹${cards?.recovered ?? 0}',
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
                '₹${cards?.pending ?? 0}',
                const Color(0xFFFFF8E1),
                const Color(0xFFF59F00),
                const Color(0xFFF59F00),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Overdue',
                '₹${cards?.overdue ?? 0}',
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

  // Borrowing Stats Grid
  Widget _borrowingStatsGrid(BorrowingCards? cards) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Total owed',
                '₹${cards?.totalOwed ?? 0}',
                AppColors.white,
                AppColors.textPrimary,
                AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Repaid',
                '₹${cards?.repaid ?? 0}',
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
                '₹${cards?.remaining ?? 0}',
                const Color(0xFFFFF8E1),
                const Color(0xFFF59F00),
                const Color(0xFFF59F00),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Next due',
                '₹${cards?.nextDue ?? 0}',
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

  // Period Chip
  Widget _periodChip(String label) {
    final selected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () => _onPeriodChanged(label),
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

  // Person Tile
  Widget _personTile(Person person) {
    final status = person.displayStatus ?? person.status ?? 'Pending';

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
              person.initials ?? 'NA',
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
                  person.user?.fullName ?? 'Unknown',
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  person.dueDate != null
                      ? 'Due ${person.dueDate!.day} ${_getMonthName(person.dueDate!.month)}'
                      : 'No due date',
                  style: text12(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${person.amount ?? 0}',
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF27AE60);
      case 'overdue':
        return AppColors.error;
      case 'pending':
        return const Color(0xFFF59F00);
      case 'auto':
        return AppColors.button;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
