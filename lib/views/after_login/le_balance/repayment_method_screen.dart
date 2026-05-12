import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leBalance_controller/leBalance_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_appbar.dart';

class RepaymentMethodScreen extends StatelessWidget {
  RepaymentMethodScreen({super.key});

  final RepaymentController controller = Get.put(RepaymentController());

  @override
  Widget build(BuildContext context) {
    final List<_RepaymentOption> options = [
      _RepaymentOption(
        method: RepaymentMethod.autoPay,
        icon: Icons.bolt_rounded,
        title: 'AutoPay',
        description:
            'Auto-debit on due date with reminders & calling support throughout.',
        badge: 'Most popular',
      ),
      _RepaymentOption(
        method: RepaymentMethod.microDebit,
        icon: Icons.calendar_month_outlined,
        title: 'Daily Settle',
        description:
            'Daily micro-debits spread the load automatically with reminders & support.',
        badge: 'Low daily impact',
      ),
      _RepaymentOption(
        method: RepaymentMethod.smartProtect,
        icon: Icons.verified_user_outlined,
        title: 'Smart Protect',
        description:
            'Auto-debit + micro-debit failsafe with full recovery workflow if needed.',
        badge: 'Maximum protection',
      ),
      _RepaymentOption(
        method: RepaymentMethod.manualSupport,
        icon: Icons.back_hand_outlined,
        title: 'Manual Support',
        description:
            'Pay yourself before the due date. Reminders & calling assistance included.',
        badge: 'Full control',
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,

        appBar: _buildAppBar(controller),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  return Obx(
                    () => _RepaymentCard(
                      option: options[i],
                      isSelected:
                          controller.selectedMethod.value == options[i].method,
                      onTap: () => controller.selectMethod(options[i].method),
                    ),
                  );
                },
              ),
            ),

            // ── Confirm button ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              child: Obx(
                () => _ConfirmButton(
                  isLoading: controller.isLoading.value,
                  onTap: controller.isLoading.value ? null : controller.next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(RepaymentController controller) {
    return LeBalanceAppBar(
      title: "How will you repay?",
      subtitle: "₹${controller.amount} · Due ${controller.dueDate}",
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _RepaymentOption {
  final RepaymentMethod method;
  final IconData icon;
  final String title;
  final String description;
  final String badge;

  const _RepaymentOption({
    required this.method,
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
  });
}

// ── Repayment card ────────────────────────────────────────────────────────────

class _RepaymentCard extends StatelessWidget {
  final _RepaymentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RepaymentCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon box ──────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                option.icon,
                size: 22,
                color: isSelected ? AppColors.white : AppColors.grey400,
              ),
            ),

            const SizedBox(width: 14),

            // ── Text + badge ──────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: text14(
                      fontWeight: FontWeight.w700,
                    ).copyWith(color: AppColors.primary, letterSpacing: -0.1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: text12(
                      fontWeight: FontWeight.w400,
                    ).copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  _Badge(label: option.badge, active: isSelected),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Custom radio ──────────────────────
            _RadioDot(selected: isSelected),
          ],
        ),
      ),
    );
  }
}

// ── Badge pill ────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final bool active;
  const _Badge({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: text11(
              fontWeight: FontWeight.w500,
            ).copyWith(color: active ? AppColors.white : AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ── Custom radio dot ──────────────────────────────────────────────────────────

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.grey300,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: selected ? 9 : 0,
        height: selected ? 9 : 0,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Confirm button ────────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  const _ConfirmButton({required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading ? AppColors.grey600 : AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Confirm Method",
                    style: text16(
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: AppColors.white, letterSpacing: 0.2),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }
}
