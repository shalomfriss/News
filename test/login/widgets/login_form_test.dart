// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_news/app/app.dart';
import 'package:demo_news/login/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

import '../../helpers/helpers.dart';

class MockUser extends Mock implements User {}

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

void main() {
  const loginButtonKey = Key('loginForm_emailPasswordLogin_appButton');
  const loginFormCloseModalKey = Key('loginForm_closeModal_iconButton');

  group('LoginForm', () {
    late LoginBloc loginBloc;
    late AppBloc appBloc;
    late User user;

    setUp(() {
      loginBloc = MockLoginBloc();
      appBloc = MockAppBloc();
      user = MockUser();

      when(() => loginBloc.state).thenReturn(const LoginState());
    });

    group('adds', () {
      testWidgets('AuthenticationFailure SnackBar when submission fails',
          (tester) async {
        whenListen(
          loginBloc,
          Stream.fromIterable(const <LoginState>[
            LoginState(status: FormzSubmissionStatus.inProgress),
            LoginState(status: FormzSubmissionStatus.failure),
          ]),
        );
        await tester.pumpApp(
          BlocProvider.value(value: loginBloc, child: const LoginForm()),
        );
        await tester.pump();
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('nothing when login is canceled', (tester) async {
        whenListen(
          loginBloc,
          Stream.fromIterable(const <LoginState>[
            LoginState(status: FormzSubmissionStatus.inProgress),
            LoginState(status: FormzSubmissionStatus.canceled),
          ]),
        );
      });
    });

    group('renders', () {
      testWidgets('email/password login button', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(value: loginBloc, child: const LoginForm()),
        );
        expect(find.byKey(loginButtonKey), findsOneWidget);
      });
    });

    group('navigates', () {
      testWidgets('to LoginWithEmailPage when Continue with email is pressed',
          (tester) async {
        await tester.pumpApp(
          BlocProvider.value(value: loginBloc, child: const LoginForm()),
        );
        await tester.ensureVisible(find.byKey(loginButtonKey));
        await tester.tap(find.byKey(loginButtonKey));
        await tester.pumpAndSettle();
        expect(find.byType(LoginWithEmailPage), findsOneWidget);
      });
    });

    group('closes modal', () {
      const buttonText = 'button';

      testWidgets('when the close icon is pressed', (tester) async {
        await tester.pumpApp(
          BlocProvider.value(
            value: loginBloc,
            child: Builder(
              builder: (context) {
                return AppButton.black(
                  child: Text(buttonText),
                  onPressed: () => showAppModal<void>(
                    context: context,
                    builder: (context) => const LoginModal(),
                    routeSettings: const RouteSettings(name: LoginModal.name),
                  ),
                );
              },
            ),
          ),
        );
        await tester.tap(find.text(buttonText));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(loginFormCloseModalKey));
        await tester.pumpAndSettle();

        expect(find.byType(LoginForm), findsNothing);
      });

      testWidgets('when user is authenticated', (tester) async {
        final appStateController = StreamController<AppState>();

        whenListen(
          appBloc,
          appStateController.stream,
          initialState: const AppState.unauthenticated(),
        );

        await tester.pumpApp(
          Builder(
            builder: (context) {
              return AppButton.black(
                child: Text(buttonText),
                onPressed: () => showAppModal<void>(
                  context: context,
                  builder: (context) => BlocProvider.value(
                    value: appBloc,
                    child: LoginModal(),
                  ),
                  routeSettings: const RouteSettings(name: LoginModal.name),
                ),
              );
            },
          ),
        );
        await tester.tap(find.text(buttonText));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byKey(loginButtonKey));
        await tester.tap(find.byKey(loginButtonKey));
        await tester.pumpAndSettle();
        expect(find.byType(LoginWithEmailPage), findsOneWidget);

        appStateController.add(AppState.authenticated(user));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(LoginWithEmailPage), findsNothing);
        expect(find.byType(LoginForm), findsNothing);
      });

      testWidgets('when user is authenticated and onboarding is required',
          (tester) async {
        final appStateController = StreamController<AppState>();

        whenListen(
          appBloc,
          appStateController.stream,
          initialState: const AppState.unauthenticated(),
        );

        await tester.pumpApp(
          Builder(
            builder: (context) {
              return AppButton.black(
                child: Text(buttonText),
                onPressed: () => showAppModal<void>(
                  context: context,
                  builder: (context) => BlocProvider.value(
                    value: appBloc,
                    child: LoginModal(),
                  ),
                  routeSettings: const RouteSettings(name: LoginModal.name),
                ),
              );
            },
          ),
        );
        await tester.tap(find.text(buttonText));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byKey(loginButtonKey));
        await tester.tap(find.byKey(loginButtonKey));
        await tester.pumpAndSettle();
        expect(find.byType(LoginWithEmailPage), findsOneWidget);

        appStateController.add(AppState.onboardingRequired(user));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(LoginWithEmailPage), findsNothing);
        expect(find.byType(LoginForm), findsNothing);
      });
    });
  });
}
