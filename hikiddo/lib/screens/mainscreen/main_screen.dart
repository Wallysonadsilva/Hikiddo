import 'package:flutter/material.dart';
import 'package:hikiddo/components/side_bar.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/components/bottom_navigation.dart';
import 'package:hikiddo/screens/homepage/homepage_screen.dart';
import 'package:hikiddo/screens/location/location_screen.dart';
import 'package:hikiddo/screens/welcome/welcome_screen.dart';
import 'package:hikiddo/services/auth.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {

  int currentIndex = 1;
  final AuthService _auth = AuthService();

  final pages = [
    const UserProfilePage(),
    const HomePageScreen(),
    const LocationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('HIKIDDO!', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              await _auth.signOut(context);
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const WelcomeScreen()),
              );
            },
          )
        ],
      ),
      body: pages[currentIndex],
      drawer: const SideBar(),
      bottomNavigationBar: BottomNavigationBarComp(
        currentIndex: currentIndex,
        onTap: (index){
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
