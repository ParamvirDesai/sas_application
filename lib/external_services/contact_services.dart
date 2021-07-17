// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

class Services {
  Future<Contact?> contacts() async {
    final FlutterContactPicker _contactPicker = new FlutterContactPicker();
    Contact? contact = await _contactPicker.selectContact();
    return contact;
  }
}
