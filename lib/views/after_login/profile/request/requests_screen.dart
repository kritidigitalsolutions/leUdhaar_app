import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/auth_models/verify_res_model.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/request_money_res_model.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/service/local_storage/auth_storage.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/profile_controller/request_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RequestController _controller = Get.put(RequestController());

  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.fetchHelpData();
    userId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void userId() {
    User? user = AuthStorage.getUser();
    currentUserId = user?.id ?? '';
  }

  /// Lender — someone sent a request TO me (requestTo == me)
  List<Datum> _lenderRequests(List<Datum> data) =>
      data.where((d) => d.requestTo?.id == currentUserId).toList();

  /// Borrower — I sent a request to someone else (requestFrom == me)
  List<Datum> _borrowerRequests(List<Datum> data) =>
      data.where((d) => d.requestFrom?.id == currentUserId).toList();

  int _pendingCount(List<Datum> data) => _lenderRequests(
    data,
  ).where((d) => d.status?.toLowerCase() == 'pending').length;

  // ── Borrower bottom sheet ────────────────────────────────────────────────────
  void _showBorrowerDetails(Datum req) {
    final name = req.requestTo?.fullName ?? 'Unknown';
    final initials = _getInitials(name);
    final statusColor = _statusColor(req.status);
    final statusLabel = _capitalise(req.status ?? 'Unknown');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    children: [
                      Text(
                        'Request Details',
                        style: text16(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Avatar + name
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          initials,
                          style: text20(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: text18(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You requested money from them',
                        style: text12(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      Text(
                        '₹${req.amount ?? 0}',
                        style: text26(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (req.reason != null && req.reason!.isNotEmpty)
                        Text(
                          req.reason!,
                          style: text13(color: AppColors.textSecondary),
                        ),
                      const SizedBox(height: 10),

                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withAlpha(80)),
                        ),
                        child: Text(
                          statusLabel,
                          style: text12(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Detail rows
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _detailRow(
                              'Return date',
                              req.returnDate != null
                                  ? '${req.returnDate!.day} ${_monthName(req.returnDate!.month)} ${req.returnDate!.year}'
                                  : 'N/A',
                              valueColor: AppColors.button,
                            ),
                            Divider(height: 1, color: AppColors.grey200),
                            _detailRow(
                              'Repayment',
                              _capitalise(req.repaymentMode ?? 'N/A'),
                              valueColor: AppColors.button,
                            ),
                            Divider(height: 1, color: AppColors.grey200),
                            _detailRow(
                              'Receive via',
                              _capitalise(req.receiveMethod ?? 'N/A'),
                            ),
                            if (req.receiveDetails?.upiId != null &&
                                req.receiveDetails!.upiId!.isNotEmpty) ...[
                              Divider(height: 1, color: AppColors.grey200),
                              _detailRow('UPI ID', req.receiveDetails!.upiId!),
                            ],
                            if (req.receiveDetails?.accountNumber != null &&
                                req
                                    .receiveDetails!
                                    .accountNumber!
                                    .isNotEmpty) ...[
                              Divider(height: 1, color: AppColors.grey200),
                              _detailRow(
                                'Account No.',
                                req.receiveDetails!.accountNumber!,
                              ),
                              Divider(height: 1, color: AppColors.grey200),
                              _detailRow(
                                'IFSC',
                                req.receiveDetails?.ifscCode ?? 'N/A',
                              ),
                            ],
                            if (req.responseNote != null &&
                                req.responseNote!.isNotEmpty) ...[
                              Divider(height: 1, color: AppColors.grey200),
                              _detailRow('Response note', req.responseNote!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (req.createdAt != null)
                        Text(
                          'Sent on ${req.createdAt!.day} ${_monthName(req.createdAt!.month)} ${req.createdAt!.year}  •  ${_formatTime(req.createdAt!)}',
                          style: text12(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + TabBar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 0,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    backButton(),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requests',
                          style: text18(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Manage money requests',
                          style: text12(color: AppColors.white54),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.white,
                  indicatorWeight: 3,
                  labelColor: AppColors.white,
                  unselectedLabelColor: AppColors.white54,
                  labelStyle: text14(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: text14(),
                  tabs: const [
                    Tab(text: 'Lender'),
                    Tab(text: 'Borrower'),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              final state = _controller.requestMoneyRes.value;

              if (state.status == Status.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == Status.error) {
                return Center(
                  child: Text(
                    state.message ?? 'Something went wrong',
                    style: text14(color: AppColors.error),
                  ),
                );
              }

              final allData = state.data?.data ?? [];
              final lenderList = _lenderRequests(allData);
              final borrowerList = _borrowerRequests(allData);
              final pendingCount = _pendingCount(allData);

              return Column(
                children: [
                  const SizedBox(height: 14),

                  // Pending warning — lender tab only
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (_, _) {
                      if (_tabController.index != 0 || pendingCount == 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 14,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFE0A3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.warning,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '$pendingCount pending request${pendingCount > 1 ? 's' : ''} need your response',
                                  style: text13(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLenderList(lenderList),
                        _buildBorrowerList(borrowerList),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Lender list ──────────────────────────────────────────────────────────────
  Widget _buildLenderList(List<Datum> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No one has sent you a request',
          style: text14(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (_, i) => _lenderCard(list[i]),
    );
  }

  Widget _lenderCard(Datum req) {
    final name = req.requestFrom?.fullName ?? 'Unknown';
    final initials = _getInitials(name);
    final formattedDate = req.createdAt != null
        ? '${req.createdAt!.day} ${_monthName(req.createdAt!.month)}'
        : '';
    final formattedTime = req.createdAt != null
        ? _formatTime(req.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  initials,
                  style: text13(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: text14(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${req.reason ?? ''} · $formattedDate',
                      style: text12(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedTime,
                    style: text11(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${req.amount ?? 0}',
                    style: text15(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  color: AppColors.grey,
                  height: 38,
                  title: "View Request",
                  onTap: () {
                    // Navigate to AcceptRequestScreen, passing the Datum object
                    Get.toNamed(AppRoutes.acceptRequest, arguments: req);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  color: AppColors.error,
                  height: 38,
                  title: "Decline",
                  onTap: () {
                    // TODO: call decline API with req.id
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Borrower list ─────────────────────────────────────────────────────────────
  Widget _buildBorrowerList(List<Datum> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          "You haven't sent any requests",
          style: text14(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (_, i) => _borrowerCard(list[i]),
    );
  }

  Widget _borrowerCard(Datum req) {
    final name = req.requestTo?.fullName ?? 'Unknown';
    final initials = _getInitials(name);
    final formattedDate = req.createdAt != null
        ? '${req.createdAt!.day} ${_monthName(req.createdAt!.month)}'
        : '';
    final formattedTime = req.createdAt != null
        ? _formatTime(req.createdAt!)
        : '';
    final statusColor = _statusColor(req.status);
    final statusLabel = _capitalise(req.status ?? 'Unknown');

    return GestureDetector(
      onTap: () => _showBorrowerDetails(req),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: text13(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: text14(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${req.reason ?? ''} · $formattedDate',
                    style: text12(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTime,
                  style: text11(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${req.amount ?? 0}',
                  style: text15(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // inline status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withAlpha(80)),
                  ),
                  child: Text(
                    statusLabel,
                    style: text10(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Shared detail row widget ─────────────────────────────────────────────────
  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: text13(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: text13(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _monthName(int month) {
    const months = [
      '',
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
    return months[month];
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour < 12 ? 'am' : 'pm';
    return '$h:$m$suffix';
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'accepted':
        return Colors.green;
      case 'declined':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _capitalise(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;
}
