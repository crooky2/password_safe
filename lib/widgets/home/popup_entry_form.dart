import "package:flutter/material.dart";

import "../../vault/password_database.dart";

import "../screen_popup.dart";
import "../secret_text_field.dart";

class EntryFormPopup extends StatefulWidget {
  const EntryFormPopup({super.key, this.entry, this.clone = false});

  final PasswordEntry? entry;
  final bool clone;

  @override
  State<EntryFormPopup> createState() => _EntryFormPopupState();
}

class _EntryFormPopupState extends State<EntryFormPopup> {
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _urlController;
  late final TextEditingController _notesController;

  String? _errorMessage;

  bool get _isEditing => widget.entry != null && !widget.clone;

  @override
  void initState() {
    super.initState();

    final entry = widget.entry;

    _titleController = TextEditingController(text: entry?.title ?? "");
    _usernameController = TextEditingController(text: entry?.username ?? "");
    _passwordController = TextEditingController(text: entry?.password ?? "");
    _urlController = TextEditingController(text: entry?.url ?? "");
    _notesController = TextEditingController(text: entry?.notes ?? "");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final url = _urlController.text.trim();
    final notes = _notesController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = "Title is required.";
      });
      return;
    }

    final entry = PasswordEntry(
      id: _isEditing
          ? widget.entry!.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      username: username,
      password: password,
      url: url,
      notes: notes,
      isFavorite: _isEditing ? widget.entry!.isFavorite : false,
      iconKey: widget.entry?.iconKey ?? "",
    );

    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing
        ? "Edit entry"
        : widget.clone
        ? "Clone entry"
        : "New entry";

    return ScreenPopup(
      title: title,
      onClose: () {
        Navigator.of(context).pop();
      },
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 12),
        SecretTextField(
          controller: _passwordController,
          labelText: "Password",
          enableBorder: false,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(labelText: 'URL'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),  
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],

        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: Text(_isEditing ? 'Save changes' : 'Create entry'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          icon: const Icon(Icons.delete),
          label: Text("Discard"),
        ),
      ],
    );
  }
}
