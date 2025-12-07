import 'package:app_ui/app_ui.dart' show AppButton, AppSpacing, Assets;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_news/app/app.dart';
import 'package:demo_news/l10n/l10n.dart';
import 'package:demo_news/login/login.dart';
import 'package:form_inputs/form_inputs.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state.status.isLoggedIn) {
          // Pop all routes on top of [LoginModal], then pop the modal itself.
          Navigator.of(context)
              .popUntil((route) => route.settings.name == LoginModal.name);
          Navigator.of(context).pop();
        }
      },
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(l10n.authenticationFailure)),
              );
          }
        },
        child: const _LoginContent(),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          minimum: EdgeInsets.only(
            bottom: bottomPadding > 0 ? AppSpacing.lg : AppSpacing.xxlg,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * .75),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                const _LoginTitleAndCloseButton(),
                const SizedBox(height: AppSpacing.sm),
                const _LoginSubtitle(),
                const SizedBox(height: AppSpacing.lg),
                _ContinueWithEmailPasswordLoginButton(),
                const SizedBox(height: AppSpacing.md),
                const _SocialLoginButtons(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoginTitleAndCloseButton extends StatelessWidget {
  const _LoginTitleAndCloseButton();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Text(
            context.l10n.loginModalTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        IconButton(
          key: const Key('loginForm_closeModal_iconButton'),
          constraints: const BoxConstraints.tightFor(width: 24, height: 36),
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _LoginSubtitle extends StatelessWidget {
  const _LoginSubtitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.loginModalSubtitle,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _ContinueWithEmailPasswordLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppButton.outlinedTransparentDarkAqua(
      key: const Key('loginForm_emailPasswordLogin_appButton'),
      onPressed: () => Navigator.of(context).push<void>(
        LoginWithEmailPasswordPage.route(),
      ),
      textStyle: Theme.of(context).textTheme.titleMedium,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.emailOutline.svg(),
          const SizedBox(width: AppSpacing.lg),
          const Text('Sign in with Email & Password'),
        ],
      ),
    );
  }
}

class _SocialLoginButtons extends StatelessWidget {
  const _SocialLoginButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Divider(),
        const SizedBox(height: AppSpacing.md),
        _SocialLoginButton(
          key: const Key('loginForm_googleLogin_appButton'),
          icon: Assets.icons.google.svg(height: 24, width: 24),
          label: 'Continue with Google',
          onPressed: () => context.read<LoginBloc>().add(
                const LoginWithGoogleSubmitted(),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SocialLoginButton(
          key: const Key('loginForm_appleLogin_appButton'),
          icon: Assets.icons.apple.svg(height: 24, width: 24),
          label: 'Continue with Apple',
          onPressed: () => context.read<LoginBloc>().add(
                const LoginWithAppleSubmitted(),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SocialLoginButton(
          key: const Key('loginForm_facebookLogin_appButton'),
          icon: Assets.icons.facebook.svg(height: 24, width: 24),
          label: 'Continue with Facebook',
          onPressed: () => context.read<LoginBloc>().add(
                const LoginWithFacebookSubmitted(),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SocialLoginButton(
          key: const Key('loginForm_twitterLogin_appButton'),
          icon: Assets.icons.twitter.svg(height: 24, width: 24),
          label: 'Continue with Twitter',
          onPressed: () => context.read<LoginBloc>().add(
                const LoginWithTwitterSubmitted(),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SocialLoginButton(
          key: const Key('loginForm_tiktokLogin_appButton'),
          icon: Assets.icons.tiktok.svg(height: 24, width: 24),
          label: 'Continue with TikTok',
          onPressed: () => context.read<LoginBloc>().add(
                const LoginWithTikTokSubmitted(),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SocialLoginButton(
          key: const Key('loginForm_instagramLogin_appButton'),
          icon: Assets.icons.instagram.svg(height: 24, width: 24),
          label: 'Continue with Instagram',
          onPressed: () => context.read<LoginBloc>().add(
                const LoginWithInstagramSubmitted(),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SocialLoginButton(
          key: const Key('loginForm_youtubeLogin_appButton'),
          icon: Assets.icons.youtube.svg(height: 24, width: 24),
          label: 'Continue with YouTube',
          onPressed: () => context.read<LoginBloc>().add(
                const LoginWithYouTubeSubmitted(),
              ),
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton.outlinedTransparentDarkAqua(
      onPressed: onPressed,
      textStyle: Theme.of(context).textTheme.titleMedium,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: AppSpacing.lg),
          Text(label),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
