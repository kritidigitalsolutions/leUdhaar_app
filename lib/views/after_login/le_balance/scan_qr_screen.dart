import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/custom_button.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/leBalance_controller/leBalance_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_appbar.dart';

class LeBalanceScreen extends StatelessWidget {
  LeBalanceScreen({super.key});

  final LeBalanceController controller = Get.put(LeBalanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeBalanceAppBar(
        title: "Le'Balance",
        subtitle: "Scan shop QR to begin",
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // ── Main Content ──────────────────────────────────────
              Container(
                decoration: BoxDecoration(color: AppColors.white),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // ── QR Scanner Frame ───────────────────────
                    _QrScannerFrame(controller: controller),

                    const SizedBox(height: 32),

                    // ── Scan Button ────────────────────────────
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: CustomElevatedIconButton(
                          text: 'Scan QR code in the frame',
                          icon: Icons.qr_code_scanner_rounded,
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.startScanning,
                        ),
                      ),
                    ),

                    // Obx(
                    const SizedBox(height: 20),

                    // ── OR Divider ─────────────────────────────
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: text13(
                              color: AppColors.grey.shade500,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Manual Shop ID ─────────────────────────
                    _ManualIdField(controller: controller),

                    // ── Error Message ──────────────────────────
                    Obx(
                      () => controller.errorMessage.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFCA5A5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Color(0xFFEF4444),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.errorMessage.value,
                                        style: const TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── QR Scanner Frame ─────────────────────────────────────────────────────────

class _QrScannerFrame extends StatelessWidget {
  final LeBalanceController controller;
  const _QrScannerFrame({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.background, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: controller.isScanning.value
              // When scanning is active, show camera preview placeholder
              // Replace this Stack with your mobile_scanner Widget
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: AppColors.black87),
                    // Corner brackets to indicate scan area
                    const _ScanOverlay(),
                    Positioned(
                      bottom: 16,
                      child: GestureDetector(
                        onTap: controller.stopScanning,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Cancel',
                            style: text13(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              // Idle state — show QR icon placeholder
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 160,
                      color: const Color(0xFF1E293B),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Point camera at shop QR code',
                      style: text13(color: AppColors.textSecondary),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Scan Overlay (corner brackets) ──────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(painter: _CornerPainter()),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.button
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    final r = size;

    // Top-left
    canvas.drawLine(const Offset(0, len), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(len, 0), paint);
    // Top-right
    canvas.drawLine(Offset(r.width - len, 0), Offset(r.width, 0), paint);
    canvas.drawLine(Offset(r.width, 0), Offset(r.width, len), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, r.height - len), Offset(0, r.height), paint);
    canvas.drawLine(Offset(0, r.height), Offset(len, r.height), paint);
    // Bottom-right
    canvas.drawLine(
      Offset(r.width - len, r.height),
      Offset(r.width, r.height),
      paint,
    );
    canvas.drawLine(
      Offset(r.width, r.height - len),
      Offset(r.width, r.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Manual ID Field ──────────────────────────────────────────────────────────

class _ManualIdField extends StatefulWidget {
  final LeBalanceController controller;
  const _ManualIdField({required this.controller});

  @override
  State<_ManualIdField> createState() => _ManualIdFieldState();
}

class _ManualIdFieldState extends State<_ManualIdField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextField(
        controller: _textController,
        onChanged: (val) => widget.controller.manualShopId.value = val,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontSize: 15, color: Color(0xFF111111)),
        decoration: InputDecoration(
          hintText: 'Enter shop ID manually',
          hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
          ),
          suffixIcon: widget.controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                )
              : widget.controller.manualShopId.value.isNotEmpty
              ? IconButton(
                  onPressed: widget.controller.submitManualShopId,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 22,
                  ),
                )
              : null,
        ),
        onSubmitted: (_) => widget.controller.submitManualShopId(),
      ),
    );
  }
}
