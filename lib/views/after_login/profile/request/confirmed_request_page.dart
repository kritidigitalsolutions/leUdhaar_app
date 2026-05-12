import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leBalance_controller/leBalance_controller.dart';

class ConfirmedRequestPage extends StatelessWidget {
  ConfirmedRequestPage({super.key});

  final CreditLoggedController controller = Get.put(CreditLoggedController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated Success Icon ──────────────────────────────
              const _AnimatedSuccessIcon(),

              const SizedBox(height: 28),

              // ── Title ──────────────────────────────────────────────
              Text(
                'Approved!',
                style: text26(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ).copyWith(letterSpacing: 0.5),
              ),

              const SizedBox(height: 10),

              // ── Subtitle ───────────────────────────────────────────
              Text(
                '₹2,000 sent to Rahul Sharma.\nAgreement is now active.',
                textAlign: TextAlign.center,
                style: text14(
                  color: AppColors.textSecondary,
                ).copyWith(height: 1.55),
              ),

              const SizedBox(height: 28),

              // ── Detail Card ────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Shop',
                      value: controller.shopName,
                      isFirst: true,
                    ),
                    _DetailRow(
                      label: 'Amount',
                      valueWidget: Text(
                        '₹${controller.amount}',
                        style: text15(
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    _DetailRow(label: 'Due date', value: controller.dueDate),
                    _DetailRow(
                      label: 'Repayment',
                      value: controller.repayment,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              Text(
                '₹2,000 sent to Rahul Sharma.\nAgreement is now active.',
                textAlign: TextAlign.center,
                style: text14(
                  color: AppColors.textSecondary,
                ).copyWith(height: 1.55),
              ),

              const Spacer(flex: 2),

              // ── Dashboard Button ───────────────────────────────────
              AppButton(title: "Back to Home", onTap: controller.goToDashboard),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animated Success Icon ────────────────────────────────────────────────────

class _AnimatedSuccessIcon extends StatefulWidget {
  const _AnimatedSuccessIcon();

  @override
  State<_AnimatedSuccessIcon> createState() => _AnimatedSuccessIconState();
}

class _AnimatedSuccessIconState extends State<_AnimatedSuccessIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _rays;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _rays = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => SizedBox(
        width: 130,
        height: 130,
        child: CustomPaint(
          painter: _SunRaysPainter(opacity: _rays.value),
          child: Center(
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFFBBF7D0),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.28),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF15803D),
                  size: 46,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SunRaysPainter extends CustomPainter {
  final double opacity;
  _SunRaysPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E).withOpacity(opacity * 0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    const rayCount = 12;
    const innerR = 48.0;
    const outerR = 62.0;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * pi) / rayCount;
      final start = Offset(
        center.dx + innerR * cos(angle),
        center.dy + innerR * sin(angle),
      );
      final end = Offset(
        center.dx + outerR * cos(angle),
        center.dy + outerR * sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(_SunRaysPainter old) => old.opacity != opacity;
}

// ─── Detail Row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool isFirst;
  final bool isLast;

  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFDBEAFE), width: 1),
              ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: text14(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          valueWidget ??
              Text(
                value ?? '',
                style: text15(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
        ],
      ),
    );
  }
}
