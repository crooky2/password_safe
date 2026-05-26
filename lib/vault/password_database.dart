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
    this.iconKey = "",
  });

  final String id;
  final String title;
  final String username;
  final String password;
  final String notes;
  final String url;
  final bool isFavorite;
  final String iconKey;


  Map<String, Object> toJson() {
    return {
      "id": id,
      "title": title,
      "username": username,
      "password": password,
      "notes": notes,
      "url": url,
      "isFavorite": isFavorite,
      "iconKey": iconKey,
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
      iconKey: json["iconKey"] as String? ?? "",
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
    String? iconKey,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      url: url ?? this.url,
      isFavorite: isFavorite ?? this.isFavorite,
      iconKey: iconKey ?? this.iconKey,
    );
  }
}


class PasswordFolder {
  const PasswordFolder({
    required this.id,
    required this.name,
    this.entryIds = const [],
  });

  final String id;
  final String name;
  final List<String> entryIds;

  Map<String, Object> toJson() {
    return {
      "id": id,
      "name": name,
      "entryIds": entryIds,
    };
  }

  factory PasswordFolder.fromJson(Map<String, Object?> json) {
    final entryIdsJson = json["entryIds"] as List<Object?>? ?? const [];
    
    return PasswordFolder(
      id: json["id"] as String,
      name: json["name"] as String,
      entryIds: entryIdsJson.cast<String>(),
    );
  }

  PasswordFolder copyWith({
    String? id,
    String? name,
    List<String>? entryIds,
  }) {
    return PasswordFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      entryIds: entryIds ?? this.entryIds,
    );
  }
}



class PasswordDatabase {
  const PasswordDatabase({
    required this.version,
    required this.entries,
    this.folders = const [],
  });

  final int version;
  final List<PasswordEntry> entries;
  final List<PasswordFolder> folders;

  factory PasswordDatabase.empty() {
    return const PasswordDatabase(
      version: 1,
      entries: [],
      folders: [],
    );
  }

  Map<String, Object> toJson() {
    return {
      "version": version,
      "entries": entries.map((entry) => entry.toJson()).toList(),
      "folders": folders.map((f) => f.toJson()).toList(),
    };
  }

  factory PasswordDatabase.fromJson(Map<String, Object?> json) {
    final entriesJson = json["entries"] as List<Object?>;
    final foldersJson = json["folders"] as List<Object?>? ?? const [];

    return PasswordDatabase(
      version: json["version"] as int,
      entries: entriesJson.map(
        (entryJson) => PasswordEntry.fromJson(entryJson as Map<String, Object?>)
      ).toList(),
      folders: foldersJson.map((folderJson) =>
        PasswordFolder.fromJson(folderJson as Map<String, Object?>)).toList(),
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
    List<PasswordEntry>? entries,
    List<PasswordFolder>? folders,
  }) {
    return PasswordDatabase(
      version: version ?? this.version,
      entries: entries ?? this.entries,
      folders: folders ?? this.folders,
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

  PasswordDatabase addFolder(PasswordFolder folder) {
    return copyWith(
      folders: [...folders, folder],
    );
  }

  PasswordDatabase updateFolder(PasswordFolder updatedFolder) {
    return copyWith(
      folders: folders.map((folder){
        if (folder.id == updatedFolder.id) {
          return updatedFolder;
        }

        return folder;
      }).toList(),
    );
  }

  PasswordDatabase removeFolder(String id) {
    return copyWith(
      folders: folders.where((folder) => folder.id != id).toList(),
    );
  }
}