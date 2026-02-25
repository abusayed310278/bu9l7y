import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/core/network/error/error_message.dart';
import 'package:bu9l7y/feature/auth/services/password_reset_api_service.dart';
import 'package:bu9l7y/feature/auth/views/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = (widget.initialEmail ?? '').trim();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^\S+@\S+\.\S+$').hasMatch(value);
  }

  Future<void> _handleSendOtp() async {
    if (_isLoading) {
      return;
    }

    final String email = _emailController.text.trim().toLowerCase();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final PasswordResetApiService passwordResetApiService =
          PasswordResetApiService();
      await passwordResetApiService.sendOtp(email: email);
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OtpScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorMessage.from(e, fallback: 'Failed to send OTP. Try again.'),
          ),
        ),
      );
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
                  icon: const Icon(Icons.chevron_left_rounded, size: 24),
                  color: const Color(0xFF294968),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
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
              const SizedBox(height: 24),
              SizedBox(
                width: 277,
                height: 30,
                child: Text(
                  'Reset Password',
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
                  'Enter your email and we will send a 6-digit OTP.',
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
              const SizedBox(height: 22),
              _RoundedEmailField(
                hint: 'Email address',
                controller: _emailController,
              ),
              const SizedBox(height: 34),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSendOtp,
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
                          'Send OTP',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedEmailField extends StatelessWidget {
  const _RoundedEmailField({required this.hint, required this.controller});

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(
            fontSize: 12,
            height: 1.2,
            letterSpacing: 0,
            color: const Color(0xFF6C6C6C),
            fontWeight: FontWeight.w400,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: SizedBox(
              width: 14,
              height: 14,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: 16,
                  color: Color(0xFF6C6C6C),
                ),
              ),
            ),
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
