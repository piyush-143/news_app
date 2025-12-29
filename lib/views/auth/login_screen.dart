import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/firebase_auth_view_model.dart';
import '../../view_models/toggle_view_model.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/custom_snack_bar.dart';
import '../home/main_controller.dart';
import 'forgot_password_screen.dart';
import 'signUp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // FocusNodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final authVM = context.read<FirebaseAuthViewModel>();

      final success = await authVM.loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Async gap check
      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainController()),
        );
      } else {
        // Use the correct property: errorMessage
        final error = authVM.errorMessage ?? "Login failed. Please try again.";
        CustomSnackBar.showError(context, error);
      }
    } else {
      CustomSnackBar.showError(context, "Invalid email or password");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to Firebase ViewModel for loading state
    final authVM = context.watch<FirebaseAuthViewModel>();
    final isLoading = authVM.isLoading;

    // Listen to ToggleViewModel for password visibility
    final isPasswordVisible = context
        .watch<ToggleViewModel>()
        .isLoginPasswordVisible;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Center(
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
                    Image.asset(
                      "assets/logo.png",
                      width: 140,
                      height: 140,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.newspaper,
                        size: 100,
                        color: Colors.indigo,
                      ),
                    ),
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

                    // --- Email Field ---
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                      obscureText: !isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
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
                            context
                                .read<ToggleViewModel>()
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

                    // --- Login Button ---
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: isLoading ? null : _login,
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
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    // --- Sign Up Link ---
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
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
