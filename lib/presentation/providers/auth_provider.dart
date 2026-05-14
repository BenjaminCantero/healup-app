import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Onboarding ──────────────────────────────────────────────────────────────
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void complete() => state = true;
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

// ─── Auth ─────────────────────────────────────────────────────────────────────
class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void login() => state = true;
  void logout() => state = false;
}

final isLoggedInProvider =
    NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

// ─── User Name ────────────────────────────────────────────────────────────────
class UserNameNotifier extends Notifier<String> {
  @override
  String build() => 'Alejandro';
  void setName(String name) => state = name;
}

final userNameProvider =
    NotifierProvider<UserNameNotifier, String>(UserNameNotifier.new);
