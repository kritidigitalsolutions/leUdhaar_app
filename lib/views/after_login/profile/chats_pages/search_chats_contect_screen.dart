import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/textstyle.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:leudaar_app/view_model/after_login/leUdhaar_controller/chat_controller.dart';
import 'package:leudaar_app/views/custom_widget/custom_widget.dart';

class ChatSearchScreen extends StatelessWidget {
  ChatSearchScreen({super.key});

  final controller = Get.put(ChatSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 55, 16, 10),
            child: Row(
              children: [
                backButton(),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      style: text15(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search by name...",
                        hintStyle: text15(color: AppColors.white70),
                        border: InputBorder.none,
                        icon: const Icon(
                          Icons.search,
                          color: AppColors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // White Content Area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: AppColors.white),
              child: Obx(
                () => ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Recent Searches
                    if (controller.searchController.text.isEmpty) ...[
                      Text(
                        "Recent searches",
                        style: text15(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      ...controller.recentSearches.map(
                        (name) => _recentSearchItem(name),
                      ),

                      const SizedBox(height: 24),
                    ],

                    // All Contacts
                    Text(
                      "All contacts on Le Udhaar",
                      style: text15(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // if (controller.filteredContacts.isEmpty)
                    //   const Center(
                    //     child: Padding(
                    //       padding: EdgeInsets.all(30),
                    //       child: Text("No contacts found"),
                    //     ),
                    //   )
                    // else
                    //   ...controller.filteredContacts.map(
                    //     (contact) => _contactItem(contact),
                    //   ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentSearchItem(String name) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name, style: text16()),
      trailing: const Icon(Icons.close, size: 20, color: AppColors.grey),
      onTap: () {
        controller.searchController.text = name;
      },
    );
  }

  Widget _contactItem(Contact contact) {
    final name = contact.displayName ?? "Unknown";
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primary,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "A",
          style: text16(fontWeight: FontWeight.w600, color: AppColors.white),
        ),
      ),
      title: Text(name, style: text16(fontWeight: FontWeight.w600)),
      subtitle: const Text(
        "Online",
        style: TextStyle(color: Color(0xFF27AE60)),
      ),
      onTap: () {
        controller.addToRecentSearch(name);
        Get.toNamed(AppRoutes.myChatPage, arguments: name);
      },
    );
  }
}
