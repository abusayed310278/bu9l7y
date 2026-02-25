import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/core/common/widgets/custom_snackbar.dart';
import 'package:bu9l7y/feature/auth/views/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _accepted = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_isLoading) {
      return;
    }
    if (!_accepted) {
      CustomSnackbar.show('Please accept the terms to continue.');
      return;
    }
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirm = _confirmController.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      CustomSnackbar.show('Please fill all required fields.');
      return;
    }
    if (password != confirm) {
      CustomSnackbar.show('Passwords do not match.');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'uid': user.uid,
          'fullName': name,
          'email': email,
          'phone': user.phoneNumber ?? '',
          'role': 'user',
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await userCredential.user?.updateDisplayName(name);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      CustomSnackbar.show(e.message ?? 'Sign up failed.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                  color: const Color(0xFF294968),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(Images.appLogo, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 277,
                height: 30,
                child: Text(
                  'Join Us Today',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    height: 1,
                    letterSpacing: 0,
                    color: const Color(0xFF284968),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 277,
                height: 28,
                child: Text(
                  'Start your journey with respectful collaboration.\nDiscover talent or showcase your creativity.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    height: 1,
                    letterSpacing: 0,
                    color: const Color(0xFF6C6C6C),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _RoundedField(
                hint: 'Your Name',
                icon: Icons.person_outline_rounded,
                controller: _nameController,
              ),
              const SizedBox(height: 14),
              _RoundedField(
                hint: 'Email',
                icon: Icons.mail_outline_rounded,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _RoundedField(
                hint: 'New password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureNewPassword,
                controller: _passwordController,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  splashRadius: 18,
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _RoundedField(
                hint: 'Confirm password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                controller: _confirmController,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  splashRadius: 18,
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _accepted,
                      onChanged: (value) {
                        setState(() {
                          _accepted = value ?? false;
                        });
                      },
                      side: const BorderSide(
                        color: Color(0xFF8A8A8A),
                        width: 1,
                      ),
                      activeColor: const Color(0xFF284968),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 315,
                    height: 45,
                    child: Text(
                      'By using this app, you agree to follow all guidelines, use the content responsibly, and accept any future updates to our policies.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        height: 1,
                        letterSpacing: 0,
                        color: const Color(0xFF838383),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284968),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: _isLoading
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
                          'Sign up',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            height: 1.2,
                            letterSpacing: 0,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: SizedBox(
                  width: 343,
                  height: 17,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          height: 1.2,
                          letterSpacing: 0,
                          color: Color(0xFF1F1F1F),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SignInScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Log in',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            height: 1.2,
                            letterSpacing: 0,
                            color: Color(0xFF00A2FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

class _RoundedField extends StatelessWidget {
  const _RoundedField({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
  });

  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(
            fontSize: 12,
            height: 1.2,
            letterSpacing: 0,
            color: Color(0xFF6C6C6C),
            fontWeight: FontWeight.w400,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(icon, size: 14.67, color: const Color(0xFF6C6C6C)),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: suffixIcon,
                ),
          contentPadding: const EdgeInsets.only(top: 12, right: 16, bottom: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFCECECE), width: 1),
            borderRadius: BorderRadius.circular(100),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF284968), width: 1),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
