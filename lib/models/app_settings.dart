import 'package:equatable/equatable.dart';
import 'package:memory_challenge/core/constants/app_constants.dart';
import 'package:memory_challenge/models/animal_profile.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.timerDurationSeconds = AppConstants.defaultTimerSeconds,
    this.lastActiveProfile = AnimalProfile.panda,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
  });

  final int timerDurationSeconds;
  final AnimalProfile lastActiveProfile;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;

  AppSettings copyWith({
    int? timerDurationSeconds,
    AnimalProfile? lastActiveProfile,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
  }) {
    return AppSettings(
      timerDurationSeconds:
          timerDurationSeconds ?? this.timerDurationSeconds,
      lastActiveProfile: lastActiveProfile ?? this.lastActiveProfile,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'timerDurationSeconds': timerDurationSeconds,
        'lastActiveProfile': lastActiveProfile.id,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'vibrationEnabled': vibrationEnabled,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    final timer = (map['timerDurationSeconds'] as num?)?.toInt() ??
        AppConstants.defaultTimerSeconds;
    final clamped = timer
        .clamp(AppConstants.minTimerSeconds, AppConstants.maxTimerSeconds);
    // Snap to step.
    final snapped = AppConstants.minTimerSeconds +
        (((clamped - AppConstants.minTimerSeconds) /
                    AppConstants.timerStepSeconds)
                .round() *
            AppConstants.timerStepSeconds);
    return AppSettings(
      timerDurationSeconds: snapped
          .clamp(AppConstants.minTimerSeconds, AppConstants.maxTimerSeconds),
      lastActiveProfile: AnimalProfile.fromId(
        map['lastActiveProfile'] as String? ?? 'panda',
      ),
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      musicEnabled: map['musicEnabled'] as bool? ?? true,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        timerDurationSeconds,
        lastActiveProfile,
        soundEnabled,
        musicEnabled,
        vibrationEnabled,
      ];
}
