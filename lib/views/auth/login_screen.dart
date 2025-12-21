import 'package:flutter/material.dart';
import 'package:news_app/views/auth/signUp_screen.dart';
import 'package:provider/provider.dart';

import '../../view_models/db_view_model.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_snack_bar.dart';
import '../home/main_controller.dart';
import 'forgot_password_screen.dart';

/// The primary entry point for users.
/// Handles Form Validation, Authentication State, and Navigation to the main app.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to retrieve user input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // FocusNodes help us manage keyboard behavior (e.g., moving next, or closing it)
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Handles the login submission logic.
  Future<void> _handleLogin() async {
    // UX: Dismiss the keyboard immediately so the user sees the loading state clearly
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Access the ViewModel without listening to changes (read-only) for the function call
      final dbVM = context.read<DbViewModel>();

      final success = await dbVM.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Async Safety: Ensure the widget is still on screen before navigating
      if (!mounted) return;

      if (success) {
        // Use pushReplacement to prevent user from going "back" to the login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainController()),
        );
      } else {
        CustomSnackBar.showError(context, "Invalid email or password");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to ViewModel changes to update UI (Loading Spinner, Password Visibility)
    final dbViewModel = context.watch<DbViewModel>();
    final isLoading = dbViewModel.isLoading;
    final isPasswordVisible = dbViewModel.isLoginPasswordVisible;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide back button
        actionsPadding: const EdgeInsets.only(right: 15, top: 10),
        actions: [
          // --- Guest Mode / Skip Button ---
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainController()),
              );
            },
            style: OutlinedButton.styleFrom(backgroundColor: Colors.indigo),
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
      // GestureDetector ensures the keyboard closes if the user taps the background
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          // SingleChildScrollView prevents "Bottom Overflow" errors when keyboard rises
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Header Section ---
                    Image.asset("assets/logo.png", width: 140, height: 140),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Login to continue exploring news",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    // --- Input Fields ---
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      autofocus: false,
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
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !isPasswordVisible, // Toggles text masking
                      autofocus: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
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
                            // Toggle state in ViewModel to keep UI logic clean
                            context
                                .read<DbViewModel>()
                                .toggleLoginPasswordVisibility();
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

                    // --- Forgot Password Link ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // --- Login Action ---
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
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
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    // --- Footer / Sign Up Link ---
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
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
