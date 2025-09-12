// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:prototype/customer/add_edit_cutomer_dialogue.dart';

// class CustomerActions extends StatelessWidget {
//   final String docId;
//   final String name;
//   final String phone;
//   final bool isActive;

//   const CustomerActions({
//     super.key,
//     required this.docId,
//     required this.name,
//     required this.phone,
//     required this.isActive,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final CollectionReference customersRef = FirebaseFirestore.instance
//         .collection('customers');

//     return Row(
//       children: [
//         // Edit Button
//         IconButton(
//           icon: const Icon(Icons.edit, color: Colors.white),
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (context) => AddEditCustomerDialog(
//                 docId: docId,
//                 name: name,
//                 phone: phone,
//                 isActive: isActive,
//               ),
//             );
//           },
//         ),

//         // Delete Button
//         IconButton(
//           icon: const Icon(Icons.delete, color: Colors.redAccent),
//           onPressed: () async {
//             final confirm = await showDialog<bool>(
//               context: context,
//               builder: (context) => AlertDialog(
//                 title: const Text('Delete Customer'),
//                 content: const Text(
//                   'Are you sure you want to delete this customer?',
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, false),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, true),
//                     child: const Text(
//                       'Delete',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 ],
//               ),
//             );

//             if (confirm == true) {
//               try {
//                 await customersRef.doc(docId).delete();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Customer deleted'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Error deleting customer: $e'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             }
//           },
//         ),
//       ],
//     );
//   }
// }
