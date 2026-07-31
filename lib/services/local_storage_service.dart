import 'package:hive_flutter/hive_flutter.dart';
import 'package:memory_challenge/models/animal_profile.dart';
import 'package:memory_challenge/models/app_settings.dart';
import 'package:memory_challenge/models/profile_stats.dart';

abstract final class HiveBoxes {
  static const String settings = 'settings';
  static const String profiles = 'profiles';
}

class LocalStorageService {
  LocalStorageService();

  late Box<dynamic> _settingsBox;
  late Box<dynamic> _profilesBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(HiveBoxes.settings);
    _profilesBox = await Hive.openBox(HiveBoxes.profiles);
    await _ensureDefaults();
  }

  Future<void> _ensureDefaults() async {
    if (!_settingsBox.containsKey('app')) {
      await _settingsBox.put('app', const AppSettings().toMap());
    }
    for (final profile in AnimalProfile.values) {
      if (!_profilesBox.containsKey(profile.id)) {
        await _profilesBox.put(profile.id, const ProfileStats().toMap());
      }
    }
  }

  AppSettings loadSettings() {
    final raw = _settingsBox.get('app');
    if (raw is Map) return AppSettings.fromMap(raw);
    return const AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('app', settings.toMap());
  }

  ProfileStats loadProfile(AnimalProfile profile) {
    final raw = _profilesBox.get(profile.id);
    if (raw is Map) return ProfileStats.fromMap(raw);
    return const ProfileStats();
  }

  Future<void> saveProfile(AnimalProfile profile, ProfileStats stats) async {
    await _profilesBox.put(profile.id, stats.toMap());
  }

  Map<AnimalProfile, ProfileStats> loadAllProfiles() {
    final map = <AnimalProfile, ProfileStats>{};
    for (final profile in AnimalProfile.values) {
      map[profile] = loadProfile(profile);
    }
    return map;
  }

  Future<void> resetProfile(AnimalProfile profile) async {
    await _profilesBox.put(profile.id, const ProfileStats().toMap());
  }

  Future<void> resetAllProfiles() async {
    for (final profile in AnimalProfile.values) {
      await resetProfile(profile);
    }
  }
}
