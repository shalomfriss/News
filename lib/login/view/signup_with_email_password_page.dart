import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_news/login/login.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:user_repository/user_repository.dart';

class SignUpWithEmailPasswordPage extends StatelessWidget {
  const SignUpWithEmailPasswordPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const SignUpWithEmailPasswordPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        userRepository: context.read<UserRepository>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          actions: [
            IconButton(
              key: const Key('signUpWithEmailPasswordPage_closeIcon'),
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: const SignUpWithEmailPasswordForm(),
      ),
    );
  }
}

class SignUpWithEmailPasswordForm extends StatefulWidget {
  const SignUpWithEmailPasswordForm({super.key});

  @override
  State<SignUpWithEmailPasswordForm> createState() => _SignUpWithEmailPasswordFormState();
}

class _SignUpWithEmailPasswordFormState extends State<SignUpWithEmailPasswordForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Account created successfully!')),
            );
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Sign up failed. Please try again.')),
            );
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xlg,
                AppSpacing.lg,
                AppSpacing.xlg,
                AppSpacing.xxlg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _HeaderTitle(),
                  const SizedBox(height: AppSpacing.xxxlg),
                  _NameInput(controller: _nameController),
                  const SizedBox(height: AppSpacing.lg),
                  _EmailInput(controller: _emailController),
                  const SizedBox(height: AppSpacing.lg),
                  _PasswordInput(controller: _passwordController),
                  const Spacer(),
                  _SignUpButton(
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Create Account',
      key: const Key('signUpWithEmailPasswordForm_header_title'),
      style: theme.textTheme.displaySmall,
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginBloc>().state;

    return TextField(
      key: const Key('signUpWithEmailPasswordForm_nameInput_textField'),
      controller: controller,
      readOnly: state.status.isInProgress,
      decoration: const InputDecoration(
        hintText: 'Name (optional)',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginBloc>().state;

    return AppEmailTextField(
      key: const Key('signUpWithEmailPasswordForm_emailInput_textField'),
      controller: controller,
      readOnly: state.status.isInProgress,
      hintText: 'Email',
    );
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput({required this.controller});

  final TextEditingController controller;

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginBloc>().state;

    return TextField(
      key: const Key('signUpWithEmailPasswordForm_passwordInput_textField'),
      controller: widget.controller,
      readOnly: state.status.isInProgress,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginBloc>().state;

    return AppButton.darkAqua(
      key: const Key('signUpWithEmailPasswordForm_signUpButton'),
      onPressed: () {
        if (emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty) {
          context.read<LoginBloc>().add(
                SignUpEmailPasswordSubmitted(
                  email: emailController.text,
                  password: passwordController.text,
                  name: nameController.text.isEmpty ? null : nameController.text,
                ),
              );
        }
      },
      child: state.status.isInProgress
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(),
            )
          : const Text('Create Account'),
    );
  }
}
