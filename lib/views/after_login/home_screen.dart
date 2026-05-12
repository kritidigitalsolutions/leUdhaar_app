import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/home_controller.dart';

// ─── Home Screen ─────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());

  // How tall the expanded flexible space is (below toolbar)
  static const double _expandedExtra = 190.0;
  // Total SliverAppBar expandedHeight = kToolbarHeight + _expandedExtra
  static const double _expandedHeight = kToolbarHeight + _expandedExtra;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsing App Bar ────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            expandedHeight: _expandedHeight,
            backgroundColor: AppColors.primary,
            surfaceTintColor: AppColors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,

            // ── Collapsed toolbar (always visible when pinned) ──────
            title: _CollapsedBar(controller: controller),
            titleSpacing: 0,

            // ── Expanded flexible space ─────────────────────────────
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // How much has it collapsed? 0.0 = fully expanded, 1.0 = fully collapsed
                final double maxExtent =
                    _expandedHeight + MediaQuery.of(context).padding.top;
                final double currentExtent = constraints.maxHeight;
                final double t = ((maxExtent - currentExtent) / _expandedExtra)
                    .clamp(0.0, 1.0);

                return _ExpandedHeader(
                  controller: controller,
                  collapseProgress: t,
                );
              },
            ),

            // Rounded bottom only when expanded
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
          ),

          // ── Features ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 14),
              child: _SectionLabel(title: 'Features'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _FeatureCard(
                    title: "Le'Udhaar",
                    subtitle:
                        'Digital repayment automation for personal credit transactions.',
                    icon: Icons.people_outline_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primary.withAlpha(20),
                    onTap: controller.goToLeUdhaar,
                  ),
                  const SizedBox(height: 10),
                  _FeatureCard(
                    title: "Le'Balance",
                    subtitle:
                        'Balance- credit Infra for cafes, shops & merchants',
                    icon: Icons.storefront_outlined,
                    iconColor: AppColors.success,
                    iconBg: AppColors.success.withAlpha(20),
                    onTap: controller.goToLeBalance,
                  ),
                  const SizedBox(height: 10),
                  _FeatureCard(
                    title: "Le'Legally",
                    subtitle:
                        'Digital agreements, e-sign & AI mou draft engine',
                    icon: Icons.description_outlined,
                    iconColor: AppColors.blue,
                    iconBg: AppColors.blue.withAlpha(20),
                    onTap: controller.goToLeLegally,
                    comingSoon: true,
                  ),
                ],
              ),
            ),
          ),

          // ── Recent ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 26, 12, 14),
              child: _SectionLabel(
                title: 'Recent',
                trailing: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'See all',
                    style: text13(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Transactions ─────────────────────────────────────────
          Obx(
            () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _TransactionTile(tx: controller.transactions[i]),
                  ),
                  childCount: controller.transactions.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Collapsed Bar (pinned toolbar) ──────────────────────────────────────────
// Shown when fully scrolled — compact name + actions
class _CollapsedBar extends StatelessWidget {
  final HomeController controller;
  const _CollapsedBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Mini avatar
          GestureDetector(
            onTap: controller.goToProfile,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  controller.userInitials.value,
                  style: text12(
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name
          Expanded(
            child: Text(
              controller.userName.value,
              style: text15(
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
          // Search
          // _HBtn(icon: Icons.search_rounded, onTap: () {}),
          const SizedBox(width: 8),
          // Notification
          Stack(
            children: [
              _HBtn(
                icon: Icons.notifications_outlined,
                onTap: controller.goToNotifications,
              ),
              Obx(
                () => controller.notificationCount.value > 0
                    ? Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Expanded Header (flexible space) ────────────────────────────────────────
// Fades / slides out as user scrolls up
class _ExpandedHeader extends StatelessWidget {
  final HomeController controller;
  final double collapseProgress; // 0 = expanded, 1 = collapsed

  const _ExpandedHeader({
    required this.controller,
    required this.collapseProgress,
  });

  static String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    // Fade out content as it collapses
    final double opacity = (1.0 - collapseProgress * 1.8).clamp(0.0, 1.0);
    // Slide content up slightly as it collapses
    final double slideUp = collapseProgress * 20;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, top + kToolbarHeight + 4, 22, 10),
        child: ClipRect(
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, -slideUp),
              child: Obx(
                () => SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance label
                      Text(
                        'TOTAL PENDING AMOUNT',
                        style: text11(
                          color: Color(0x99FFFFFF),
                          fontWeight: FontWeight.w500,
                        ).copyWith(letterSpacing: 0.6),
                      ),
                      const SizedBox(height: 4),
                      // Big amount
                      Text(
                        '₹${_fmt(controller.totalPendingAmount.value)}',
                        style: text30(
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ).copyWith(letterSpacing: -1.5, height: 1.1),
                      ),
                      const SizedBox(height: 14),
                      // Stat chips
                      Row(
                        children: [
                          Expanded(
                            child: _StatChip(
                              label: 'You Need to Pay',
                              amount: controller.youNeedToPay.value,
                              icon: Icons.arrow_upward_rounded,
                              iconColor: AppColors.error,
                              iconBg: AppColors.error.withAlpha(20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatChip(
                              label: 'You Will Receive',
                              amount: controller.youWillReceive.value,
                              icon: Icons.arrow_downward_rounded,
                              iconColor: AppColors.success,
                              iconBg: AppColors.success.withAlpha(20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _HBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.yellow.withAlpha(40),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 19, color: AppColors.yellow),
    ),
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color iconColor;
  final Color iconBg;

  final IconData icon;
  const _StatChip({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  static String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: text10(
              color: AppColors.hintText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${_fmt(amount)}',
            style: text16(fontWeight: FontWeight.w800, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionLabel({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.6,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;
  final bool comingSoon;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.white),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: text15(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (comingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Coming Soon',
                              style: text8(
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: text12(
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  const _TransactionTile({required this.tx});

  static String _fmt(double v) {
    return v
        .abs()
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  ({Color bg, Color fg, Color dot, Color? border}) get s {
    switch (tx.status) {
      case 'Pending':
        return (
          bg: AppColors.warning.withOpacity(.12),
          fg: AppColors.warning,
          dot: AppColors.warning,
          border: null,
        );

      case 'Active':
        return (
          bg: AppColors.success.withOpacity(.12),
          fg: AppColors.success,
          dot: AppColors.success,
          border: null,
        );

      case 'Paid':
        return (
          bg: AppColors.grey.withOpacity(.08),
          fg: AppColors.textSecondary,
          dot: AppColors.textSecondary,
          border: AppColors.background,
        );

      default:
        return (
          bg: AppColors.background,
          fg: AppColors.textSecondary,
          dot: AppColors.textSecondary,
          border: AppColors.background,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNeg = tx.amount < 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.background),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                tx.initials,
                style: text13(
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.name,
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: s.dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      tx.dueDate,
                      style: text11(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isNeg ? '-' : '+'}₹${_fmt(tx.amount)}',
                style: text15(
                  fontWeight: FontWeight.w800,
                  color: isNeg ? AppColors.error : AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: s.border != null
                      ? Border.all(color: s.border!)
                      : null,
                ),
                child: Text(
                  tx.status,
                  style: text10(fontWeight: FontWeight.w700, color: s.fg),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
