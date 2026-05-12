import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';
import 'package:share_plus/share_plus.dart';

class FindPersonScreen extends StatefulWidget {
  const FindPersonScreen({super.key});

  @override
  State<FindPersonScreen> createState() => _FindPersonScreenState();
}

class _FindPersonScreenState extends State<FindPersonScreen> {
  final TextEditingController _searchController = TextEditingController(
    text: 'Rahul',
  );

  // Search results (on Le'Udhaar)
  final List<Map<String, dynamic>> _searchResults = [
    {
      'initials': 'RV',
      'name': 'Rahul Verma',
      'number': '+91 98765 43210',
      'verified': true,
    },
    {
      'initials': 'RK',
      'name': 'Rahul Kumar',
      'number': '+91 81234 56789',
      'verified': false,
    },
  ];

  // Contacts who are on the app
  final List<Map<String, dynamic>> _contactsOnApp = [
    {'initials': 'AS', 'name': 'Aman Sharma', 'number': '+91 99887 76655'},
    {'initials': 'PK', 'name': 'Priya Kumari', 'number': '+91 70123 45678'},
  ];

  // Contacts who are NOT on the app
  final List<Map<String, dynamic>> _contactsNotOnApp = [
    {'initials': 'RK', 'name': 'Rohit Kumar', 'number': '+91 88997 55443'},
    {'initials': 'NS', 'name': 'Neha Singh', 'number': '+91 66554 33221'},
    {'initials': 'VK', 'name': 'Vikas Kumar', 'number': '+91 55443 22110'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                backButton(),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find a person',
                      style: text18(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Search by name or number',
                      style: text12(color: AppColors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    style: text14(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search name or number',
                      hintStyle: text14(color: AppColors.hintText),
                      filled: true,
                      fillColor: AppColors.white,
                      suffixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.grey300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.grey300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.button,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  // Search Results
                  Text(
                    'Search results',
                    style: text12(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  ..._searchResults.map((r) => _searchResultTile(r)),
                  const SizedBox(height: 24),

                  // Contacts On App
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'From your contacts (On App)',
                    style: text14(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ..._contactsOnApp.map((c) => _contactOnAppTile(c)),

                  const SizedBox(height: 24),

                  // Contacts Not On App
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'From your contacts (Not on App)',
                    style: text14(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ..._contactsNotOnApp.map((c) => _contactNotOnAppTile(c)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Search Result Tile
  Widget _searchResultTile(Map<String, dynamic> result) {
    final bool verified = result['verified'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: verified ? AppColors.button : AppColors.grey200,
          width: verified ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Text(
              result['initials'],
              style: text13(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['name'],
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result['number'],
                  style: text12(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (verified) {
                Get.toNamed(AppRoutes.requestMoneyScreen, arguments: result);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: verified ? AppColors.button : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: verified ? AppColors.button : AppColors.grey300,
                ),
              ),
              child: Text(
                verified ? 'Request' : 'Invite',
                style: text12(
                  fontWeight: FontWeight.w600,
                  color: verified ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Contact On App Tile
  Widget _contactOnAppTile(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.button.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Text(
              contact['initials'],
              style: text13(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'],
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact['number'],
                  style: text12(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                Get.toNamed(AppRoutes.requestMoneyScreen, arguments: contact),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Request',
                style: text12(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Contact NOT On App Tile → Share Referral Link
  // Contact NOT On App Tile
  Widget _contactNotOnAppTile(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Text(
              contact['initials'],
              style: text13(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'],
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact['number'],
                  style: text12(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // WhatsApp Button
          GestureDetector(
            onTap: () => _shareViaWhatsApp(contact),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366), // WhatsApp Green
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'WhatsApp',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Other Share Button
          GestureDetector(
            onTap: () => _shareReferralLink(contact),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Share',
                style: text12(
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Share via WhatsApp ====================
  void _shareViaWhatsApp(Map<String, dynamic> contact) {
    String name = contact['name'] ?? 'Friend';

    String message =
        "Hey $name 👋\n\n"
        "I’ve invited you to join Le’Udhaar — a stress-free & automated platform for lending, borrowing, and repayments.\n\n"
        "Join now using my referral link:\n"
        "https://leudaar.app/refer?user=your_user_id";

    // WhatsApp URL Scheme
    final whatsappUrl = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(message)}",
    );

    // You can launch this URL using url_launcher package
    // For now, we'll use general share with prefilled text
    SharePlus.instance.share(
      ShareParams(text: message, subject: "Join me on Le’Udhaar"),
    );
  }

  // ==================== General Share (Other Apps) ====================
  void _shareReferralLink(Map<String, dynamic> contact) {
    String name = contact['name'] ?? 'Friend';

    String message =
        "Hey $name 👋\n\n"
        "I’ve invited you to join Le’Udhaar — a stress-free & automated platform for lending, borrowing, and repayments.\n\n"
        "Join now using my referral link:\n"
        "https://leudaar.app/refer?user=your_user_id\n\n"
        "Looking forward to seeing you there!";

    SharePlus.instance.share(
      ShareParams(text: message, subject: "Join me on Le’Udhaar"),
    );
  }
}
