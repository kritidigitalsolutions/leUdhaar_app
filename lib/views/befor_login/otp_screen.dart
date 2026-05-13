import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/before_login/auth_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final phone = Get.arguments;
  final controller = Get.find<AuthController>();
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final c in controller.otpControllers) {
      c.clear();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining == 0) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _resendOtp() {
    if (!_canResend) return;
    for (final c in controller.otpControllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    _startTimer();
    controller.resendOtp();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && !RegExp(r'^\d$').hasMatch(value)) {
      controller.otpControllers[index].clear();
      return;
    }
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (controller.otpControllers[index].text.isEmpty && index > 0) {
        controller.otpControllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final digits = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    for (int i = 0; i < 6; i++) {
      controller.otpControllers[i].text = i < digits.length ? digits[i] : '';
    }
    _focusNodes[(digits.length - 1).clamp(0, 5)].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Back button ───────────────────────────────
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF4A4845),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Back",
                        style: text13(
                          fontWeight: FontWeight.w500,
                        ).copyWith(color: const Color(0xFF4A4845)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Logo ──────────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "₹",
                      style: text40(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ).copyWith(height: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    "Enter verification code",
                    style: text24(fontWeight: FontWeight.w700).copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: text14().copyWith(color: const Color(0xFF7A7670)),
                      children: [
                        const TextSpan(text: "Sent to "),
                        TextSpan(
                          text: "+91 $phone",
                          style: text14(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── OTP Boxes ─────────────────────────────────
                GestureDetector(
                  onLongPress: _handlePaste,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (i) => _OtpBox(
                        index: i,
                        controller: controller.otpControllers[i],
                        focusNode: _focusNodes[i],
                        onChanged: (v) => _onOtpChanged(v, i),
                        onKeyEvent: (e) => _onKeyEvent(e, i),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Resend row ────────────────────────────────
                Center(
                  child: _canResend
                      ? GestureDetector(
                          onTap: _resendOtp,
                          child: Text(
                            "Resend OTP",
                            style: text14(
                              fontWeight: FontWeight.w600,
                            ).copyWith(color: const Color(0xFF1A1A1A)),
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            style: text14().copyWith(
                              color: const Color(0xFF7A7670),
                            ),
                            children: [
                              const TextSpan(text: "Didn't receive it? "),
                              TextSpan(
                                text: "Resend in ${_secondsRemaining}s",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9E9A94),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                const SizedBox(height: 32),

                // ── Verify button ─────────────────────────────
                Obx(
                  () => _DarkButton(
                    label: "Verify & Continue",
                    isLoading: controller.isLoading.value,
                    onTap: () {
                      controller.verifyOtp(phone);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // ── Security note ─────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEAE3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 18,
                        color: Color(0xFF3D9C6E),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: text12().copyWith(
                              color: const Color(0xFF5A5651),
                              height: 1.5,
                            ),
                            children: const [
                              TextSpan(text: "OTP is valid for "),
                              TextSpan(
                                text: "10 minutes",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              TextSpan(text: ". Never share it with anyone."),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _DarkButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _DarkButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading ? const Color(0xFF555555) : AppColors.primary,
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
                    label,
                    style: text16(
                      color: AppColors.white,

                      fontWeight: FontWeight.w600,
                    ).copyWith(letterSpacing: 0.3),
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

class _OtpBox extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 46,
        height: 56,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          maxLength: 1,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4E1DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4E1DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
