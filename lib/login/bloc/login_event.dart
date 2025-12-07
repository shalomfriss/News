part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class SendEmailLinkSubmitted extends LoginEvent with AnalyticsEventMixin {
  @override
  AnalyticsEvent get event => const AnalyticsEvent('SendEmailLinkSubmitted');
}

class LoginEmailPasswordSubmitted extends LoginEvent with AnalyticsEventMixin {
  const LoginEmailPasswordSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginEmailPasswordSubmitted');

  @override
  List<Object> get props => [email, password];
}

class SignUpEmailPasswordSubmitted extends LoginEvent with AnalyticsEventMixin {
  const SignUpEmailPasswordSubmitted({
    required this.email,
    required this.password,
    this.name,
  });

  final String email;
  final String password;
  final String? name;

  @override
  AnalyticsEvent get event => const AnalyticsEvent('SignUpEmailPasswordSubmitted');

  @override
  List<Object> get props => [email, password, if (name != null) name!];
}

class ForgotPasswordSubmitted extends LoginEvent with AnalyticsEventMixin {
  const ForgotPasswordSubmitted({
    required this.email,
  });

  final String email;

  @override
  AnalyticsEvent get event => const AnalyticsEvent('ForgotPasswordSubmitted');

  @override
  List<Object> get props => [email];
}

class LoginWithGoogleSubmitted extends LoginEvent with AnalyticsEventMixin {
  const LoginWithGoogleSubmitted();

  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginWithGoogleSubmitted');

  @override
  List<Object> get props => [];
}

class LoginWithAppleSubmitted extends LoginEvent with AnalyticsEventMixin {
  const LoginWithAppleSubmitted();

  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginWithAppleSubmitted');

  @override
  List<Object> get props => [];
}

class LoginWithFacebookSubmitted extends LoginEvent with AnalyticsEventMixin {
  const LoginWithFacebookSubmitted();

  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginWithFacebookSubmitted');

  @override
  List<Object> get props => [];
}

class LoginWithTwitterSubmitted extends LoginEvent with AnalyticsEventMixin {
  const LoginWithTwitterSubmitted();

  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginWithTwitterSubmitted');

  @override
  List<Object> get props => [];
}

class LoginWithTikTokSubmitted extends LoginEvent with AnalyticsEventMixin {
  const LoginWithTikTokSubmitted();

  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginWithTikTokSubmitted');

  @override
  List<Object> get props => [];
}

class LoginWithInstagramSubmitted extends LoginEvent with AnalyticsEventMixin {
  const LoginWithInstagramSubmitted();

  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginWithInstagramSubmitted');

  @override
  List<Object> get props => [];
}

class LoginWithYouTubeSubmitted extends LoginEvent with AnalyticsEventMixin {
  const LoginWithYouTubeSubmitted();

  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginWithYouTubeSubmitted');

  @override
  List<Object> get props => [];
}
