import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/social_button.dart';

import '../../authentication/models/user_model.dart';
import '../../authentication/services/auth_service.dart';

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

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Simulate authentication request
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    // ==========================================================
    // DEMO USERS
    // ==========================================================

    UserModel? user;

    switch (email) {
      case 'admin@vaxitrack.com':
        user = const UserModel(
          id: 'USR001',
          name: 'System Admin',
          email: 'admin@vaxitrack.com',
          role: UserRole.admin,
        );
        break;

      case 'warehouse@vaxitrack.com':
        user = const UserModel(
          id: 'USR002',
          name: 'Warehouse Staff',
          email: 'warehouse@vaxitrack.com',
          role: UserRole.warehouseStaff,
        );
        break;

      case 'sales@vaxitrack.com':
        user = const UserModel(
          id: 'USR003',
          name: 'Sales Representative',
          email: 'sales@vaxitrack.com',
          role: UserRole.salesRepresentative,
        );
        break;

      case 'facility@vaxitrack.com':
        user = const UserModel(
          id: 'USR004',
          name: 'Facility Staff',
          email: 'facility@vaxitrack.com',
          role: UserRole.facilityStaff,
        );
        break;

      case 'pharmacist@vaxitrack.com':
        user = const UserModel(
          id: 'USR005',
          name: 'Pharmacist',
          email: 'pharmacist@vaxitrack.com',
          role: UserRole.pharmacist,
        );
        break;
    }

    // ==========================================================
    // INVALID USER
    // ==========================================================

    if (user == null) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email. Please use one of the demo accounts.'),
        ),
      );

      return;
    }

    // ==========================================================
    // PASSWORD CHECK
    // ==========================================================

    if (password.length < 6) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must contain at least 6 characters.'),
        ),
      );

      return;
    }

    // ==========================================================
    // SAVE CURRENT USER
    // ==========================================================

    _authService.login(user);

    setState(() {
      isLoading = false;
    });

    // ==========================================================
    // SUCCESS MESSAGE
    // ==========================================================

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome ${user.name} (${user.roleName})')),
    );

    // ==========================================================
    // NAVIGATE TO DASHBOARD
    // ==========================================================

    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  // ============================================================
  // BUILD
  // ============================================================

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

                  // ==================================================
                  // LOGO
                  // ==================================================
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

                  // ==================================================
                  // TITLE
                  // ==================================================
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

                  // ==================================================
                  // EMAIL
                  // ==================================================
                  CustomTextField(
                    controller: emailController,
                    labelText: "Email",
                    hintText: "Enter your email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter email";
                      }

                      if (!value.contains("@")) {
                        return "Invalid email";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // PASSWORD
                  // ==================================================
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

                  // ==================================================
                  // FORGOT PASSWORD
                  // ==================================================
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

                  // ==================================================
                  // LOGIN BUTTON
                  // ==================================================
                  PrimaryButton(
                    text: "Login",
                    isLoading: isLoading,
                    onPressed: loginUser,
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // DIVIDER
                  // ==================================================
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

                  // ==================================================
                  // GOOGLE
                  // ==================================================
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

                  // ==================================================
                  // FACEBOOK
                  // ==================================================
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

                  // ==================================================
                  // SIGN UP
                  // ==================================================
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

                  // ==================================================
                  // DEMO LOGIN INFORMATION
                  // ==================================================
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: const [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.primary),

                            SizedBox(width: 8),

                            Text(
                              "Demo Accounts",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        Text(
                          "admin@vaxitrack.com",
                          style: TextStyle(fontSize: 12),
                        ),

                        Text(
                          "warehouse@vaxitrack.com",
                          style: TextStyle(fontSize: 12),
                        ),

                        Text(
                          "sales@vaxitrack.com",
                          style: TextStyle(fontSize: 12),
                        ),

                        Text(
                          "facility@vaxitrack.com",
                          style: TextStyle(fontSize: 12),
                        ),

                        Text(
                          "pharmacist@vaxitrack.com",
                          style: TextStyle(fontSize: 12),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Password: any password with 6+ characters",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
