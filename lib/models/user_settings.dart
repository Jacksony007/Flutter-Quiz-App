class UserSettings {
  final bool notifications;
  final bool darkMode;

  UserSettings({required this.notifications, required this.darkMode});

  // Convert a Map into a UserSettings instance
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      notifications: map['notifications'] ?? true,
      darkMode: map['darkMode'] ?? false,
    );
  }

  // Convert a UserSettings instance into a Map
  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'darkMode': darkMode,
    };
  }
}
