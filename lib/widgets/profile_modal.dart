import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_inc/providers/user_provider.dart';

class ProfileModal extends StatelessWidget {
  final String fullName;
  final String profileImage;
  final bool isDayMode;
  final String role; // 'Student', 'Teacher', or default
  final VoidCallback onNavigateToSettings;

  const ProfileModal({
    Key? key,
    required this.fullName,
    required this.profileImage,
    required this.isDayMode,
    required this.role,
    required this.onNavigateToSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Container(
      color: isDayMode ? Colors.white : const Color(0xFF37474F),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 40,
            backgroundImage: profileImage.startsWith('http')
                ? NetworkImage(profileImage)
                : AssetImage(profileImage) as ImageProvider,
          ),
          const SizedBox(height: 10),
          // User Name
          Text(
            fullName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDayMode ? Colors.black87 : Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Role-specific Options
          if (role == 'Teacher')
            ListTile(
              leading: Icon(
                Icons.class_,
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
              title: Text(
                'Manage Classes',
                style: TextStyle(
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/manage_classes');
              },
            ),
          if (role == 'Student')
            ListTile(
              leading: Icon(
                Icons.assignment,
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
              title: Text(
                'View Assignments',
                style: TextStyle(
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/view_assignments');
              },
            ),

          // Shared Options for All Roles
          ListTile(
            leading: Icon(
              Icons.settings,
              color: isDayMode ? Colors.black87 : Colors.white,
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
            ),
            onTap: onNavigateToSettings,
          ),

          ListTile(
            leading: Icon(
              isDayMode ? Icons.wb_sunny : Icons.nights_stay,
              color: isDayMode ? Colors.black87 : Colors.white,
            ),
            title: Text(
              isDayMode ? 'Switch to Night Mode' : 'Switch to Day Mode',
              style: TextStyle(
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
            ),
            onTap: () {
              userProvider.toggleTheme(); // Toggle theme globally
              Navigator.pop(context); // Close the modal
            },
          ),

          ListTile(
            leading: Icon(
              Icons.logout,
              color: isDayMode ? Colors.black87 : Colors.white,
            ),
            title: Text(
              'Log Out',
              style: TextStyle(
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
            ),
            onTap: () {
              userProvider.logout();
              Navigator.pop(context); // Close modal
              Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
            },
          ),
        ],
      ),
    );
  }
}
