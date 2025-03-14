import 'package:flutter/material.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart'; // استيراد الحزمة
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
  List<Contact> selectedContacts = []; // جهات الاتصال المحددة
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
        _checkAndRequestPermission(); // طلب إذن الوصول إلى جهات الاتصال
      }
    });
  }

  // طلب الإذن للوصول إلى جهات الاتصال
  Future<void> _checkAndRequestPermission() async {
    final permissionStatus = await Permission.contacts.status;
    if (!permissionStatus.isGranted) {
      await Permission.contacts.request();
    }
    readData();
  }

  // قراءة البيانات من قاعدة البيانات
  Future<void> readData() async {
    list.clear();
    List<Map> response = await sqlDb.readData(
      "SELECT * FROM Contacts WHERE group_id = $groupId ORDER BY name ASC",
    );
    list.addAll(response);
    if (mounted) setState(() {});
  }

  // إضافة جهات الاتصال المحددة إلى قاعدة البيانات
  Future<void> _pickContacts() async {
    final selectedContactsFromPicker = await Navigator.push<List<Contact>>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ContactPickerScreen(selectedContacts: selectedContacts),
      ),
    );
    if (selectedContactsFromPicker != null) {
      setState(() {
        selectedContacts = selectedContactsFromPicker;
      });

      // إضافة جهات الاتصال إلى قاعدة البيانات مع التحقق من التكرار
      for (var contact in selectedContactsFromPicker) {
        // التأكد من عدم وجود جهة الاتصال مسبقًا
        bool exists = await _checkIfContactExists(contact);
        if (!exists) {
          await sqlDb.insertData(''' 
            INSERT INTO Contacts (group_id, name, phone, active)
            VALUES ($groupId, "${contact.displayName}", "${contact.phones.map((e) => e.number).join(', ')}", $active)
          ''');
        }
      }
      readData();
    }
  }

  // التحقق من وجود جهة الاتصال في قاعدة البيانات
  Future<bool> _checkIfContactExists(Contact contact) async {
    List<Map> result = await sqlDb.readData('''
      SELECT * FROM Contacts WHERE name = "${contact.displayName}" AND group_id = $groupId
    ''');
    return result.isNotEmpty;
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
              child:
                  list.isEmpty
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
                                  icon: const Icon(
                                    Icons.phone,
                                    color: Colors.green,
                                  ),
                                  onPressed:
                                      () => launchUrl(
                                        Uri(
                                          scheme: 'tel',
                                          path: list[i]['phone'],
                                        ),
                                      ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await sqlDb.deleteData(
                                      "DELETE FROM Contacts WHERE id = ${list[i]['id']}",
                                    );
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

class ContactPickerScreen extends StatefulWidget {
  final List<Contact> selectedContacts;

  ContactPickerScreen({required this.selectedContacts});

  @override
  _ContactPickerScreenState createState() => _ContactPickerScreenState();
}

class _ContactPickerScreenState extends State<ContactPickerScreen> {
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
    await Permission.contacts.request(); // طلب الإذن هنا أيضًا
    _contacts = await FastContacts.getAllContacts();
    _filteredContacts = List.from(_contacts);
    setState(() => _isLoading = false);
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      // فلترة العناصر المحددة وغير المحددة معًا
      _filteredContacts = [
        ..._selectedContacts.where(
          (contact) =>
              contact.displayName.toLowerCase().contains(query) ||
              contact.phones.any(
                (phone) =>
                    phone.number.replaceAll(RegExp(r'\D'), '').contains(query),
              ),
        ),
        ..._contacts.where(
          (contact) =>
              !_selectedContacts.contains(
                contact,
              ) && // التأكد من أن العنصر غير محدد
              (contact.displayName.toLowerCase().contains(query) ||
                  contact.phones.any(
                    (phone) => phone.number
                        .replaceAll(RegExp(r'\D'), '')
                        .contains(query),
                  )),
        ),
      ];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("اختر جهات الاتصال"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedContacts);
            },
            child: const Text("تأكيد", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "بحث",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
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
    );
  }
}
