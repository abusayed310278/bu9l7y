import 'package:bu9l7y/core/constants/assets.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
              const SizedBox(
                width: 277,
                height: 30,
                child: Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 24,
                    height: 1,
                    letterSpacing: 0,
                    color: Color(0xFF284968),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
                width: 277,
                height: 28,
                child: Text(
                  'Select which contact details should we use to reset your\npassword',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    height: 1.2,
                    letterSpacing: 0,
                    color: Color(0xFF6C6C6C),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const _RoundedPasswordField(hint: 'New password'),
              const SizedBox(height: 14),
              const _RoundedPasswordField(hint: 'Confirm password'),
              const SizedBox(height: 34),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284968),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
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

class _RoundedPasswordField extends StatelessWidget {
  const _RoundedPasswordField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Outfit',
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
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: SizedBox(
              width: 14,
              height: 14,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(
                  Icons.lock_outline_rounded,
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
