import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/social_button.dart';
import '../../../app/app_routes.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    // Simulate login request
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    /*
     * TEMPORARY USER
     *
     * Later this will come from Firebase/database.
     */
    const user = UserModel(
      id: 'USR001',
      name: 'Krish',
      email: 'krish@gmail.com',
      role: UserRole.admin,
    );

    // Save logged-in user
    AuthService().login(user);

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login Successful - ${user.roleName}')),
    );

    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 40),

                  Center(
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.vaccines,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Center(
                    child: Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      "Monitor vaccines safely",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),

                  const SizedBox(height: 40),

                  CustomTextField(
                    controller: emailController,
                    labelText: "Email",
                    hintText: "Enter your email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter email";
                      }

                      if (!value.contains("@")) {
                        return "Invalid email";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: passwordController,
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter password";
                      }

                      if (value.length < 6) {
                        return "Minimum 6 characters";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.forgotPassword);
                      },
                      child: const Text("Forgot Password?"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  PrimaryButton(
                    text: "Login",
                    isLoading: isLoading,
                    onPressed: loginUser,
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: const [
                      Expanded(child: Divider()),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text("OR"),
                      ),

                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SocialButton(
                    text: "Continue with Google",
                    iconPath: "assets/icons/google logo.png",
                    borderColor: Colors.red,
                    textColor: Colors.red,
                    onPressed: () {
                      // TODO: Google Login
                    },
                  ),

                  const SizedBox(height: 16),

                  SocialButton(
                    text: "Continue with Facebook",
                    iconPath: "assets/icons/facebook logo.png",
                    borderColor: Colors.blue,
                    textColor: Colors.blue,
                    onPressed: () {
                      // TODO: Facebook Login
                    },
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 15),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.signup);
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
