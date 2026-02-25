import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/auth/views/sign_in_screen.dart';
import 'package:bu9l7y/feature/profile/views/account_settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _ProfileHeader(),
            const SizedBox(height: 48),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 343,
                height: 20,
                child: Text(
                  'Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    height: 1,
                    color: const Color(0xFF1F2224),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _settingTile(
              iconPath: Images.settings,
              title: 'Account Settings',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: Color(0xFF888C92),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AccountSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _settingTile(
              iconPath: Images.logout,
              title: 'Log Out',
              titleColor: const Color(0xFFE11D2E),
              onTap: () => _showLogoutCard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile({
    required String iconPath,
    required String title,
    Color titleColor = const Color(0xFF2A2E35),
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 40, height: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  height: 1.2,
                  color: titleColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ...?(trailing == null ? null : <Widget>[trailing]),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutCard(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure want to Log out',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    height: 1.2,
                    color: Color(0xFF1F2224),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap log out to Log out from this app.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    height: 1.2,
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD9D9D9),
                            foregroundColor: const Color(0xFF1F2224),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute<void>(
                                builder: (_) => const SignInScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA002A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Log out',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
