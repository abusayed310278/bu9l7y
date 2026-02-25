import 'package:bu9l7y/app_ground.dart';
import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/core/network/api_service/token_meneger.dart';
import 'package:bu9l7y/feature/auth/views/forgot_password_screen.dart';
import 'package:bu9l7y/feature/auth/views/sign_up_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedCredentials() async {
    final bool rememberMeEnabled = await TokenManager.isRememberMeEnabled();
    if (!rememberMeEnabled) {
      return;
    }

    final String? rememberedEmail = await TokenManager.getRememberedEmail();
    final String? rememberedPassword =
        await TokenManager.getRememberedPassword();

    if (!mounted) {
      return;
    }

    setState(() {
      _rememberMe = true;
      _emailController.text = rememberedEmail ?? '';
      _passwordController.text = rememberedPassword ?? '';
    });
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) {
      return;
    }
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        final DocumentReference<Map<String, dynamic>> userDoc = FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid);
        final String photoUrl = (user.photoURL ?? '').trim();
        final Map<String, dynamic> payload = <String, dynamic>{
          'userId': user.uid,
          'uid': user.uid,
          'email': (user.email ?? email).trim(),
          'role': 'user',
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        };
        if (photoUrl.isNotEmpty) {
          payload['image'] = photoUrl;
          payload['avatarUrl'] = photoUrl;
        } else {
          final DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc
              .get();
          final Map<String, dynamic>? data = snapshot.data();
          if (data?['image'] == '') {
            payload['image'] = FieldValue.delete();
          }
          if (data?['avatarUrl'] == '') {
            payload['avatarUrl'] = FieldValue.delete();
          }
        }
        await userDoc.set(payload, SetOptions(merge: true));
      }

      if (_rememberMe) {
        await TokenManager.setRememberMe(true);
        await TokenManager.saveRememberedCredentials(
          email: email,
          password: password,
        );
      } else {
        await TokenManager.setRememberMe(false);
        await TokenManager.clearRememberedCredentials();
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const AppGround(initialIndex: 0),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign in failed.')));
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
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(Images.appLogo, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 253,
                height: 30,
                child: Text(
                  'Welcome Back',
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
                width: 253,
                height: 28,
                child: Text(
                  'Respectful collaboration starts here. Sign in to \nconnect with creatives or clients worldwide.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    height: 1.2,
                    letterSpacing: 0,
                    color: const Color(0xFF6C6C6C),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _SignInField(
                hint: 'Email or Phone Number',
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _SignInField(
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                controller: _passwordController,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
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
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
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
                  const SizedBox(width: 8),
                  Text(
                    'Remember me',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      height: 1.2,
                      color: Color(0xFF7D7D7D),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 143,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF838383),
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          'Forgot your password?',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            height: 1,
                            letterSpacing: 0,
                            color: Color(0xFF838383),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSignIn,
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
                          'Login',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            height: 1.2,
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
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Don’t have an account?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            height: 1.2,
                            letterSpacing: 0,
                            color: Color(0xFF1F1F1F),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          ' ',
                          textAlign: TextAlign.center,
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
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign up',
                            textAlign: TextAlign.center,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInField extends StatelessWidget {
  const _SignInField({
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
            child: Icon(icon, size: 16, color: const Color(0xFF7D7D7D)),
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
