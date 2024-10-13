import 'package:flutter/material.dart';
import 'package:frontend/controllers/auth_service.dart';
import 'package:frontend/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final response = await _authService.getCurrentUser();
      setState(() {
        _user = response;
      });
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF004AAD),
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/man.png') as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_user!.name} ${_user!.lname}', // Display name and last name
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(  // Fixed headline5 to headlineSmall
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004AAD),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user!.email, // Display email
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(   // Fixed subtitle1 to titleMedium
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Divider(thickness: 2),
                  const SizedBox(height: 16),
                  Text(
                    'ตำแหน่ง: ${_user!.role}', // Display role
                    style: Theme.of(context).textTheme.bodyLarge,  // Fixed bodyText1 to bodyLarge
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.logOut(); // Call the logout method
                      Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red color for logout button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 3, // Profile is selected
        selectedItemColor: Color(0xFF004AAD),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Handle navigation based on the index
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home'); // Navigate to Home Page
              break;
            case 1:
              Navigator.pushNamed(context, '/events'); // Navigate to Events Page
              break;
            case 2:
              Navigator.pushNamed(context, '/notifications'); // Navigate to Notifications Page
              break;
            case 3:
              // Do nothing since we're already on the profile page
              break;
          }
        },
      ),
    );
  }
}
