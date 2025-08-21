import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added this import
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../widgets/auth_footer.dart';
import '../widgets/social_login_button.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Initialize screen util if not using ScreenUtilInit wrapper
    // ScreenUtil.init(context, designSize: const Size(360, 800));
    
    return Scaffold(
      body: Container(
        color: AppColors.primaryRed,
        child: Center(
          child: Container(
            margin: EdgeInsets.only(
              top: 0.20.sh, // Changed from screenHeight * 0.20
              bottom: 0.02.sh, // Changed from screenHeight * 0.02
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w), // Added .w
            child: Card(
              color: AppColors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r), // Added .r
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w), // Added .w
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome Back',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.primaryRed,
                          ),
                        ),
                        SizedBox(height: 32.h), // Added .h
                        CustomTextField(
                          label: 'Full Name',
                          keyboardType: TextInputType.name,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid name';
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
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h), // Added .h
                        CustomTextField(
                          label: 'Password',
                          obscureText: true,
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
                            icon: const Icon(Icons.visibility_off),
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(height: 8.h), // Added .h
                        Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () {
                              // Handle forgot password
                            },
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.linkText,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h), // Added .h
                        CustomButton(
                          text: 'LOGIN',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Handle login
                            }
                          },
                          isLoading: _isLoading,
                        ),
                        SizedBox(height: 24.h), // Added .h
                        Text(
                          'Or Sign Up',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                        SizedBox(height: 26.h), // Added .h
                        SocialLoginButton(
                          logoPath: 'assets/images/google_logo.png',
                          text: 'Google',
                          onPressed: () {
                            // Handle Google login
                          },
                        ),
                        SizedBox(height: 12.h), // Added .h
                        SocialLoginButton(
                          logoPath: 'assets/images/facebook_logo.png',
                          text: 'Facebook',
                          onPressed: () {
                            // Handle Facebook login
                          },
                        ),
                        SizedBox(height: 24.h), // Added .h
                        AuthFooter(
                          text: 'Don\'t Have An Account?',
                          actionText: 'SIGN UP',
                          onActionPressed: () {
                            // Handle sign up
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
    );
  }
}