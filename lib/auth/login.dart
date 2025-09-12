import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype/admin_app/admin_home.dart';
import 'package:prototype/customer_app/core/sessio_manager.dart';
import 'package:prototype/customer_app/customer_home.dart';
import 'package:prototype/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final CollectionReference customerRef = FirebaseFirestore.instance.collection(
    'customers',
  );

  final SessionManager _session = SessionManager();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// 🔹 Check saved login (Admin OR Customer)
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 🔸 Admin session check
    bool isAdminLoggedIn = prefs.getBool('isAdminLoggedIn') ?? false;
    if (isAdminLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHome()),
      );
      return;
    }

    // 🔸 Customer session check
    final session = await _session.getSession();
    final docId = session['docId'];
    if (docId != null) {
      final docSnapshot = await customerRef.doc(docId).get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        if (userData['active'] == true && userData['isLoggedIn'] == true) {
          _session.attachListener(context, docId);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerHomePage(userData: userData),
            ),
          );
        } else {
          await _session.clearSession();
        }
      }
    }
  }

  /// 🔹 Login method (Admin OR Customer)
  Future<void> _login() async {
    setState(() => loading = true);

    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // ✅ Case 1: Admin
    if (username == "Admin" && password == "admin@123") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdminLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHome()),
      );

      setState(() => loading = false);
      return;
    }

    // ✅ Case 2: Customer (Firestore)
    final query = await customerRef
        .where('name', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();

    if (query.docs.isNotEmpty) {
      final userDoc = query.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData['active'] == true) {
        if (userData['isLoggedIn'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "This account is already logged in on another device",
              ),
            ),
          );
        } else {
          await userDoc.reference.update({'isLoggedIn': true});
          await _session.saveSession(username, userDoc.id);
          _session.attachListener(context, userDoc.id);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerHomePage(userData: userData),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Your account is not active")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid credentials")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kprimerycolor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Ozvol Login",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            // Username
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: usernameController,
              decoration: InputDecoration(
                hintText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Password
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kseccolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _login,
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
