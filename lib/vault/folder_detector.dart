import "password_database.dart";

enum DetectedFolderSource { title, username, urlHost }

class DetectedFolder {
  const DetectedFolder({
    required this.name,
    required this.source,
    required this.entries,
  });

  final String name;
  final DetectedFolderSource source;
  final List<PasswordEntry> entries;
}

List<DetectedFolder> detectFolders(
  List<PasswordEntry> entries, {
  required String untitledName,
}) {
  final groups = <String, _FolderDraft>{};

  void addGroup({
    required String key,
    required String name,
    required DetectedFolderSource source,
    required PasswordEntry entry,
  }) {
    final group = groups.putIfAbsent(
      key,
      () => _FolderDraft(name: name, source: source),
    );

    group.add(entry);
  }

  for (final entry in entries) {
    final titleKey = _normalize(entry.title);
    if (titleKey.isNotEmpty) {
      addGroup(
        key: "title:$titleKey",
        name: _prettyName(entry.title, untitledName),
        source: DetectedFolderSource.title,
        entry: entry,
      );
    }

    // final usernameDomain = _emailDomain(entry.username);
    // if (usernameDomain != null) {
    //   addGroup(
    //     key: "username:$usernameDomain",
    //     name: _domainName(usernameDomain, untitledName),
    //     source: DetectedFolderSource.usernameDomain,
    //     entry: entry,
    //   );
    // }

    final usernameKey = _normalize(entry.username);
    if (usernameKey.isNotEmpty) {
      addGroup(
        key: "username:$usernameKey",
        name: entry.username.trim(),
        source: DetectedFolderSource.username,
        entry: entry
      );
    }

    final urlHost = _urlHost(entry.url);
    if (urlHost != null) {
      addGroup(
        key: "url:$urlHost",
        name: _domainName(urlHost, untitledName),
        source: DetectedFolderSource.urlHost,
        entry: entry,
      );
    }
  }

  final folders = groups.values
      .where((group) => group.entries.length >= 2)
      .map(
        (group) => DetectedFolder(
          name: group.name,
          source: group.source,
          entries: group.entries,
        ),
      )
      .toList();

  folders.sort((a, b) {
    final countCompare = b.entries.length.compareTo(a.entries.length);
    if (countCompare != 0) {
      return countCompare;
    }

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  return folders;
}

class _FolderDraft {
  _FolderDraft({required this.name, required this.source});

  final String name;
  final DetectedFolderSource source;
  final List<PasswordEntry> entries = [];
  final Set<String> _entryIds = {};

  void add(PasswordEntry entry) {
    if (_entryIds.add(entry.id)) {
      entries.add(entry);
    }
  }
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r"\s+"), " ");
}

String _prettyName(String value, String untitledName) {
  final trimmed = value.trim();

  if (trimmed.isEmpty) {
    return untitledName;
  }

  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

// String? _emailDomain(String value) {
//   final trimmed = value.trim().toLowerCase();
//   final atIndex = trimmed.indexOf("@");

//   if (atIndex == -1 || atIndex == trimmed.length - 1) {
//     return null;
//   }

//   return trimmed.substring(atIndex + 1);
// }

String? _urlHost(String value) {
  final trimmed = value.trim().toLowerCase();

  if (trimmed.isEmpty) {
    return null;
  }

  final urlText = trimmed.contains("://") ? trimmed : "https://$trimmed";
  final url = Uri.tryParse(urlText);
  final host = url?.host.replaceFirst(RegExp(r"^www\."), "");

  if (host == null || host.isEmpty) {
    return null;
  }

  return host;
}

String _domainName(String domain, String untitledName) {
  final cleanDomain = domain
      .replaceFirst(RegExp(r"^www\."), "")
      .replaceFirst(RegExp(r"^mail\."), "");

  final firstPart = cleanDomain.split(".").first;
  return _prettyName(firstPart, untitledName);
}
