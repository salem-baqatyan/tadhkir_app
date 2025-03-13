import 'package:flutter/material.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPickerDialog extends StatefulWidget {
  @override
  _ContactPickerDialogState createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  List<Contact> _selectedContacts = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    await Permission.contacts.request();
    _contacts = await FastContacts.getAllContacts();
    _filteredContacts = _contacts;
    setState(() => _isLoading = false);
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts
          .where((contact) => contact.displayName.toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleSelection(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("اختر جهات الاتصال"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "بحث",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(height: 10),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return ListTile(
                        title: Text(contact.displayName),
                        trailing: Checkbox(
                          value: _selectedContacts.contains(contact),
                          onChanged: (bool? selected) {
                            _toggleSelection(contact);
                          },
                        ),
                        onTap: () => _toggleSelection(contact),
                      );
                    },
                  ),
                ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("إلغاء"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedContacts),
          child: Text("تأكيد"),
        ),
      ],
    );
  }
}

void showContactPicker(BuildContext context) async {
  final selectedContacts = await showDialog<List<Contact>>(
    context: context,
    builder: (context) => ContactPickerDialog(),
  );
  if (selectedContacts != null) {
    print(
        "جهات الاتصال المحددة: ${selectedContacts.map((c) => c.displayName).join(", ")}");
  }
}
