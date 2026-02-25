import 'dart:io';
import 'dart:async';

import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/core/network/api_service/token_meneger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _avatarFile;
  String? _avatarUrl;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _firestoreAvailable = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _avatarFile = File(picked.path);
    });
  }

  Future<void> _loadProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login again.')));
      return;
    }

    final String rememberedEmail =
        (await TokenManager.getRememberedEmail() ?? '').trim();
    final String fallbackEmail = (user.email ?? rememberedEmail).trim();
    final String fallbackPhone = (user.phoneNumber ?? '').trim();

    try {
      final DocumentSnapshot<Map<String, dynamic>> profileDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      final Map<String, dynamic>? data = profileDoc.data();

      _nameController.text =
          (data?['fullName'] as String?)?.trim().isNotEmpty == true
          ? data!['fullName'] as String
          : (user.displayName ?? '');
      _emailController.text =
          (data?['email'] as String?)?.trim().isNotEmpty == true
          ? data!['email'] as String
          : fallbackEmail;
      _phoneController.text =
          (data?['phone'] as String?)?.trim().isNotEmpty == true
          ? data!['phone'] as String
          : fallbackPhone;
      _bioController.text = (data?['bio'] as String?) ?? '';
      _avatarUrl = await _resolveAvatarUrl(data, user);
    } on MissingPluginException {
      _firestoreAvailable = false;
      _nameController.text = user.displayName ?? '';
      _emailController.text = fallbackEmail;
      _phoneController.text = fallbackPhone;
      _bioController.text = '';
      _avatarUrl = (user.photoURL ?? '').trim();
    } on FirebaseException catch (e) {
      final String rawMessage = (e.message ?? '').toLowerCase();
      final bool isChannelUnavailable =
          rawMessage.contains('unable to establish connection on channel') ||
          rawMessage.contains('channel-error');
      if (isChannelUnavailable) {
        _firestoreAvailable = false;
        _nameController.text = user.displayName ?? _nameController.text;
        _emailController.text = fallbackEmail;
        _phoneController.text = fallbackPhone;
        _bioController.text = _bioController.text;
        _avatarUrl = (user.photoURL ?? '').trim();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Firestore channel unavailable. Running in fallback mode.',
              ),
            ),
          );
        }
        return;
      }
      if (mounted) {
        final String message;
        if (e.code == 'permission-denied') {
          message = 'Firestore permission denied. Update Firestore rules.';
        } else if (e.code == 'unavailable') {
          message = 'No internet connection. Please try again.';
        } else {
          message = e.message ?? 'Failed to load profile data.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _readStringValue(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    return value.toString().trim();
  }

  String _extractAvatarCandidate(Map<String, dynamic>? data) {
    if (data == null) {
      return '';
    }

    final List<String> keys = <String>[
      'avatarUrl',
      'avatarURL',
      'avatar',
      'photoURL',
      'photoUrl',
      'image',
      'imageUrl',
      'profileImage',
      'profile_image',
    ];
    for (final String key in keys) {
      final String value = _readStringValue(data[key]);
      if (value.isNotEmpty) {
        return value;
      }
    }

    final dynamic avatarObj = data['avatar'];
    if (avatarObj is Map<String, dynamic>) {
      final String nestedUrl = _readStringValue(avatarObj['url']).isNotEmpty
          ? _readStringValue(avatarObj['url'])
          : _readStringValue(avatarObj['downloadURL']);
      if (nestedUrl.isNotEmpty) {
        return nestedUrl;
      }
    }

    return '';
  }

  Future<String> _resolveAvatarUrl(
    Map<String, dynamic>? data,
    User user,
  ) async {
    String candidate = _extractAvatarCandidate(data);
    if (candidate.isEmpty) {
      candidate = _readStringValue(user.photoURL);
    }
    if (candidate.isEmpty) {
      return '';
    }
    if (candidate.startsWith('gs://')) {
      try {
        return await _storage.refFromURL(candidate).getDownloadURL();
      } catch (e) {
        debugPrint('Failed to resolve gs avatar URL: $e');
        return '';
      }
    }
    return candidate;
  }

  Future<String> _uploadAvatar({
    required String uid,
    required File file,
  }) async {
    final List<String> parts = file.path.split('.');
    final String rawExtension = parts.length > 1 ? parts.last.toLowerCase() : '';
    final RegExp extensionPattern = RegExp(r'^[a-z0-9]{1,5}$');
    final String safeExtension = extensionPattern.hasMatch(rawExtension)
        ? rawExtension
        : 'jpg';
    final String contentType = switch (safeExtension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
    final Reference ref = _storage
        .ref()
        .child('users')
        .child(uid)
        .child(
          'avatar_${DateTime.now().millisecondsSinceEpoch}.$safeExtension',
        );

    await ref.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );

    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        return await ref.getDownloadURL();
      } on FirebaseException catch (e) {
        final bool isRetryable = e.code == 'object-not-found';
        final bool hasMoreAttempts = attempt < 2;
        if (!isRetryable || !hasMoreAttempts) {
          rethrow;
        }
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }

    throw FirebaseException(
      plugin: 'firebase_storage',
      code: 'object-not-found',
      message: 'Avatar upload completed but URL could not be resolved.',
    );
  }

  Future<void> _uploadAvatarInBackground({
    required User user,
    required File avatarFile,
  }) async {
    try {
      final String url = await _uploadAvatar(
        uid: user.uid,
        file: avatarFile,
      ).timeout(const Duration(seconds: 20));

      bool firestoreFailed = false;
      bool authPhotoFailed = false;

      if (_firestoreAvailable) {
        try {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set({
                'avatarUrl': url,
                'image': url,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true))
              .timeout(const Duration(seconds: 12));
        } catch (e) {
          firestoreFailed = true;
          debugPrint('Avatar Firestore update failed: $e');
        }
      }

      if (user.photoURL != url) {
        try {
          await user.updatePhotoURL(url);
        } catch (e) {
          authPhotoFailed = true;
          debugPrint('Avatar auth profile update failed: $e');
        }
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _avatarUrl = url;
        _avatarFile = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            firestoreFailed || authPhotoFailed
                ? 'Photo uploaded. Some profile sync steps failed.'
                : 'Profile photo updated.',
          ),
        ),
      );
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo upload timed out. Try again.')),
      );
    } on FirebaseException catch (e) {
      debugPrint('Avatar upload failed [${e.code}]: ${e.message}');
      if (!mounted) {
        return;
      }
      final String message;
      if (e.code == 'permission-denied') {
        message = 'Storage permission denied. Check Firebase Storage rules.';
      } else if (e.code == 'unauthenticated') {
        message = 'Please login again, then retry photo upload.';
      } else if (e.code == 'object-not-found') {
        message = 'Upload completed but file URL was not ready. Try again.';
      } else if (e.code == 'unauthorized') {
        message = 'You are not allowed to upload this photo.';
      } else {
        message = 'Profile saved, but photo upload failed.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      debugPrint('Avatar upload failed: $e');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved, but photo upload failed.'),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) {
      return;
    }

    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login again.')));
      return;
    }

    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String bio = _bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Full name is required.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final String rememberedEmail =
          (await TokenManager.getRememberedEmail() ?? '').trim();
      final String email = (user.email ?? rememberedEmail).trim();
      _emailController.text = email;
      final File? pendingAvatarFile = _avatarFile;
      final bool hasPendingAvatar = pendingAvatarFile != null;

      if (_firestoreAvailable) {
        final Map<String, dynamic> payload = <String, dynamic>{
          'uid': user.uid,
          'fullName': name,
          'phone': phone,
          'bio': bio,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (email.isNotEmpty) {
          payload['email'] = email;
        }
        if (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty) {
          final String avatar = _avatarUrl!.trim();
          payload['avatarUrl'] = avatar;
          payload['image'] = avatar;
        }

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(payload, SetOptions(merge: true));
      }

      String successMessage = 'Profile updated successfully.';
      if (user.displayName != name) {
        try {
          await user.updateDisplayName(name);
        } on FirebaseAuthException catch (e) {
          debugPrint('updateDisplayName failed: ${e.code} ${e.message}');
          successMessage =
              'Profile saved, but auth display name update failed.';
        }
      }
      if (!_firestoreAvailable) {
        successMessage =
            'Profile updated (Firestore channel unavailable on this run).';
      }
      if (hasPendingAvatar) {
        successMessage = 'Profile updated. Uploading photo in background...';
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      if (hasPendingAvatar) {
        unawaited(
          _uploadAvatarInBackground(user: user, avatarFile: pendingAvatarFile),
        );
      }
    } on MissingPluginException {
      _firestoreAvailable = false;
      try {
        if (user.displayName != name) {
          await user.updateDisplayName(name);
        }
      } catch (_) {}
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile saved without Firestore (channel unavailable).',
          ),
        ),
      );
    } on FirebaseException catch (e) {
      final String rawMessage = (e.message ?? '').toLowerCase();
      final bool isChannelUnavailable =
          rawMessage.contains('unable to establish connection on channel') ||
          rawMessage.contains('channel-error');
      if (isChannelUnavailable) {
        _firestoreAvailable = false;
        try {
          if (user.displayName != name) {
            await user.updateDisplayName(name);
          }
        } catch (_) {}
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile saved without Firestore (channel unavailable).',
            ),
          ),
        );
        return;
      }
      if (!mounted) {
        return;
      }
      final String message;
      if (e.code == 'permission-denied') {
        message = 'Firestore permission denied. Update Firestore rules.';
      } else if (e.code == 'unavailable') {
        message = 'No internet connection. Please try again.';
      } else {
        message = e.message ?? 'Failed to update profile.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e, st) {
      debugPrint('Save profile unexpected error: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 14),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
                    color: const Color(0xFF1F2224),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Personal Details',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1,
                      color: Color(0xFF1F2224),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD4C8BE),
                      ),
                      child: _avatarFile == null
                          ? (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _avatarUrl!,
                                      fit: BoxFit.cover,
                                      width: 74,
                                      height: 74,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
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
                                  ))
                          : ClipOval(
                              child: Image.file(
                                _avatarFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(4),
                          // decoration: BoxDecoration(
                          //   color: const Color(0xFF284968),
                          //   borderRadius: BorderRadius.circular(16),
                          //   border: Border.all(
                          //     color: const Color(0xFFFFFFFF),
                          //     width: 2.3,
                          //   ),
                          // ),
                          child: Image.asset(Images.edit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Full name'),
              const SizedBox(height: 6),
              _FieldInput(controller: _nameController),
              const SizedBox(height: 12),
              const _FieldLabel('Email address'),
              const SizedBox(height: 6),
              _FieldInput(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
              const SizedBox(height: 12),
              const _FieldLabel('Phone Number'),
              const SizedBox(height: 6),
              _FieldInput(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _FieldInput(
                controller: _bioController,
                height: 112,
                topAlign: true,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284968),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            height: 1.2,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 16,
        height: 1.2,
        color: Color(0xFF2C313A),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _FieldInput extends StatelessWidget {
  const _FieldInput({
    required this.controller,
    this.height = 40,
    this.topAlign = false,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final double height;
  final bool topAlign;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textAlignVertical: topAlign
            ? TextAlignVertical.top
            : TextAlignVertical.center,
        style: GoogleFonts.outfit(
          fontSize: 16,
          height: 1.2,
          color: Color(0xFF1F2224),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEBEBEB),
          contentPadding: EdgeInsets.fromLTRB(12, topAlign ? 10 : 0, 12, 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
