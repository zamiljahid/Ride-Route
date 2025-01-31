import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:delivary/screens/dashboard/model/profile_model.dart';
import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../shared_preference.dart';
import '../splash screen/splash_screen.dart';
import 'edit_profile_screen.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<ProfileModel?> _fetchUserData(BuildContext context) async {
    final String? userId = SharedPrefs.getString('id');
    final String? token = SharedPrefs.getString('token');

    if (userId != null && token != null) {
      try {
        return await ApiClient().getProfile('?user=${userId.toString()}', token, context);
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'P R O F I L E',
          style: TextStyle(fontFamily: 'Rowdies'),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () async {
            bool? shouldLogout = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: CustomColors.navyBlue.withOpacity(.8),
                  title: Text('Logout', style: TextStyle(color: CustomColors.white)),
                  content: Text('Are you sure you want to log out?', style: TextStyle(color: CustomColors.white)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel', style: TextStyle(color: CustomColors.white)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Logout', style: TextStyle(color: CustomColors.white)),
                    ),
                  ],
                );
              },
            );
            if (shouldLogout == true) {
              await SharedPrefs.remove('token');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SplashScreen()),
                    (route) => false,
              );
            }
          },
          icon: const Icon(
            Icons.exit_to_app_outlined,
            color: CustomColors.customeBlue,
            size: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
            icon: const Icon(
              Icons.settings,
              color: CustomColors.customeBlue,
              size: 35,
            ),
          ),
        ],
      ),
      body: FutureBuilder<ProfileModel?>(
        future: _fetchUserData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data found.'));
          } else {
            ProfileModel user = snapshot.data!;
            String? profilePic = user.profilePicture;
            String empName = '${user.firstName} ${user.lastName}'.trim();
            String empId = user.id.toString();
            String contact = user.contactNumber ?? '';
            String nationality = user.nationality ?? '';

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(width: 2, color: CustomColors.white),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF010159),
                          blurRadius: 9.0,
                          spreadRadius: 7.0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: profilePic != null && profilePic.isNotEmpty
                          ? Image.network(
                        profilePic,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 100, color: Colors.white);
                        },
                      )
                          : Icon(Icons.person, size: 100, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Name: $empName',
                    style: const TextStyle(fontSize: 20, fontFamily: 'Rowdies'),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'ID: $empId',
                    style: const TextStyle(fontSize: 20, fontFamily: 'Rowdies'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Contact: $contact',
                    style: const TextStyle(fontSize: 20, fontFamily: 'Rowdies'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nationality: $nationality',
                    style: const TextStyle(fontSize: 20, fontFamily: 'Rowdies'),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

