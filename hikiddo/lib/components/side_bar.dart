// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hikiddo/constants.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  // Function to launch URL
  void launchMailto(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@hikiddo.com',
    );
    if (!await launchUrl(emailUri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 200.0,
            width: double.infinity,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color:
                    Colors.white, // Choose a color that fits your app's style
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Align items in the Row to space between
                children: [
                  const Text(
                    'Menu ',
                    style: TextStyle(
                      color: greenColor,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.black), // Close icon with white color
                    onPressed: () => Navigator.of(context)
                        .pop(), // Close the drawer when tapped
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled:
                    true, // Allows the bottom sheet to be larger than half the screen
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                    heightFactor:
                        0.75, // Makes the bottom sheet take up 80% of the screen height
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal:
                              16.0), // Horizontal padding for the content
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: [
                              const Align(
                                alignment: Alignment
                                    .center, // Centers the title horizontally
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      16.0), // Padding around the title
                                  child: Text(
                                    'About', // Title
                                    style: TextStyle(
                                      color: orangeColor,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right:
                                    0, // Positions the close button on the right
                                child: IconButton(
                                  icon: const Icon(Icons.close), // Close icon
                                  onPressed: () => Navigator.pop(
                                      context), // Closes the bottom sheet
                                ),
                              ),
                            ],
                          ),
                          const Expanded(
                            child: SingleChildScrollView(
                              // Makes the content scrollable
                              child: Text(
                                'Introducing Hikiddo, the innovative app designed to strengthen '
                                'the bond between parents and their children. '
                                'In a fast-paced world, where technology often creates distance, '
                                'Hikiddo takes a different approach by leveraging the power '
                                'of connectivity to bring families closer together. ',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(
                Icons.mail), // Choose an icon that fits the menu item
            title: const Text('Contact'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled:
                    true, // Allows the bottom sheet to be larger than half the screen
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                    heightFactor:
                        0.75, // Makes the bottom sheet take up 80% of the screen height
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal:
                              16.0), // Horizontal padding for the content
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: [
                              const Align(
                                alignment: Alignment
                                    .center, // Centers the title horizontally
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      16.0), // Padding around the title
                                  child: Text(
                                    'Contact us', // Title
                                    style: TextStyle(
                                        color: orangeColor,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                right:
                                    0, // Positions the close button on the right
                                child: IconButton(
                                  icon: const Icon(Icons.close), // Close icon
                                  onPressed: () => Navigator.pop(
                                      context), // Closes the bottom sheet
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              // Makes the content scrollable
                              padding: const EdgeInsets.all(
                                  16.0), // Optional: Add padding around the content
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const SizedBox(
                                      height:
                                          20), // Adds space between the title and the first line of text
                                  const Text(
                                    'For general queries or information about the app, please send an email to:',
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.justify,
                                  ),
                                  const SizedBox(
                                      height:
                                          10), // Adds space between lines of text
                                  InkWell(
                                    onTap: () {
                                      launchMailto(context);
                                    }, // Updated to call the revised method
                                    child: const Text(
                                      'support@hikiddo.com',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          10), // Adds space between lines of text
                                  const Text(
                                    'Our dedicated support team will get back to you as soon as possible.',
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Add more ListTile widgets for other menu items as needed...
        ],
      ),
    );
  }
}
