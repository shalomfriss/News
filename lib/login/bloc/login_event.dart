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

class LoginGoogleSubmitted extends LoginEvent with AnalyticsEventMixin {
  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginGoogleSubmitted');
}

class LoginAppleSubmitted extends LoginEvent with AnalyticsEventMixin {
  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginAppleSubmitted');
}

class LoginTwitterSubmitted extends LoginEvent with AnalyticsEventMixin {
  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginTwitterSubmitted');
}

class LoginFacebookSubmitted extends LoginEvent with AnalyticsEventMixin {
  @override
  AnalyticsEvent get event => const AnalyticsEvent('LoginFacebookSubmitted');
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
