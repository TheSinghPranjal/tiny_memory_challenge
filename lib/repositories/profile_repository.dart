import 'package:memory_challenge/models/animal_profile.dart';
import 'package:memory_challenge/models/app_settings.dart';
import 'package:memory_challenge/models/profile_stats.dart';
import 'package:memory_challenge/services/local_storage_service.dart';

class ProfileRepository {
  ProfileRepository(this._storage);

  final LocalStorageService _storage;

  AppSettings loadSettings() => _storage.loadSettings();

  Future<void> saveSettings(AppSettings settings) =>
      _storage.saveSettings(settings);

  ProfileStats loadProfile(AnimalProfile profile) =>
      _storage.loadProfile(profile);

  Future<void> saveProfile(AnimalProfile profile, ProfileStats stats) =>
      _storage.saveProfile(profile, stats);

  Map<AnimalProfile, ProfileStats> loadAllProfiles() =>
      _storage.loadAllProfiles();

  Future<void> resetProfile(AnimalProfile profile) =>
      _storage.resetProfile(profile);

  Future<void> resetAllProfiles() => _storage.resetAllProfiles();

  /// Ranked leaderboard: highest level, then highest stage.
  List<({AnimalProfile profile, ProfileStats stats, int rank})>
      leaderboard() {
    final entries = loadAllProfiles().entries.toList()
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
