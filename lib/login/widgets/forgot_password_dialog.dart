import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:demo_news/login/login.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == FormzSubmissionStatus.success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Password reset email sent! Please check your inbox.',
                ),
              ),
            );
        } else if (state.status == FormzSubmissionStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to send password reset email. Please try again.',
                ),
              ),
            );
        }
      },
      child: AlertDialog(
        title: Text(
          'Reset Password',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return AppEmailTextField(
                  key: const Key('forgotPasswordDialog_emailInput_textField'),
                  controller: _emailController,
                  readOnly: state.status == FormzSubmissionStatus.inProgress,
                  hintText: 'Email',
                );
              },
            ),
          ],
        ),
        actions: [
          AppButton.smallTransparent(
            key: const Key('forgotPasswordDialog_cancelButton'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              final isInProgress = state.status == FormzSubmissionStatus.inProgress;
              return AppButton.smallDarkAqua(
                key: const Key('forgotPasswordDialog_sendButton'),
                onPressed: isInProgress
                    ? null
                    : () {
                        if (_emailController.text.isNotEmpty) {
                          context.read<LoginBloc>().add(
                                ForgotPasswordSubmitted(
                                  email: _emailController.text,
                                ),
                              );
                        }
                      },
                child: isInProgress
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Reset Link'),
              );
            },
          ),
        ],
      ),
    );
  }
}
