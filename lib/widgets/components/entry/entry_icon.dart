import "package:flutter/material.dart";
import "package:simple_icons/simple_icons.dart";

import "../../../vault/password_database.dart";

class EntryIconResolver {
  const EntryIconResolver();

  static final Map<String, IconData> _icons = {
    for (final item in SimpleIcons.values.entries)
      _normalize(item.key): item.value,
  };

  static const Map<String, String> _domains = {
    "gmail.com": "gmail",
    "googlemail.com": "gmail",
    "mail.google.com": "gmail",
    "google.com": "google",
    "github.com": "github",
    "gitlab.com": "gitlab",
    "bitbucket.org": "bitbucket",
    "proton.me": "protonmail",
    "protonmail.com": "protonmail",
    "pm.me": "protonmail",
    "apple.com": "apple",
    "icloud.com": "apple",
    "spotify.com": "spotify",
    "netflix.com": "netflix",
    "discord.com": "discord",
    "discord.gg": "discord",
    "dropbox.com": "dropbox",
    "steampowered.com": "steam",
    "steamcommunity.com": "steam",
    "paypal.com": "paypal",
  };

  static const Map<String, String> _nameAliases = {
    "1password": "n1password",
    "net": "dotnet",
    "webde": "webdotde",
    "proton": "protonmail",
    "abstract": "abstracticon",
  };

  IconData resolve(PasswordEntry entry) {
    return _fromName(entry.title) ??
        _fromDomain(_websiteDomain(entry.url)) ??
        Icons.key_rounded;
  }

  String? _websiteDomain(String website) {
    var value = website.trim();
    if (value.isEmpty || RegExp(r"\s").hasMatch(value)) {
      return null;
    }
    if (value.startsWith("//")) {
      value = "https:$value";
    } else if (!value.contains("://")) {
      value = "https://$value";
    }

    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != "https" && uri.scheme != "http") ||
        uri.host.isEmpty) {
      return null;
    }
    return _normalizeHost(uri.host);
  }

  String? _normalizeHost(String value) {
    var host = value.toLowerCase();
    if (host.endsWith(".")) {
      host = host.substring(0, host.length - 1);
    }
    if (host.isEmpty || host.length > 253) {
      return null;
    }

    final labels = host.split(".");
    if (labels.length < 2) {
      return null;
    }

    final validLabel = RegExp(r"^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$");
    for (final label in labels) {
      if (label.length > 63 || !validLabel.hasMatch(label)) {
        return null;
      }
    }

    return host;
  }

  IconData? _fromDomain(String? host) {
    if (host == null) {
      return null;
    }

    var candidate = host;
    while (candidate.contains(".")) {
      final iconName = _domains[candidate];

      if (iconName != null) {
        final icon = _lookup(iconName);
        if (icon != null) {
          return icon;
        }
      }

      candidate = candidate.substring(candidate.indexOf(".") + 1);
    }
    return null;
  }

  IconData? _fromName(String title) {
    final exactMatch = _lookup(title);
    if (exactMatch != null) {
      return exactMatch;
    }

    final words = title
        .toLowerCase()
        .split(RegExp(r"[^a-z0-9]+"))
        .where((word) => word.isNotEmpty)
        .toList();

    for (var length = 3; length >= 1; length--) {
      for (var start = 0; start + length <= words.length; start++) {
        final phrase = words.sublist(start, start + length).join();
        if (phrase.length < 3) {
          continue;
        }

        final icon = _lookup(phrase);
        if (icon != null) {
          return icon;
        }
      }
    }
    return null;
  }

  IconData? _lookup(String name) {
    final normalized = _normalize(name);
    final catalogueName = _nameAliases[normalized] ?? normalized;

    return _icons[catalogueName];
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll("&", "and")
        .replaceAll("+", "plus")
        .replaceAll("#", "sharp")
        .replaceAll(RegExp(r"[^a-z0-9]"), "");
  }
}
