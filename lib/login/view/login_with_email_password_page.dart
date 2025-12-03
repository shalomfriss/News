import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_news/login/login.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:user_repository/user_repository.dart';

class LoginWithEmailPasswordPage extends StatelessWidget {
  const LoginWithEmailPasswordPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const LoginWithEmailPasswordPage());

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
              key: const Key('loginWithEmailPasswordPage_closeIcon'),
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: const LoginWithEmailPasswordForm(),
      ),
    );
  }
}

class LoginWithEmailPasswordForm extends StatefulWidget {
  const LoginWithEmailPasswordForm({super.key});

  @override
  State<LoginWithEmailPasswordForm> createState() => _LoginWithEmailPasswordFormState();
}

class _LoginWithEmailPasswordFormState extends State<LoginWithEmailPasswordForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
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
              const SnackBar(content: Text('Login successful!')),
            );
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Login failed. Please check your credentials.')),
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
                  _EmailInput(controller: _emailController),
                  const SizedBox(height: AppSpacing.lg),
                  _PasswordInput(controller: _passwordController),
                  const SizedBox(height: AppSpacing.sm),
                  const _ForgotPasswordLink(),
                  const Spacer(),
                  _LoginButton(
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SignUpLink(),
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
      'Sign in with Email',
      key: const Key('loginWithEmailPasswordForm_header_title'),
      style: theme.textTheme.displaySmall,
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
      key: const Key('loginWithEmailPasswordForm_emailInput_textField'),
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
      key: const Key('loginWithEmailPasswordForm_passwordInput_textField'),
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

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginBloc>().state;

    return AppButton.darkAqua(
      key: const Key('loginWithEmailPasswordForm_loginButton'),
      onPressed: () {
        if (emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty) {
          context.read<LoginBloc>().add(
                LoginEmailPasswordSubmitted(
                  email: emailController.text,
                  password: passwordController.text,
                ),
              );
        }
      },
      child: state.status.isInProgress
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(),
            )
          : const Text('Sign In'),
    );
  }
}

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        key: const Key('loginWithEmailPasswordForm_forgotPasswordLink'),
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<LoginBloc>(),
              child: const ForgotPasswordDialog(),
            ),
          );
        },
        child: Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}

class _SignUpLink extends StatelessWidget {
  const _SignUpLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          key: const Key('loginWithEmailPasswordForm_signUpLink'),
          onPressed: () => Navigator.of(context).push<void>(
            SignUpWithEmailPasswordPage.route(),
          ),
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}
