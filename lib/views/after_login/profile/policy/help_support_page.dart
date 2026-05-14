import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/policy_models/policy_res_model.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/profile_controller/policy_controller.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final PolicyController _controller = Get.put(PolicyController());

  @override
  void initState() {
    super.initState();
    _controller.fetchHelpData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Help & Support',
          style: text18(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ).copyWith(letterSpacing: 0.2),
        ),
      ),
      body: Obx(() {
        final response = _controller.helpSupResponse.value;

        if (response.status == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

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
                  style: text14(color: AppColors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _controller.fetchHelpData,
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

        final data = response.data?.data;
        if (data == null) {
          return const Center(child: Text('No data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Card ──────────────────────────────────────────
              _HeaderCard(title: data.title, description: data.description),

              const SizedBox(height: 16),

              // ── Contact Section ───────────────────────────────────────
              _SectionLabel(label: 'Contact Us'),
              const SizedBox(height: 10),
              _ContactTile(
                icon: Icons.email_outlined,
                label: 'Email Support',
                value: data.supportEmail,
                onTap: () {}, // _launchEmail(data.supportEmail),
              ),
              const SizedBox(height: 10),
              _ContactTile(
                icon: Icons.phone_outlined,
                label: 'Phone Support',
                value: data.supportPhone,
                onTap: () {}, // _launchPhone(data.supportPhone),
              ),
              if (data.availability != null) ...[
                const SizedBox(height: 10),
                _AvailabilityBanner(text: data.availability!),
              ],

              const SizedBox(height: 24),

              // ── FAQs ──────────────────────────────────────────────────
              if (data.faqs.isNotEmpty) ...[
                _SectionLabel(label: 'Frequently Asked Questions'),
                const SizedBox(height: 10),
                _FaqList(faqs: data.faqs),
              ],

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // void _launchEmail(String? email) async {
  //   if (email == null) return;
  //   final uri = Uri(scheme: 'mailto', path: email);
  //   if (await canLaunchUrl(uri)) launchUrl(uri);
  // }

  // void _launchPhone(String? phone) async {
  //   if (phone == null) return;
  //   final uri = Uri(scheme: 'tel', path: phone);
  //   if (await canLaunchUrl(uri)) launchUrl(uri);
  // }
}

// ═══════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({this.title, this.description});
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withAlpha(100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title ?? 'Help & Support',
                  style: text18(
                    color: AppColors.white,

                    fontWeight: FontWeight.w700,
                  ).copyWith(letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              style: text13(
                color: AppColors.textSecondary,
              ).copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: text14(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ).copyWith(letterSpacing: 0.2),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.05),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: text12(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? '—',
                    style: text15(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityBanner extends StatelessWidget {
  const _AvailabilityBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: text13(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList({required this.faqs});
  final List<Faq> faqs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: List.generate(faqs.length, (i) {
            final faq = faqs[i];
            return Column(
              children: [
                _FaqTile(question: faq.question, answer: faq.answer),
                if (i < faqs.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({this.question, this.answer});
  final String? question;
  final String? answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: _expanded ? AppColors.primary.withOpacity(0.03) : AppColors.white,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        onExpansionChanged: (v) => setState(() => _expanded = v),
        trailing: AnimatedRotation(
          turns: _expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
        title: Text(
          widget.question ?? '',
          style: text14(
            fontWeight: FontWeight.w600,
            color: _expanded ? AppColors.textSecondary : AppColors.black87,
          ),
        ),
        children: [
          Text(
            widget.answer ?? '',
            style: text13(color: AppColors.textPrimary).copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}
