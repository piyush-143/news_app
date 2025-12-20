import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/db_service.dart';
import '../../view_models/db_view_model.dart';
import '../../widgets/custom_snack_bar.dart';

/// Screen to view and edit the current user's profile details.
/// Features:
/// 1. Profile Picture upload/change.
/// 2. Name and Email editing.
/// 3. Real-time updates from the local SQLite database.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Temporary storage to pre-fill the edit dialog
  String? _currentName;

  /// Displays a popup dialog allowing the user to modify their Name and Email.
  void _showEditDialog(
    BuildContext context,
    String currentName,
    String currentEmail,
    bool isDark,
  ) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);
    final formKey = GlobalKey<FormState>();

    // Theme-dependent colors for the dialog
    final dialogBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final inputFillColor = isDark ? Colors.white12 : Colors.grey.shade200;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBgColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                    controller: nameController,
                    label: "Name",
                    icon: Icons.person_outline,
                    fillColor: inputFillColor,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    fillColor: inputFillColor,
                    textColor: textColor,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 20, right: 20),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Save Button
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final dbVM = context.read<DbViewModel>();

                  // Attempt to update in DB
                  final success = await dbVM.updateProfile(
                    nameController.text.trim(),
                    emailController.text.trim(),
                  );

                  // Async Safety: Check if widget is mounted before using context
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog

                    if (success) {
                      CustomSnackBar.showSuccess(
                        context,
                        "Profile updated successfully",
                      );
                    } else {
                      // This usually happens if the new email is already taken by another user
                      CustomSnackBar.showError(
                        context,
                        "Update failed. Email might be taken.",
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  /// Helper widget for consistent text fields inside the dialog
  TextFormField _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color fillColor,
    required Color textColor,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor),
      maxLines: maxLines,
      validator: (val) => val!.isEmpty ? "$label cannot be empty" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.indigo.shade300),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
        ),
      ),
    );
  }

  /// Triggers the image picker in the ViewModel
  Future<void> _pickImage(BuildContext context) async {
    final dbVM = context.read<DbViewModel>();
    final success = await dbVM.updateProfilePicture();

    if (context.mounted) {
      if (success) {
        CustomSnackBar.showSuccess(context, "Profile picture updated");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch for changes (e.g., if email is updated, this triggers a rebuild)
    final dbVM = context.watch<DbViewModel>();
    final email = dbVM.currentUserEmail ?? "Guest";

    // Theme Colors
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        titleSpacing: 0,
        actionsPadding: const EdgeInsets.only(right: 15),
        actions: [
          // Edit Button in AppBar
          IconButton(
            onPressed: () {
              _showEditDialog(context, _currentName ?? "", email, isDark);
            },
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.indigo.shade50,
            ),
            icon: Icon(
              Icons.edit_rounded,
              color: isDark ? Colors.white : Colors.indigo,
            ),
            tooltip: "Edit Profile",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        // FutureBuilder ensures we fetch the absolute latest data from SQLite
        // every time the UI rebuilds.
        child: FutureBuilder<Map<String, dynamic>?>(
          future: DbService.getInstance.getUserDetails(email),
          builder: (context, snapshot) {
            final data = snapshot.data;
            _currentName = data?['Name'];
            final String? imagePath = data?['Image'];

            // Handle loading vs data state for the Name display
            final displayTitle = snapshot.hasData
                ? (_currentName ?? "No Name")
                : (snapshot.connectionState == ConnectionState.waiting
                      ? "Loading..."
                      : "No Name");

            return Column(
              children: [
                const SizedBox(height: 20),

                // --- Profile Image Section ---
                Center(
                  // Stack allows us to place the "Camera Icon" on top of the Avatar
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // The Main Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.indigo.shade50,
                          backgroundImage:
                              (imagePath != null && imagePath.isNotEmpty)
                              ? FileImage(File(imagePath))
                              : null,
                          child: (imagePath == null || imagePath.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: isDark ? Colors.white : Colors.indigo,
                                )
                              : null,
                        ),
                      ),

                      // The Edit/Camera Badge
                      GestureDetector(
                        onTap: () => _pickImage(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 3,
                            ),
                          ),
                          child: dbVM.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- Info Tiles ---
                _buildInfoTile(
                  "Full Name",
                  displayTitle,
                  Icons.person_outline_rounded,
                  cardColor,
                  textColor,
                ),
                const SizedBox(height: 16),
                _buildInfoTile(
                  "Email Address",
                  email,
                  Icons.email_outlined,
                  cardColor,
                  textColor,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Reusable widget for displaying user details (Name, Email)
  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withAlpha(50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.indigo, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
