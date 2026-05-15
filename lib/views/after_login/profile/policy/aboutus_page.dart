import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/view_model/after_login/profile_controller/policy_controller.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final PolicyController _controller = Get.put(PolicyController());

  @override
  void initState() {
    super.initState();
    _controller.fetchAboutUs();
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
          'About Us',
          style: text18(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ).copyWith(letterSpacing: 0.2),
        ),
      ),
      body: Obx(() {
        final response = _controller.aboutUsRes.value;

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
                  onPressed: _controller.fetchAboutUs,
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
          return Center(
            child: Text(
              'No data available',
              style: text14(color: AppColors.textSecondary),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App Identity Card ─────────────────────────────────────
              _AppIdentityCard(
                appName: data.appName,
                tagline: data.tagline,
                version: data.version,
              ),

              const SizedBox(height: 16),

              // ── Description ───────────────────────────────────────────
              if (data.description != null) ...[
                _SectionLabel(label: 'Who We Are'),
                const SizedBox(height: 10),
                _DescriptionCard(description: data.description!),
                const SizedBox(height: 20),
              ],

              // ── Company Info ──────────────────────────────────────────
              _SectionLabel(label: 'Company Info'),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.business_rounded,
                label: 'Company Name',
                value: data.companyName,
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Contact Email',
                value: data.contactEmail,
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════

class _AppIdentityCard extends StatelessWidget {
  const _AppIdentityCard({this.appName, this.tagline, this.version});
  final String? appName;
  final String? tagline;
  final String? version;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName ?? 'About Us',
                      style: text18(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ).copyWith(letterSpacing: 0.3),
                    ),
                    if (version != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'v${version!}',
                          style: text12(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (tagline != null) ...[
            const SizedBox(height: 14),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tagline!,
                    style: text13(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ).copyWith(height: 1.5, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
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

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        description,
        style: text13(color: AppColors.textPrimary).copyWith(height: 1.6),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
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
                    color: AppColors.textSecondary,
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
        ],
      ),
    );
  }
}
