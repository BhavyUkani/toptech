import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../../../core/widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<AuthController>();
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 seconds pulse cycle
    )..repeat(reverse: true); // Smooth back-and-forth glow pulse
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        // Static diagonal gradient background (#1C2452 to #FE6420)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 4, 10, 48), // Deep gradient top
              Color.fromARGB(255, 17, 24, 63), // Mid navy
              Color(0xFFFE6420), // Bottom Right Orange
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Scrollable central form area
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 24.0,
                    ),
                    child: SizedBox(
                      width: size.width > 500 ? 385 : double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Brand Logo Card with border radius 12
                          Center(
                            child: Container(
                              height: 90,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1F000000),
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Welcome Title text
                          const Center(
                            child: Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Center(
                            child: Text(
                              'Sign in to access your dashboard',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Outlined input field (Username/Email/Mobile) - Compact
                          CustomTextField(
                            controller: controller.identifierController,
                            labelText: 'Username, Email or Mobile',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),

                          // Outlined input field (Password) - Compact
                          Obx(
                            () => CustomTextField(
                              controller: controller.passwordController,
                              labelText: 'Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: controller.obscurePassword.value,
                              suffixIcon: IconButton(
                                iconSize: 18,
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white70,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Forgot Password Text Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Get.snackbar(
                                  'Forgot Password',
                                  'Please contact your system administrator to retrieve your credentials.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF1C2452),
                                  colorText: Colors.white,
                                  borderRadius: 12,
                                  margin: const EdgeInsets.all(16),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Simple Material Theme Elevated Button of color #1C2452 with layout fixes
                          Obx(
                            () => SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => controller.login(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1C2452),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0x661C2452,
                                  ),
                                  elevation:
                                      3, // Elevated standard Material style
                                  padding: EdgeInsets
                                      .zero, // Override global theme padding clipping text
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors
                                              .white, // Explicit white color
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Glowing slogan stuck to the bottom of the screen inside double quotes ""
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Oscillates dynamic glow radius between 4.0 and 14.0
                      final val = _animationController.value;
                      final glowRadius = 4.0 + (10.0 * val);

                      return Text(
                        '"Your Trusted Tech Partner"', // Inside ""
                        style: TextStyle(
                          color: const Color(0xE6FFFFFF), // ~90% opacity white
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFE6420), // Orange glow
                              blurRadius: glowRadius,
                            ),
                            Shadow(
                              color: const Color(0xFF1C2452), // Blue glow
                              blurRadius: glowRadius / 1.5,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
