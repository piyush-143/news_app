import 'dart:io';

import 'package:flutter/material.dart';
import 'package:news_app/view_models/index_view_model.dart';
import 'package:provider/provider.dart';

import '../../utils/size_config.dart';
import '../../view_models/firebase_auth_view_model.dart';
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
    final tileBgColor = isDark ? Colors.grey.shade900 : Colors.white;

    return Consumer2<ThemeViewModel, FirebaseAuthViewModel>(
      builder: (context, themeVM, fbVM, child) {
        final localPath = fbVM.profileImagePath;
        bool localFileExists = false;
        if (localPath != null && localPath.isNotEmpty) {
          localFileExists = File(localPath).existsSync();
        }

        final networkUrl = fbVM.currentUser?.photoURL;

        ImageProvider? imageProvider;
        if (localFileExists) {
          imageProvider = ResizeImage(FileImage(File(localPath!)), width: 100);
        } else if (networkUrl != null && networkUrl.isNotEmpty) {
          imageProvider = NetworkImage(networkUrl);
        }

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 24.w,
            title: Text("Settings", style: TextStyle(fontSize: 24.sp)),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 24.w),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 22.w,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.indigo.shade50,
                    backgroundImage: imageProvider,
                    child: (imageProvider == null)
                        ? Icon(
                            Icons.person,
                            size: 25.w,
                            color: isDark ? Colors.white : Colors.indigo,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.indigo.shade100,
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
                            size: 60.w,
                            color: isDark ? Colors.grey.shade400 : Colors.indigo,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "News App",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Your Daily Dose of News",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),

              _buildSectionHeader(textColor, "Preferences"),
              Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: tileBgColor,
                  borderRadius: BorderRadius.circular(16.w),
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
                      fontSize: 16.sp,
                    ),
                  ),
                  secondary: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.indigo.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      themeVM.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: themeVM.isDarkMode ? Colors.white : Colors.orange,
                      size: 22.w,
                    ),
                  ),
                  value: themeVM.isDarkMode,
                  onChanged: (val) => themeVM.toggleTheme(val),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  activeTrackColor: Colors.indigo.shade200,
                  activeThumbColor: Colors.indigo,
                  inactiveTrackColor: Colors.grey.shade300,
                  inactiveThumbColor: Colors.grey.shade500,
                ),
              ),

              SizedBox(height: 10.h),

              _buildSectionHeader(textColor, "Support"),

              _buildOptionTile(
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                isDark: isDark,
                textColor: textColor,
                iconColor: iconColor,
                onTap: () => CustomSnackBar.showInfo(context, "Coming Soon!"),
              ),
              _buildOptionTile(
                icon: Icons.policy_outlined,
                title: "Privacy Policy",
                isDark: isDark,
                textColor: textColor,
                iconColor: iconColor,
                onTap: () => CustomSnackBar.showInfo(context, "Coming Soon!"),
              ),
              _buildOptionTile(
                icon: Icons.share_rounded,
                title: "Share App",
                isDark: isDark,
                textColor: textColor,
                iconColor: iconColor,
                onTap: () => CustomSnackBar.showInfo(context, "Sharing not implemented yet"),
              ),

              SizedBox(height: 20.h),

              TextButton(
                onPressed: () async {
                  context.read<IndexViewModel>().reset();
                  await fbVM.logout();
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
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w),
                    side: BorderSide(color: Colors.red.shade700.withAlpha(200)),
                  ),
                  backgroundColor: Colors.red.shade100,
                ),
                child: Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              Center(
                child: Text(
                  "Version 1.0.0",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(Color textColor, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          color: textColor.withAlpha(200),
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required Color textColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16.w),
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
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22.w, color: iconColor),
              ),
              SizedBox(width: 16.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 28.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
