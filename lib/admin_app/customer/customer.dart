import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype/utils/colors.dart';
import 'package:shimmer/shimmer.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final CollectionReference customersRef = FirebaseFirestore.instance
      .collection("customers");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kprimerycolor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customers",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: customersRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[600]!,
                            child: Container(height: 50, color: Colors.white),
                          ),
                        );
                      },
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading customers"));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text("No customers found"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return customerItem(
                        docs[index].id,
                        data["name"] ?? "",
                        data["phone"] ?? "",
                        data["active"] ?? false,
                        data["password"] ?? "",
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditCustomerDialog(context),
        backgroundColor: kseccolor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Customer row with actions
  Widget customerItem(
    String docId,
    String name,
    String phone,
    bool isActive,
    String password,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
              ),
              Text(phone, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              Switch(
                value: isActive,
                onChanged: (value) {
                  customersRef.doc(docId).update({
                    'active': value,
                    if (!value)
                      'isLoggedIn':
                          false, // Set isLoggedIn to false if deactivated
                  });
                },
                activeColor: Colors.orange,
              ),

              CustomerActions(
                docId: docId,
                name: name,
                phone: phone,
                password: password,
                isActive: isActive,
                onUpdated: () => setState(() {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add or Edit customer dialog
  void _showAddOrEditCustomerDialog(
    BuildContext context, {
    String? docId,
    String? initialName,
    String? initialPhone,
    String? initialPassword,
    bool initialActive = false,
  }) {
    final nameController = TextEditingController(text: initialName ?? '');
    final phoneController = TextEditingController(text: initialPhone ?? '');
    final passwordController = TextEditingController(
      text: initialPassword ?? '',
    );

    bool accessEnabled = initialActive;
    bool isSaving = false;
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFF3B2E2E),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docId == null ? "Add Customer" : "Edit Customer",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Customer Name"),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: phoneController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration("Mobile Number"),
                      ),
                      const SizedBox(height: 20),
                      // PASSWORD FIELD
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Password").copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setStateDialog(
                                () => obscurePassword = !obscurePassword,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Access Enabled",
                            style: TextStyle(color: Colors.white),
                          ),
                          Switch(
                            value: accessEnabled,
                            onChanged: (value) {
                              setStateDialog(() => accessEnabled = value);
                            },
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (nameController.text.isEmpty ||
                                        phoneController.text.isEmpty ||
                                        passwordController.text.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "Please fill all required fields",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setStateDialog(() => isSaving = true);

                                    try {
                                      if (docId == null) {
                                        await customersRef.add({
                                          "name": nameController.text,
                                          "phone": phoneController.text,
                                          "password": passwordController.text,
                                          "active": accessEnabled,
                                          "isLoggedIn": false,
                                          "timestamp":
                                              FieldValue.serverTimestamp(),
                                        });
                                      } else {
                                        await customersRef.doc(docId).update({
                                          "name": nameController.text,
                                          "phone": phoneController.text,
                                          "password": passwordController.text,
                                          "active": accessEnabled,
                                        });
                                      }

                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                            docId == null
                                                ? "Customer Added"
                                                : "Customer Updated",
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      setStateDialog(() => isSaving = false);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text("Error: $e"),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(docId == null ? "Save" : "Update"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.transparent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.orange),
      ),
    );
  }
}

// Separate widget for Edit/Delete actions
class CustomerActions extends StatelessWidget {
  final String docId;
  final String name;
  final String phone;
  final String password;
  final bool isActive;
  final VoidCallback? onUpdated;

  const CustomerActions({
    super.key,
    required this.docId,
    required this.name,
    required this.phone,
    required this.password,
    required this.isActive,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.orange),
          onPressed: () {
            final parentState = context
                .findAncestorStateOfType<_CustomersPageState>();
            parentState?._showAddOrEditCustomerDialog(
              context,
              docId: docId,
              initialName: name,
              initialPhone: phone,
              initialPassword: password,
              initialActive: isActive,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('customers')
                .doc(docId)
                .delete();
            if (onUpdated != null) onUpdated!();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text("Customer Deleted"),
              ),
            );
          },
        ),
      ],
    );
  }
}
