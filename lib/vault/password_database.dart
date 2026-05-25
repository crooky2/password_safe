import "dart:convert";


class PasswordEntry {
  const PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.notes = "",
    this.url = "",
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String username;
  final String password;
  final String notes;
  final String url;
  final bool isFavorite;


  Map<String, Object> toJson() {
    return {
      "id": id,
      "title": title,
      "username": username,
      "password": password,
      "notes": notes,
      "url": url,
      "isFavorite": isFavorite,
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
      isFavorite: json["isFavorite"] as bool? ?? false,
    );
  }

  PasswordEntry copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? notes,
    String? url,
    bool? isFavorite,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      url: url ?? this.url,
      isFavorite: isFavorite ?? this.isFavorite,
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

  PasswordDatabase updateEntry(PasswordEntry updatedEntry) {
    return copyWith(
      entries: entries.map((entry) {
        if (entry.id == updatedEntry.id) {
          return updatedEntry;
        }

        return entry;
      }).toList(),
    );
  }

  PasswordDatabase removeEntry(String id) {
    return copyWith(
      entries: entries.where((entry) => entry.id != id).toList(),
    );
  }
}