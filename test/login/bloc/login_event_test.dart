// ignore_for_file: prefer_const_constructors
import 'package:demo_news/login/login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginEvent', () {
    group('LoginEmailChanged', () {
      test('supports value comparisons', () {
        expect(
          LoginEmailChanged('test@gmail.com'),
          LoginEmailChanged('test@gmail.com'),
        );
        expect(
          LoginEmailChanged(''),
          isNot(LoginEmailChanged('test@gmail.com')),
        );
      });
    });

    group('SendEmailLinkSubmitted', () {
      test('supports value comparisons', () {
        expect(SendEmailLinkSubmitted(), SendEmailLinkSubmitted());
      });
    });

    group('LoginWithGoogleSubmitted', () {
      test('supports value comparisons', () {
        expect(LoginWithGoogleSubmitted(), LoginWithGoogleSubmitted());
      });
    });

    group('LoginWithTwitterSubmitted', () {
      test('supports value comparisons', () {
        expect(LoginWithTwitterSubmitted(), LoginWithTwitterSubmitted());
      });
    });

    group('LoginWithFacebookSubmitted', () {
      test('supports value comparisons', () {
        expect(LoginWithFacebookSubmitted(), LoginWithFacebookSubmitted());
      });
    });

    group('LoginWithAppleSubmitted', () {
      test('supports value comparisons', () {
        expect(LoginWithAppleSubmitted(), LoginWithAppleSubmitted());
      });
    });
  });
}
