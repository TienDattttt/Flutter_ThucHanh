import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constant/app_sizes.dart';
import '../../../core/constant/colors.dart';
import '../../../core/constant/images.dart';
import '../../../core/constant/validators.dart';
import '../../../core/error/failures.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/usecases/user/sign_up_usecase.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../widgets/input_form_button.dart';
import '../../widgets/input_text_form_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        EasyLoading.dismiss();
        if (state is UserLoading) {
          EasyLoading.show(status: 'Đang tải...');
        } else if (state is UserLogged) {
          context.read<CartBloc>().add(const GetCart());
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.home,
            (Route<dynamic> route) => false,
          );
        } else if (state is UserLoggedFail) {
          String errorMessage = "Đã xảy ra lỗi. Vui lòng thử lại.";
          if (state.failure is CredentialFailure) {
            errorMessage = "Tên đăng nhập hoặc mật khẩu không đúng.";
          } else if (state.failure is NetworkFailure) {
            errorMessage = "Lỗi mạng. Kiểm tra kết nối của bạn.";
          }
          EasyLoading.showError(errorMessage);
        }
      },
      child: Scaffold(
          body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                      height: 80,
                      child: Image.asset(
                        kAppLogo,
                        color: kLightPrimaryColor,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Vui lòng sử dụng địa chỉ email để tạo tài khoản mới",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  InputTextFormField(
                    controller: _firstNameController,
                    hint: 'Họ',
                    textInputAction: TextInputAction.next,
                    validation: (String? val) =>
                        Validators.validateField(val, "Họ"),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InputTextFormField(
                    controller: _lastNameController,
                    hint: 'Tên',
                    textInputAction: TextInputAction.next,
                    validation: (String? val) =>
                        Validators.validateField(val, "Tên"),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InputTextFormField(
                    controller: _emailController,
                    hint: 'Email',
                    textInputAction: TextInputAction.next,
                    validation: (String? val) => Validators.validateEmail(val),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InputTextFormField(
                    controller: _passwordController,
                    hint: 'Mật khẩu',
                    textInputAction: TextInputAction.next,
                    isSecureField: true,
                    validation: (String? val) =>
                        Validators.validateField(val, "Mật khẩu"),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InputTextFormField(
                    controller: _confirmPasswordController,
                    hint: 'Xác nhận mật khẩu',
                    isSecureField: true,
                    textInputAction: TextInputAction.go,
                    validation: (String? val) =>
                        Validators.validatePasswordMatch(
                      val,
                      _passwordController.text,
                    ),
                    onFieldSubmitted: (_) => _onSignUp(context),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  InputFormButton(
                    color: kLightPrimaryColor,
                    onClick: () => _onSignUp(context),
                    titleText: 'Đăng ký',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InputFormButton(
                    color: kLightPrimaryColor,
                    onClick: () {
                      Navigator.of(context).pop();
                    },
                    titleText: 'Quay lại',
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }

  void _onSignUp(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        EasyLoading.showError("Mật khẩu không khớp!");
        return;
      }
      context.read<UserBloc>().add(SignUpUser(SignUpParams(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          )));
    }
  }
}
