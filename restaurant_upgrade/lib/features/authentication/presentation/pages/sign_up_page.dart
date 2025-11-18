import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_widget.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import 'sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthSignUpRequested(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text,
        confirmPassword: _confirmPasswordController.text,
      ));
    }
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSignUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _navigateToSignIn();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo and Title
                    const Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'Tạo tài khoản',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Đăng ký để khám phá và đánh giá nhà hàng',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // Display Name Field
                    AuthTextField(
                      controller: _displayNameController,
                      labelText: 'Tên hiển thị',
                      hintText: 'Nhập tên hiển thị của bạn',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên hiển thị không được để trống';
                        }
                        if (value.length < AppConstants.minDisplayNameLength) {
                          return 'Tên hiển thị phải có ít nhất ${AppConstants.minDisplayNameLength} ký tự';
                        }
                        if (value.length > AppConstants.maxDisplayNameLength) {
                          return 'Tên hiển thị không được vượt quá ${AppConstants.maxDisplayNameLength} ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Email Field
                    AuthTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Nhập địa chỉ email của bạn',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email không được để trống';
                        }
                        if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Password Field
                    AuthTextField(
                      controller: _passwordController,
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu của bạn',
                      prefixIcon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mật khẩu không được để trống';
                        }
                        if (value.length < AppConstants.minPasswordLength) {
                          return 'Mật khẩu phải có ít nhất ${AppConstants.minPasswordLength} ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Confirm Password Field
                    AuthTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Xác nhận mật khẩu',
                      hintText: 'Nhập lại mật khẩu của bạn',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (value != _passwordController.text) {
                          return 'Mật khẩu xác nhận không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // Sign Up Button
                    if (state is AuthLoading)
                      const LoadingWidget(message: 'Đang tạo tài khoản...')
                    else
                      AuthButton(
                        text: 'Đăng ký',
                        onPressed: _onSignUpPressed,
                      ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Navigate to Sign In
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Đã có tài khoản? '),
                        TextButton(
                          onPressed: _navigateToSignIn,
                          child: const Text('Đăng nhập'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}