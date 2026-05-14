import 'package:flutter_riverpod/flutter_riverpod.dart';

class InjuryState {
  final String activeInjuryId;
  final double latestPainLevel;
  final int streakDays;

  InjuryState({
    required this.activeInjuryId,
    required this.latestPainLevel,
    required this.streakDays,
  });

  InjuryState copyWith({
    String? activeInjuryId,
    double? latestPainLevel,
    int? streakDays,
  }) {
    return InjuryState(
      activeInjuryId: activeInjuryId ?? this.activeInjuryId,
      latestPainLevel: latestPainLevel ?? this.latestPainLevel,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}

class InjuryNotifier extends Notifier<InjuryState> {
  @override
  InjuryState build() {
    return InjuryState(
      activeInjuryId: '1',
      latestPainLevel: 2.0,
      streakDays: 7,
    );
  }

  void updatePainLevel(double level) {
    state = state.copyWith(latestPainLevel: level);
  }

  void incrementStreak() {
    state = state.copyWith(streakDays: state.streakDays + 1);
  }

  void setActiveInjury(String id) {
    state = state.copyWith(activeInjuryId: id);
  }
}

final injuryProvider = NotifierProvider<InjuryNotifier, InjuryState>(() {
  return InjuryNotifier();
});
