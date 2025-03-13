import 'package:flutter/material.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tadhkir_app/core/shered_widget/custom_app_bar.dart';
import 'package:tadhkir_app/core/styles/Colors.dart';
import 'package:tadhkir_app/sqldb.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  SqlDb sqlDb = SqlDb();
  List list = [];
  int? groupId;
  int? active;
  String? time;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map? args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        setState(() {
          time = args['time'];
          groupId = args['group_id'];
          active = args['active'];
        });
        readData();
      }
    });
  }

  Future<void> readData() async {
    list.clear();
    List<Map> response = await sqlDb.readData(
        "SELECT * FROM Contacts WHERE group_id = $groupId ORDER BY name ASC");
    list.addAll(response);
    if (mounted) setState(() {});
  }

  Future<void> _pickContacts() async {
    final selectedContacts = await showDialog<List<Contact>>(
      context: context,
      builder: (context) => ContactPickerDialog(),
    );
    if (selectedContacts != null) {
      for (var contact in selectedContacts) {
        await sqlDb.insertData('''
          INSERT INTO Contacts (group_id, name, phone, active)
          VALUES ($groupId, "${contact.displayName}", "${contact.phones.map((e) => e.number).join(', ')}", $active)
        ''');
      }
      readData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _pickContacts,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(tital: 'مجموعة ساعة: $time'),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text("لا توجد جهات اتصال"))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          title: Text(list[i]['name']),
                          subtitle: Text(list[i]['phone']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.phone,
                                    color: Colors.green),
                                onPressed: () => launchUrl(
                                    Uri(scheme: 'tel', path: list[i]['phone'])),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await sqlDb.deleteData(
                                      "DELETE FROM Contacts WHERE id = ${list[i]['id']}");
                                  readData();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    _filteredContacts = List.from(_contacts);
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
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "بحث",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("إلغاء"),
        ),
        TextButton(
          onPressed: () {
            List<Contact> finalContacts = List.from(_selectedContacts);
            _selectedContacts.clear(); // إعادة ضبط القائمة
            Navigator.pop(context, finalContacts);
          },
          child: Text("تأكيد"),
        ),
      ],
    );
  }
}
