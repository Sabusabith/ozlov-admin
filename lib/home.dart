import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototype/auth/login.dart';
import 'package:prototype/customer.dart';
import 'package:prototype/stock/stock.dart';
import 'package:prototype/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = [StocksPage(), const CustomersPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        shape: Border(),
        width: MediaQuery.of(context).size.width / 2.5,
        backgroundColor: kprimerycolor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Icon(
                      CupertinoIcons.person_alt_circle,
                      size: 45,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Admin",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                // Navigate to login screen
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('email'); // Clear logged-in user
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              },
              child: Icon(Icons.logout, color: Colors.white, size: 35),
            ),
          ],
        ),
      ),
      backgroundColor: kprimerycolor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set your desired color
          size: 28, // Optional: change size
        ),
        leadingWidth: 30,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 15),
            Text("Ozvol", style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: kseccolor,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black.withOpacity(.7),
        backgroundColor: kseccolor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Stocks"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Customers"),
        ],
      ),
    );
  }
}
