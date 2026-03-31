import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/size_config.dart';
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
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final authVM = context.read<FirebaseAuthViewModel>();

      final success = await authVM.loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainController()),
        );
      } else {
        final error = authVM.errorMessage ?? "Login failed. Please try again.";
        CustomSnackBar.showError(context, error);
      }
    } else {
      CustomSnackBar.showError(context, "Invalid email or password");
    }
  }

  Future<void> _googleLogin() async {
    final authVM = context.read<FirebaseAuthViewModel>();
    final success = await authVM.googleSignIn();

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainController()),
      );
    } else {
      final error = authVM.errorMessage ?? "Login failed. Please try again.";
      CustomSnackBar.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authVM = context.watch<FirebaseAuthViewModel>();
    final isLoading = authVM.isLoading;
    final isPasswordVisible = context.watch<ToggleViewModel>().isLoginPasswordVisible;

    final googleBtnBg = isDark ? Colors.grey.shade800 : Colors.white;
    final googleBtnBorder = Colors.grey.shade500;
    final googleBtnText = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actionsPadding: EdgeInsets.only(right: 15.w, top: 10.h),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainController()),
              );
            },
            style: OutlinedButton.styleFrom(backgroundColor: Colors.indigo),
            child: Text(
              "Skip",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(11.w),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.indigo.shade100.withAlpha(150),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        "assets/logo.png",
                        width: 140.w,
                        height: 140.w,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.newspaper,
                          size: 100.w,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Login to continue exploring news",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                    SizedBox(height: 30.h),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 14.sp),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your email';
                        if (!value.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined, size: 20.w),
                        hintText: "Email",
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.w),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 14.sp),
                      onFieldSubmitted: (_) => _login(),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your password';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, size: 20.w),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            size: 20.w,
                          ),
                          onPressed: () {
                            context.read<ToggleViewModel>().toggleLoginPasswordVisibility();
                          },
                        ),
                        hintText: "Password",
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.w),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child: isLoading
                          ? CustomLoader(color: Colors.white, size: 24.w)
                          : Text(
                              "Login",
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            "OR",
                            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500, fontSize: 12.sp),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    InkWell(
                      onTap: isLoading ? null : _googleLogin,
                      borderRadius: BorderRadius.circular(12.w),
                      child: Container(
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: googleBtnBg,
                          border: Border.all(color: googleBtnBorder),
                          borderRadius: BorderRadius.circular(12.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? CustomLoader(color: Colors.indigo, size: 24.w)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/google_logo.png",
                                    height: 22.w,
                                    width: 22.w,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 26.w,
                                        height: 26.w,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.indigo,
                                        ),
                                        child: Text(
                                          "G",
                                          style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    "Continue with Google",
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: googleBtnText),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: TextStyle(fontSize: 13.sp)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupScreen()),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 14.sp),
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
