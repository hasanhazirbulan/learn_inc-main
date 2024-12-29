import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileModal extends StatelessWidget {
  final String fullName;
  final String profileImage;
  final bool isDayMode;
  final String role;
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
      decoration: BoxDecoration(
        color: isDayMode ? Colors.white : const Color(0xFF37474F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 40,
              backgroundImage: profileImage.isNotEmpty && (profileImage.startsWith('http') || profileImage.startsWith('assets/'))
                  ? (profileImage.startsWith('http')
                  ? NetworkImage(profileImage)
                  : AssetImage(profileImage)) as ImageProvider
                  : const AssetImage('assets/default_avatar.png'),
              backgroundColor: Colors.grey[200], // Optional: Add a background color for contrast
            ),

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

            // Navigate to Settings Button
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

            // Role-Specific Navigation
            if (role == 'students')
              ListTile(
                leading: Icon(
                  Icons.school,
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
                title: Text(
                  'My Courses',
                  style: TextStyle(
                    color: isDayMode ? Colors.black87 : Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/courses');
                },
              ),
            if (role == 'teachers')
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

            // Theme Toggle
            ListTile(
              leading: Icon(
                isDayMode ? Icons.dark_mode : Icons.light_mode,
                color: isDayMode ? Colors.black87 : Colors.white,
              ),
              title: Text(
                isDayMode ? 'Switch to Dark Mode' : 'Switch to Light Mode',
                style: TextStyle(
                  color: isDayMode ? Colors.black87 : Colors.white,
                ),
              ),
              onTap: () {
                userProvider.toggleTheme();
                Navigator.pop(context);
              },
            ),

            // Logout Button
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
                Navigator.pop(context); // Close the modal
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final bool isDayMode;

  const SettingsScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController nameController = TextEditingController();
  String? selectedAvatar;

  final List<String> avatarPaths = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void updateProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final newName = nameController.text.trim();

    if (newName.isNotEmpty) {
      userProvider.updateUserName(newName);
    }

    if (selectedAvatar != null) {
      userProvider.updateUserProfileImage(selectedAvatar!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: widget.isDayMode ? Colors.blue : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Name:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: userProvider.user?.fullName ?? 'Enter your name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Choose an Avatar:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: avatarPaths.length,
              itemBuilder: (context, index) {
                final avatarPath = avatarPaths[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatar = avatarPath;
                    });
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(avatarPath),
                    child: selectedAvatar == avatarPath
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: updateProfile,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
