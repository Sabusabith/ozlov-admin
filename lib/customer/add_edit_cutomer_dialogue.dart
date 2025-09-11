// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:prototype/utils/colors.dart';

// class AddEditCustomerDialog extends StatefulWidget {
//   final String? docId;
//   final String? name;
//   final String? phone;
//   final bool? isActive;

//   const AddEditCustomerDialog({
//     super.key,
//     this.docId,
//     this.name,
//     this.phone,
//     this.isActive,
//   });

//   @override
//   State<AddEditCustomerDialog> createState() => _AddEditCustomerDialogState();
// }

// class _AddEditCustomerDialogState extends State<AddEditCustomerDialog> {
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool accessEnabled = false;
//   bool isSaving = false;

//   final CollectionReference customersRef = FirebaseFirestore.instance
//       .collection('customers');

//   @override
//   void initState() {
//     super.initState();
//     if (widget.name != null) nameController.text = widget.name!;
//     if (widget.phone != null) phoneController.text = widget.phone!;
//     accessEnabled = widget.isActive ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       backgroundColor: const Color(0xFF3B2E2E),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.docId == null ? 'Add Customer' : 'Edit Customer',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: nameController,
//               style: const TextStyle(color: Colors.white),
//               decoration: _inputDecoration('Customer Name'),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: phoneController,
//               style: const TextStyle(color: Colors.white),
//               keyboardType: TextInputType.phone,
//               decoration: _inputDecoration('Mobile Number'),
//             ),
//             const SizedBox(height: 20),
//             if (widget.docId == null)
//               TextField(
//                 controller: passwordController,
//                 style: const TextStyle(color: Colors.white),
//                 obscureText: true,
//                 decoration: _inputDecoration('Password'),
//               ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Access Enabled',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 Switch(
//                   value: accessEnabled,
//                   onChanged: (value) {
//                     setState(() {
//                       accessEnabled = value;
//                     });
//                   },
//                   activeColor: Colors.orange,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(color: Colors.orange),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: isSaving ? null : _saveCustomer,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: isSaving
//                       ? const SizedBox(
//                           height: 18,
//                           width: 18,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text('Save'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _saveCustomer() async {
//     if (nameController.text.isEmpty || phoneController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.red,
//           content: Text("Please fill all required fields"),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       isSaving = true;
//     });

//     try {
//       if (widget.docId != null) {
//         await customersRef.doc(widget.docId).update({
//           'name': nameController.text,
//           'phone': phoneController.text,
//           'active': accessEnabled,
//         });
//       } else {
//         await customersRef.add({
//           'name': nameController.text,
//           'phone': phoneController.text,
//           'password': passwordController.text,
//           'active': accessEnabled,
//           'isLoggedIn': false,
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//       }

//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Customer saved'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       setState(() {
//         isSaving = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//       );
//     }
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.white70),
//       filled: true,
//       fillColor: Colors.transparent,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6),
//         borderSide: const BorderSide(color: Colors.white54),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6),
//         borderSide: const BorderSide(color: Colors.white54),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6),
//         borderSide: const BorderSide(color: Colors.orange),
//       ),
//     );
//   }
// }
