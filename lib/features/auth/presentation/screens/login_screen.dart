import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/services/auth_service.dart';
import '../widgets/auth_footer.dart';
import '../widgets/social_login_button.dart';
import 'package:park_chatapp/features/auth/presentation/screens/home_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Handle login with Firebase Auth
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) await showAppErrorDialog(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle forgot password
  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      await showAppInfoDialog(context, 'Please enter your email first');
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (mounted)
        await showAppInfoDialog(
          context,
          'Password reset email sent! Check your inbox.',
        );
    } catch (e) {
      if (mounted) await showAppErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: AppColors.primaryRed,
          child: Center(
            child: Container(
              margin: EdgeInsets.only(
                top: 0.01.sh, // Changed from screenHeight * 0.20
                bottom: 0.02.sh, // Changed from screenHeight * 0.02
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w), // Added .w
              child: Card(
                color: AppColors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r), // Added .r
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w), // Added .w
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/parkview.png',
                            width: 400.w,
                            height: 50.h,
                          ),
                          SizedBox(height: 18.h), // Added .h
                          CustomTextField(
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h), // Added .h
                          CustomTextField(
                            label: 'Password',
                            obscureText: _obscurePassword,
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 8.h), // Added .h
                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: _handleForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.linkText,
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h), // Added .h
                          CustomButton(
                            text: 'LOGIN',
                            onPressed:
                                _isLoading ? () {} : () => _handleLogin(),
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: 24.h), // Added .h
                          Text(
                            'or log in with',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          SizedBox(height: 26.h), // Added .h
                          SocialLoginButton(
                            logoPath: 'assets/images/google_logo.png',
                            text: 'Google',
                            onPressed:
                                _isLoading
                                    ? () {}
                                    : () async {
                                      setState(() => _isLoading = true);
                                      try {
                                        final res =
                                            await _authService
                                                .signInWithGoogle();
                                        if (res == null)
                                          return; // user cancelled
                                        if (mounted) {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => const HomeScreen(),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          await showAppErrorDialog(
                                            context,
                                            e.toString(),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() => _isLoading = false);
                                        }
                                      }
                                    },
                          ),
                          SizedBox(height: 12.h),
                          SocialLoginButton(
                            logoPath: 'assets/images/facebook_logo.png',
                            text: 'Facebook',
                            onPressed: () async {
                              await showAppInfoDialog(
                                context,
                                'Facebook Sign-In coming soon!',
                              );
                            },
                          ),
                          SizedBox(height: 24.h), // Added .h
                          AuthFooter(
                            text: 'Don\'t Have An Account?',
                            actionText: 'SIGN UP',
                            onActionPressed: () {
                              // Navigate to signup screen
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
