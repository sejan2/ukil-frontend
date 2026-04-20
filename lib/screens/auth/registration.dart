import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  String selectedRole = "user";

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff38ef7d), Color(0xff38ef7d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 ROLE SELECT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("User"),
                        selected: selectedRole == "user",
                        selectedColor: Colors.green,
                        onSelected: (_) {
                          setState(() => selectedRole = "user");
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("Advocate"),
                        selected: selectedRole == "advocate",
                        selectedColor: Colors.green,
                        onSelected: (_) {
                          setState(() => selectedRole = "advocate");
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// NAME
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "Full Name",
                      prefixIcon: Icon(Icons.person, color: Colors.green),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// EMAIL
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email, color: Colors.green),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// PHONE
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      hintText: "Phone",
                      prefixIcon: Icon(Icons.phone, color: Colors.green),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock, color: Colors.green),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 REGISTER BUTTON (FIXED)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              /// 🔥 BASIC VALIDATION
                              if (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  phoneController.text.isEmpty ||
                                  passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("All fields are required"),
                                  ),
                                );
                                return;
                              }

                              /// 🔥 CALL API WITH ROLE
                              final success = await auth.registerUser(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                phone: phoneController.text.trim(),
                                password: passwordController.text.trim(),
                                role: selectedRole, // ✅ FIXED
                              );

                              /// ❌ FAIL
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Registration Failed"),
                                  ),
                                );
                                return;
                              }

                              /// ✅ SUCCESS MESSAGE
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    selectedRole == "advocate"
                                        ? "Registered! Waiting for admin approval"
                                        : "Registration Successful",
                                  ),
                                ),
                              );

                              /// 🔥 NAVIGATION
                              Navigator.pushReplacementNamed(
                                context,
                                selectedRole == "advocate"
                                    ? AppRoutes.advocate
                                    : AppRoutes.client,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("CREATE ACCOUNT"),
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
