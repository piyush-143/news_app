import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/db_view_model.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_snack_bar.dart';

/// A screen that handles the password recovery process in two distinct stages:
/// 1. **Verification Stage:** Checks if the email exists in the database.
/// 2. **Reset Stage:** Allows the user to set a new password if verification passes.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus Nodes (for managing keyboard focus)
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _confirmPassFocusNode = FocusNode();

  // --- UI State ---
  // 0 = Verify Email, 1 = Reset Password
  int _currentStage = 0;
  String? _verifiedEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _confirmPassFocusNode.dispose();
    super.dispose();
  }

  // --- Logic: Stage 1 (Verify Email) ---

  Future<void> _handleVerifyEmail() async {
    // Dismiss keyboard first for better UX
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final dbVM = context.read<DbViewModel>();

      // Check if user exists in DB
      final exists = await dbVM.checkEmailExists(_emailController.text.trim());

      // Async Safety: Ensure widget is still on screen before updating UI
      if (!mounted) return;

      if (exists) {
        setState(() {
          _verifiedEmail = _emailController.text.trim();
          _currentStage = 1; // Move to next stage
        });
        CustomSnackBar.showSuccess(
          context,
          "Email verified. Set new password.",
        );
      } else {
        CustomSnackBar.showError(context, "Email not found in our records.");
      }
    }
  }

  // --- Logic: Stage 2 (Reset Password) ---

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Manual validation check for matching passwords
      if (_passwordController.text != _confirmPasswordController.text) {
        CustomSnackBar.showError(context, "Passwords do not match");
        return;
      }

      final dbVM = context.read<DbViewModel>();
      final success = await dbVM.resetPassword(
        _verifiedEmail!,
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        CustomSnackBar.showSuccess(
          context,
          "Password reset successful! Please Login.",
        );
        Navigator.pop(context); // Close screen and return to Login
      } else {
        CustomSnackBar.showError(context, "Failed to reset password.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch for state changes to update UI (loading spinners, visibility toggles)
    final isLoading = context.watch<DbViewModel>().isLoading;
    final dbVM = context.watch<DbViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password"), centerTitle: true),
      body: GestureDetector(
        // Dismiss keyboard when tapping outside input fields
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    size: 80,
                    color: isDark ? Colors.white : Colors.indigo,
                  ),
                  const SizedBox(height: 30),

                  // Conditional UI Rendering based on Stage
                  if (_currentStage == 0) ...[
                    // ==========================================
                    // STAGE 0: Email Verification Form
                    // ==========================================
                    const Text(
                      "Forgot Password?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter your email to verify your account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) return 'Invalid email format';
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: "Enter Email Address",
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: isLoading ? null : _handleVerifyEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CustomLoader(color: Colors.white, size: 30)
                          : const Text(
                              "Verify Email",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ] else ...[
                    // ==========================================
                    // STAGE 1: New Password Form
                    // ==========================================
                    Text(
                      "Reset for $_verifiedEmail",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passFocusNode,
                      obscureText: !dbVM.isForgotPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter new password';
                        }
                        if (value.length < 6) return 'Min 6 characters';
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            dbVM.isForgotPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            context
                                .read<DbViewModel>()
                                .toggleForgotPasswordVisibility();
                          },
                        ),
                        hintText: "New Password",
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPassFocusNode,
                      obscureText: !dbVM.isForgotConfirmPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm new password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_clock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            dbVM.isForgotConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            context
                                .read<DbViewModel>()
                                .toggleForgotConfirmPasswordVisibility();
                          },
                        ),
                        hintText: "Confirm Password",
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Reset Action Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Green signifies completion
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CustomLoader(color: Colors.white, size: 30)
                          : const Text(
                              "Reset Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),

                    // Back Button (Cancel Stage 1)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentStage = 0;
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      child: const Text("Use different email"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
