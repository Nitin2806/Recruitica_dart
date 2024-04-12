import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final void Function(String) onSearchTextChanged;

  const SearchBar({Key? key, required this.onSearchTextChanged})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: _searchController,
        onChanged: widget.onSearchTextChanged,
        decoration: InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              widget.onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }
}
