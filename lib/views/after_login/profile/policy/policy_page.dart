import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/profile_controller/policy_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

enum PolicyType { terms, privacyPolicy }

class PolicyPage extends StatefulWidget {
  final PolicyType type;
  const PolicyPage({super.key, required this.type});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  final PolicyController _controller = Get.put(PolicyController());

  String get _apiType =>
      widget.type == PolicyType.terms ? 'terms' : 'privacy-policy';

  String get _title =>
      widget.type == PolicyType.terms ? 'Terms & Conditions' : 'Privacy Policy';

  @override
  void initState() {
    super.initState();
    _controller.fetchPolicy(_apiType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          backButton(),
          const SizedBox(width: 8),
          Text(
            _title,
            style: text18(fontWeight: FontWeight.bold, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final response = _controller.policyResponse.value;

      // ── Loading ────────────────────────────────────────────
      if (response.status == Status.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      // ── Error ──────────────────────────────────────────────
      if (response.status == Status.error) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                response.message ?? 'Something went wrong',
                style: text14(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _controller.fetchPolicy(_apiType),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Retry', style: text14(color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // ── No data ────────────────────────────────────────────
      final data = response.data?.data;
      if (data == null) {
        return Center(
          child: Text(
            'No data available',
            style: text14(color: AppColors.textSecondary),
          ),
        );
      }

      // ── Content ────────────────────────────────────────────
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Meta chip row ──────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (data.effectiveDate != null)
                _MetaChip(
                  icon: Icons.calendar_today_outlined,
                  label: 'Effective: ${data.effectiveDate!}',
                ),
              if (data.version != null)
                _MetaChip(
                  icon: Icons.new_releases_outlined,
                  label: 'v${data.version!}',
                ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Title ──────────────────────────────────────────
          if (data.title != null) ...[
            Text(
              data.title!,
              style: text18(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ).copyWith(letterSpacing: 0.2),
            ),
            const SizedBox(height: 16),
          ],

          // ── Content Card ───────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withOpacity(0.12)),
            ),
            child: Text(
              data.content ?? '',
              style: text13(color: AppColors.textPrimary).copyWith(height: 1.7),
            ),
          ),

          const SizedBox(height: 40),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════
// Sub-widget
// ═══════════════════════════════════════════════

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(label, style: text12(color: AppColors.primary)),
        ],
      ),
    );
  }
}
