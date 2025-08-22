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
import 'package:park_chatapp/features/auth/presentation/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Handle sign up with Firebase Auth
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: AppColors.primaryRed,
          child: Center(
            child: Container(
              margin: EdgeInsets.only(
                top: 0.02.sh, // Changed from screenHeight * 0.20
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
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    20.w,
                    20.w,
                    20.h,
                  ), // Added .w
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
                            label: 'Full Name',
                            keyboardType: TextInputType.name,
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h), // Added .h
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
                          SizedBox(height: 24.h), // Added .h
                          CustomButton(
                            text: 'SIGN UP',
                            onPressed:
                                _isLoading ? () {} : () => _handleSignUp(),
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: 20.h), // Added .h
                          Text(
                            'Or Sign Up with',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          SizedBox(height: 20.h), // Added .h
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
                            text: 'Already Have An Account?',
                            actionText: 'LOGIN',
                            onActionPressed: () {
                              // Navigate to login screen
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
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
