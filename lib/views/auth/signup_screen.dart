import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/db_view_model.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_snack_bar.dart';
import '../home/main_controller.dart';

/// Handles new user registration.
/// Captures Name, Email, and Password to create a local account.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // FocusNodes for managing keyboard focus interactions
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    // Prevent memory leaks by disposing controllers and nodes
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Validates form and attempts to create a new user in the local DB.
  Future<void> _handleSignUp() async {
    // UX: Dismiss keyboard immediately to show the loading state clearly
    FocusScope.of(context).requestFocus(FocusNode());

    if (_formKey.currentState!.validate()) {
      final dbVM = context.read<DbViewModel>();

      final success = await dbVM.signup(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      // Async Safety Check
      if (!mounted) return;

      if (success) {
        // Navigation: Use pushAndRemoveUntil to clear the navigation stack.
        // This prevents the user from hitting "Back" and returning to the Signup/Login screens.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainController()),
          (route) => false,
        );
      } else {
        CustomSnackBar.showError(
          context,
          "Registration failed. Email might already exist.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to ViewModel for loading state and password visibility toggles
    final dbViewModel = context.watch<DbViewModel>();
    final isLoading = dbViewModel.isLoading;
    final isPasswordVisible = dbViewModel.isSignupPasswordVisible;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Custom back flow handled via buttons
        actionsPadding: const EdgeInsets.only(right: 15, top: 10),
        actions: [
          // --- Skip Button (Guest Mode) ---
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainController()),
              );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.indigo,
              alignment: Alignment.topCenter,
            ),
            child: const Text(
              "Skip",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      // GestureDetector closes keyboard when tapping background
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          // SingleChildScrollView prevents "Bottom Overflow" when keyboard appears
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24, bottom: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Header ---
                    Image.asset("assets/logo.png", width: 140, height: 140),
                    const SizedBox(height: 20),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Join us and stay updated with the latest news",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    // --- Name Field ---
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: "Full Name",
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

                    // --- Email Field ---
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: "Email",
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

                    // --- Password Field ---
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !isPasswordVisible, // Toggles masking
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            // Toggle visibility in ViewModel state
                            context
                                .read<DbViewModel>()
                                .toggleSignupPasswordVisibility();
                          },
                        ),
                        hintText: "Password",
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

                    // --- Sign Up Button ---
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CustomLoader(color: Colors.white, size: 40)
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    // --- Footer / Login Link ---
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            // Close keyboard before navigating back
                            FocusScope.of(context).requestFocus(FocusNode());
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
