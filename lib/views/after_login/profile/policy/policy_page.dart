import 'package:flutter/material.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

enum PolicyType { terms, privacy }

class PolicyPage extends StatelessWidget {
  final PolicyType type;
  const PolicyPage({super.key, required this.type});

  String get _title =>
      type == PolicyType.terms ? 'Terms & Conditions' : 'Privacy Policy';

  List<_PolicySection> get _sections =>
      type == PolicyType.terms ? _termsSections : _privacySections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildContent()),
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

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Last updated chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Last updated: January 1, 2025',
            style: text12(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 20),

        // Sections list
        ..._sections.map((s) => _buildSection(s)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSection(_PolicySection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(section.icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: text14(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            section.body,
            style: text13(color: AppColors.grey600).copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Data model ─────────────────────────────────────────
class _PolicySection {
  final String title;
  final String body;
  final IconData icon;
  const _PolicySection({
    required this.title,
    required this.body,
    required this.icon,
  });
}

// ── Terms & Conditions content ──────────────────────────
const _termsSections = [
  _PolicySection(
    icon: Icons.handshake_outlined,
    title: 'Acceptance of Terms',
    body:
        'By accessing or using Leudaar, you agree to be bound by these Terms. If you do not agree, please do not use our services.',
  ),
  _PolicySection(
    icon: Icons.manage_accounts_outlined,
    title: 'User Responsibilities',
    body:
        'You are responsible for maintaining the confidentiality of your account credentials. Any activity under your account is your responsibility. You must be 18+ to use this app.',
  ),
  _PolicySection(
    icon: Icons.currency_rupee_rounded,
    title: 'Transactions & Payments',
    body:
        'All financial transactions through Leudaar are subject to verification. We are not liable for any failed transactions due to incorrect information provided by the user.',
  ),
  _PolicySection(
    icon: Icons.block_outlined,
    title: 'Prohibited Activities',
    body:
        'Users may not misuse the platform for fraud, money laundering, impersonation, or any illegal activity. Violation will result in immediate account suspension.',
  ),
  _PolicySection(
    icon: Icons.update_outlined,
    title: 'Changes to Terms',
    body:
        'We reserve the right to update these Terms at any time. Continued use of the app after changes constitutes acceptance of the new Terms.',
  ),
];

// ── Privacy Policy content ──────────────────────────────
const _privacySections = [
  _PolicySection(
    icon: Icons.info_outline_rounded,
    title: 'Information We Collect',
    body:
        'We collect name, phone number, email, device info, and transaction data necessary to provide our services. We do not collect data beyond what is required.',
  ),
  _PolicySection(
    icon: Icons.settings_suggest_outlined,
    title: 'How We Use Your Data',
    body:
        'Your data is used to operate the app, process transactions, send notifications, and improve our services. We never sell your personal data to third parties.',
  ),
  _PolicySection(
    icon: Icons.share_outlined,
    title: 'Data Sharing',
    body:
        'We may share data with trusted payment partners and regulatory authorities as required by law. All partners are bound by strict confidentiality agreements.',
  ),
  _PolicySection(
    icon: Icons.lock_outline_rounded,
    title: 'Data Security',
    body:
        'We use industry-standard encryption (TLS/SSL) to protect your data in transit and at rest. Access to personal data is strictly limited to authorized personnel.',
  ),
  _PolicySection(
    icon: Icons.person_remove_outlined,
    title: 'Your Rights',
    body:
        'You may request access, correction, or deletion of your personal data at any time by contacting support@leudaar.com. We will respond within 30 days.',
  ),
];
