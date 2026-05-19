import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/storage/token_storage.dart';

// ─── State ────────────────────────────────────────────────────────────────────
class AuthState {
  final UserModel? user;
  final bool isAuthenticated;

  const AuthState({this.user, this.isAuthenticated = false});

  AuthState copyWith({UserModel? user, bool? isAuthenticated}) => AuthState(
        user: user ?? this.user,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      );
}

// ─── Repository Provider ──────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());

// ─── Notifier ─────────────────────────────────────────────────────────────────
class AuthNotifier extends AsyncNotifier<AuthState> {
  late AuthRepository _repo;

  @override
  Future<AuthState> build() async {
    _repo = ref.read(authRepositoryProvider);
    final isAuth = await TokenStorage.instance.isAuthenticated;
    if (!isAuth) return const AuthState(isAuthenticated: false);
    try {
      final user = await _repo.getMe();
      return AuthState(user: user, isAuthenticated: true);
    } catch (_) {
      await TokenStorage.instance.deleteTokens();
      return const AuthState(isAuthenticated: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repo.login(email, password);
      await TokenStorage.instance.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return AuthState(user: result.user, isAuthenticated: true);
    });
  }

  Future<void> register(String fullName, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repo.register(fullName, email, password);
      await TokenStorage.instance.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return AuthState(user: result.user, isAuthenticated: true);
    });
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } finally {
      await TokenStorage.instance.deleteTokens();
      state = const AsyncData(AuthState(isAuthenticated: false));
    }
  }

  Future<void> updateAvatar(String filePath) async {
    final current = state.value;
    if (current == null || current.user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final avatarUrl = await _repo.uploadAvatar(filePath);
      final updatedProfile = UserProfileModel(
        avatarUrl: avatarUrl,
        dateOfBirth: current.user!.profile?.dateOfBirth,
        gender: current.user!.profile?.gender,
        heightCm: current.user!.profile?.heightCm,
        weightKg: current.user!.profile?.weightKg,
        medicalNotes: current.user!.profile?.medicalNotes,
      );
      final updatedUser = UserModel(
        id: current.user!.id,
        email: current.user!.email,
        fullName: current.user!.fullName,
        role: current.user!.role,
        isActive: current.user!.isActive,
        profile: updatedProfile,
      );
      return AuthState(user: updatedUser, isAuthenticated: true);
    });
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ─── Onboarding (mantiene estado en memoria + SharedPreferences) ──────────────
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void complete() => state = true;
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
