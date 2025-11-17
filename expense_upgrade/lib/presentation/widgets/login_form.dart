import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/validators.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: Validators.validateEmail,
            ),
            
            const SizedBox(height: 16),
            
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              validator: Validators.validatePassword,
              onFieldSubmitted: (_) => _handleLogin(),
            ),
            
            const SizedBox(height: 24),
            
            // Login Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Đăng nhập'),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Forgot Password (placeholder)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng quên mật khẩu sẽ được thêm sau'),
                  ),
                );
              },
              child: const Text('Quên mật khẩu?'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }
}