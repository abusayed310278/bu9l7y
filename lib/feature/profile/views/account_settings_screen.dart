import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/profile/views/personal_details_screen.dart';
import 'package:bu9l7y/feature/profile/views/update_password_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
                    color: const Color(0xFF1F2224),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Account Settings',
                    style: GoogleFonts.outfit(fontSize: 16, height: 1.0, color: Color(0xFF1F2224), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _AccountHeader(),
              const SizedBox(height: 34),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'General Settings',
                  style: GoogleFonts.outfit(fontSize: 16, height: 1.0, color: const Color(0xFF1F2224), fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),
              _settingTile(
                iconPath: Images.personalDetails,
                title: 'Personal Details',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PersonalDetailsScreen()));
                },
              ),
              const SizedBox(height: 12),
              _settingTile(
                iconPath: Images.password,
                title: 'Update Password',
                subtitle: 'Last updated 3 months ago',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const UpdatePasswordScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile({required String iconPath, required String title, String? subtitle, VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 40, height: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Color(0xFF1F2224), fontWeight: FontWeight.w400),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: Color(0xFF8A8E95), fontWeight: FontWeight.w400),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 24, color: Color(0xFF888C92)),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: user == null
          ? null
          : FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
      builder: (context, snapshot) {
        final Map<String, dynamic>? data = snapshot.data?.data();
        final String name = _readName(data, user);
        final String imageUrl = _readImageUrl(data, user);

        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD4C8BE),
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: 74,
                            height: 74,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person_rounded,
                              size: 42,
                              color: Color(0xFF6E5F55),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 42,
                          color: Color(0xFF6E5F55),
                        ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(Images.edit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 16,
                height: 1.2,
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  String _readName(Map<String, dynamic>? data, User? user) {
    final String firestoreName = (data?['fullName'] as String?)?.trim() ?? '';
    final String authName = (user?.displayName ?? '').trim();
    if (firestoreName.isNotEmpty) {
      return firestoreName;
    }
    if (authName.isNotEmpty) {
      return authName;
    }
    return 'User';
  }

  String _readImageUrl(Map<String, dynamic>? data, User? user) {
    final List<String> keys = <String>[
      'image',
      'avatarUrl',
      'photoURL',
      'photoUrl',
      'imageUrl',
    ];
    for (final String key in keys) {
      final String value = (data?[key] as String?)?.trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return (user?.photoURL ?? '').trim();
  }
}
