import "dart:convert";


class PasswordEntry {
  const PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.notes = "",
    this.url = "",
  });

  final String id;
  final String title;
  final String username;
  final String password;
  final String notes;
  final String url;


  Map<String, Object> toJson() {
    return {
      "id": id,
      "title": title,
      "username": username,
      "password": password,
      "notes": notes,
      "url": url,
    };
  }

  factory PasswordEntry.fromJson(Map<String, Object?> json) {
    return PasswordEntry(
      id: json["id"] as String,
      title: json["title"] as String,
      username: json["username"] as String,
      password: json["password"] as String,
      notes: json["notes"] as String? ?? "",
      url: json["url"] as String? ?? "",
    );
  }
}



class PasswordDatabase {
  const PasswordDatabase({
    required this.version,
    required this.entries,
  });

  final int version;
  final List<PasswordEntry> entries;

  factory PasswordDatabase.empty() {
    return const PasswordDatabase(
      version: 1,
      entries: [],
    );
  }

  Map<String, Object> toJson() {
    return {
      "version": version,
      "entries": entries.map((entry) => entry.toJson()).toList(),
    };
  }

  factory PasswordDatabase.fromJson(Map<String, Object?> json) {
    final entriesJson = json["entries"] as List<Object?>;
    
    return PasswordDatabase(
      version: json["version"] as int,
      entries: entriesJson.map(
        (entryJson) => PasswordEntry.fromJson(entryJson as Map<String, Object?>)
      ).toList(),
    );
  }

  String toJsonText() {
    return jsonEncode(toJson());
  }

  factory PasswordDatabase.fromJsonText(String jsonText) {
    return PasswordDatabase.fromJson(
      jsonDecode(jsonText) as Map<String, Object?>,
    );
  }

  factory PasswordDatabase.sample() {
    return const PasswordDatabase(
      version: 1,
      entries: [
      PasswordEntry(
        id: "1",
        title: "GitHub",
        username: "chris@example.com",
        password: "not-a-real-password",
        url: "https://github.com",
        notes: "Example entry for testing JSON",
        ),
      ]
    );
  }

  PasswordDatabase copyWith({
    int? version,
    List<PasswordEntry>? entries
  }) {
    return PasswordDatabase(
      version: version ?? this.version,
      entries: entries ?? this.entries,
    );
  }

  PasswordDatabase addEntry(PasswordEntry entry) {
    return copyWith(
      entries: [...entries, entry],
    );
  }
}