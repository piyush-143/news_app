import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/firebase_auth_view_model.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_snack_bar.dart';

/// A screen that handles the password recovery process via Firebase.
/// The user enters their email, and Firebase sends a reset link.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controller
  final _emailController = TextEditingController();

  // Focus Node
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    // Dismiss keyboard first for better UX
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final authVM = context.read<FirebaseAuthViewModel>();

      final success = await authVM.forgotPassword(_emailController.text.trim());

      // Async Safety: Ensure widget is still on screen before updating UI
      if (!mounted) return;

      if (success) {
        CustomSnackBar.showSuccess(
          context,
          "Password reset link sent! Please check your email inbox.",
        );
        // Navigate back to login so they can sign in after resetting
        Navigator.pop(context);
      } else {
        final error = authVM.errorMessage ?? "Failed to send reset link.";
        CustomSnackBar.showError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch for state changes to update UI (loading spinners)
    final authVM = context.watch<FirebaseAuthViewModel>();
    final isLoading = authVM.isLoading;

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

                  const Text(
                    "Forgot Password?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your email address below to receive a password reset link.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // --- Email Input ---
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
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

                  // --- Submit Button ---
                  ElevatedButton(
                    onPressed: isLoading ? null : _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CustomLoader(color: Colors.white, size: 24)
                        : const Text(
                            "Send Reset Link",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
