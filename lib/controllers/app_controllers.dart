import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_challenge/models/animal_profile.dart';
import 'package:memory_challenge/models/app_settings.dart';
import 'package:memory_challenge/models/profile_stats.dart';
import 'package:memory_challenge/repositories/profile_repository.dart';
import 'package:memory_challenge/services/ad_service.dart';
import 'package:memory_challenge/services/audio_service.dart';
import 'package:memory_challenge/services/local_storage_service.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('Override in main()');
});

final audioServiceProvider = Provider<AudioService>((ref) {
  throw UnimplementedError('Override in main()');
});

final adServiceProvider = Provider<AdService>((ref) {
  throw UnimplementedError('Override in main()');
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(localStorageProvider));
});

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._repo, this._audio) : super(_repo.loadSettings()) {
    _applyAudio();
  }

  final ProfileRepository _repo;
  final AudioService _audio;

  void _applyAudio() {
    _audio.applyToggles(
      sound: state.soundEnabled,
      music: state.musicEnabled,
      vibration: state.vibrationEnabled,
    );
  }

  Future<void> _persist() async {
    await _repo.saveSettings(state);
    _applyAudio();
  }

  Future<void> setTimerDuration(int seconds) async {
    state = state.copyWith(timerDurationSeconds: seconds);
    await _persist();
  }

  Future<void> setActiveProfile(AnimalProfile profile) async {
    state = state.copyWith(lastActiveProfile: profile);
    await _persist();
  }

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await _persist();
  }

  Future<void> setMusicEnabled(bool value) async {
    state = state.copyWith(musicEnabled: value);
    await _persist();
    if (value) {
      await _audio.startMusic();
    } else {
      await _audio.stopMusic();
    }
  }

  Future<void> setVibrationEnabled(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    await _persist();
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(
    ref.watch(profileRepositoryProvider),
    ref.watch(audioServiceProvider),
  );
});

class ProfilesController extends StateNotifier<Map<AnimalProfile, ProfileStats>> {
  ProfilesController(this._repo) : super(_repo.loadAllProfiles());

  final ProfileRepository _repo;

  ProfileStats statsFor(AnimalProfile profile) =>
      state[profile] ?? const ProfileStats();

  Future<void> refresh() async {
    state = _repo.loadAllProfiles();
  }

  Future<void> save(AnimalProfile profile, ProfileStats stats) async {
    await _repo.saveProfile(profile, stats);
    state = {...state, profile: stats};
  }

  Future<void> resetProfile(AnimalProfile profile) async {
    await _repo.resetProfile(profile);
    state = {...state, profile: const ProfileStats()};
  }

  Future<void> resetAll() async {
    await _repo.resetAllProfiles();
    state = {
      for (final p in AnimalProfile.values) p: const ProfileStats(),
    };
  }

  List<({AnimalProfile profile, ProfileStats stats, int rank})> leaderboard() {
    final entries = state.entries.toList()
      ..sort((a, b) {
        final levelCmp = b.value.maxLevel.compareTo(a.value.maxLevel);
        if (levelCmp != 0) return levelCmp;
        return b.value.maxStage.compareTo(a.value.maxStage);
      });
    return [
      for (var i = 0; i < entries.length; i++)
        (profile: entries[i].key, stats: entries[i].value, rank: i + 1),
    ];
  }
}

final profilesControllerProvider = StateNotifierProvider<ProfilesController,
    Map<AnimalProfile, ProfileStats>>((ref) {
  return ProfilesController(ref.watch(profileRepositoryProvider));
});

final activeProfileProvider = Provider<AnimalProfile>((ref) {
  return ref.watch(settingsControllerProvider).lastActiveProfile;
});

final activeProfileStatsProvider = Provider<ProfileStats>((ref) {
  final profile = ref.watch(activeProfileProvider);
  final map = ref.watch(profilesControllerProvider);
  return map[profile] ?? const ProfileStats();
});
