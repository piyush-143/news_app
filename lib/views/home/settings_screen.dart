import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/db_service.dart';
import '../../view_models/db_view_model.dart';
import '../../view_models/theme_view_model.dart';
import '../../widgets/custom_snack_bar.dart';
import '../auth/login_screen.dart';
import '../profile/user_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Consumer2<ThemeViewModel, DbViewModel>(
      builder: (context, themeVM, dbVM, child) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 24,
            title: const Text("Settings"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: GestureDetector(
                  onTap: () {
                    if (dbVM.isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfileScreen(),
                        ),
                      );
                    } else {
                      CustomSnackBar.showInfo(
                        context,
                        "Please login to view profile",
                      );
                    }
                  },
                  child: dbVM.isLoggedIn && dbVM.currentUserEmail != null
                      ? FutureBuilder<Map<String, dynamic>?>(
                          future: DbService.getInstance.getUserDetails(
                            dbVM.currentUserEmail!,
                          ),
                          builder: (context, snapshot) {
                            final imagePath = snapshot.data?['Image'];
                            final hasImage =
                                imagePath != null && imagePath.isNotEmpty;

                            return CircleAvatar(
                              radius: 22,
                              backgroundColor: isDark
                                  ? Colors.grey.shade800
                                  : Colors.indigo.shade50,
                              backgroundImage: hasImage
                                  ? FileImage(File(imagePath))
                                  : null,
                              child: hasImage
                                  ? null
                                  : Icon(
                                      Icons.person,
                                      size: 25,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.indigo,
                                    ),
                            );
                          },
                        )
                      : CircleAvatar(
                          radius: 22,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.indigo.shade50,
                          child: Icon(
                            Icons.person,
                            size: 25,
                            color: isDark ? Colors.white : Colors.indigo,
                          ),
                        ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // --- App Header (Logo) ---
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.indigo.shade100,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withAlpha(40),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Image.asset(
                        "assets/logo.png",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.newspaper_rounded,
                            size: 60,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.indigo,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "News App",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Your Daily Dose of News",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- Preferences Section ---
              _buildSectionHeader(textColor, "Preferences"),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 2 : 30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  title: Text(
                    "Dark Mode",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.indigo.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      themeVM.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: themeVM.isDarkMode ? Colors.white : Colors.orange,
                      size: 22,
                    ),
                  ),
                  value: themeVM.isDarkMode,
                  onChanged: (val) => themeVM.toggleTheme(val),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  activeTrackColor: Colors.indigo.shade200,
                  activeThumbColor: Colors.indigo,
                  inactiveTrackColor: Colors.grey.shade300,
                  inactiveThumbColor: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 10),

              // --- Support Section ---
              _buildSectionHeader(textColor, "Support"),
              _buildOptionTile(
                context,
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                isDark: isDark,
                textColor: textColor,
                iconColor: iconColor,
                onTap: () => CustomSnackBar.showInfo(context, "Coming Soon!"),
              ),
              _buildOptionTile(
                context,
                icon: Icons.policy_outlined,
                title: "Privacy Policy",
                isDark: isDark,
                textColor: textColor,
                iconColor: iconColor,
                onTap: () => CustomSnackBar.showInfo(context, "Coming Soon!"),
              ),
              _buildOptionTile(
                context,
                icon: Icons.share_rounded,
                title: "Share App",
                isDark: isDark,
                textColor: textColor,
                iconColor: iconColor,
                onTap: () => CustomSnackBar.showInfo(
                  context,
                  "Sharing not implemented yet",
                ),
              ),

              const SizedBox(height: 20),

              // --- Conditional Login/Sign Out Button ---
              if (dbVM.isLoggedIn)
                _buildActionButton(
                  label: "Sign Out",
                  textColor: Colors.red.shade700,
                  bgColor: Colors.red.shade100,
                  onPressed: () async {
                    await dbVM.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                )
              else
                _buildActionButton(
                  label: "Login",
                  textColor: Colors.indigo.shade700,
                  bgColor: Colors.indigo.shade100,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),

              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Version 1.0.0",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color textColor,
    required Color bgColor,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: textColor.withAlpha(200)),
        ),
        backgroundColor: bgColor,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(Color textColor, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: textColor.withAlpha(200),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    required Color textColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 2 : 30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
