import "package:flutter/material.dart";


class HomeActionBar extends StatelessWidget {
  const HomeActionBar({
    super.key,
    this.onAddEntry,
    this.onSearch,
  });

  final VoidCallback? onAddEntry;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: "Add entry",
          onPressed: onAddEntry,
          icon: const Icon(Icons.add_rounded),
        ),
        IconButton(
          tooltip: "Search for entry",
          onPressed: onSearch,
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }
}