import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String hint;
  final String label;
  final Function(String?) onChanged;
  final FormFieldValidator<String>? validator;

  const SearchableDropdown({
    Key? key,
    required this.items,
    this.value,
    required this.hint,
    required this.label,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label,
                border: OutlineInputBorder(),
                errorText: state.hasError ? state.errorText : null,
              ),
              isEmpty: widget.value == null || widget.value!.isEmpty,
              child: GestureDetector(
                onTap: () async {
                  final selectedValue = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return _SearchableDropdownDialog(
                        items: widget.items,
                        selectedItem: widget.value,
                        title: widget.label,
                      );
                    },
                  );

                  if (selectedValue != null) {
                    state.didChange(selectedValue);
                    widget.onChanged(selectedValue);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.value ?? widget.hint,
                        style: TextStyle(
                          color: widget.value == null ? Colors.grey.shade600 : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SearchableDropdownDialog extends StatefulWidget {
  final List<String> items;
  final String? selectedItem;
  final String title;

  const _SearchableDropdownDialog({
    Key? key,
    required this.items,
    this.selectedItem,
    required this.title,
  }) : super(key: key);

  @override
  _SearchableDropdownDialogState createState() => _SearchableDropdownDialogState();
}

class _SearchableDropdownDialogState extends State<_SearchableDropdownDialog> {
  late TextEditingController _searchController;
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;

    _searchController.addListener(() {
      setState(() {
        if (_searchController.text.isEmpty) {
          _filteredItems = widget.items;
        } else {
          _filteredItems = widget.items
              .where((item) =>
              item.toLowerCase().contains(_searchController.text.toLowerCase()))
              .toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = item == widget.selectedItem;

                  return ListTile(
                    title: Text(item),
                    selected: isSelected,
                    selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    onTap: () {
                      Navigator.of(context).pop(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}