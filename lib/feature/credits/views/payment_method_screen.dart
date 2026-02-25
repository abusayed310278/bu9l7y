import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/credits/views/payment_result_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({
    super.key,
    required this.purchasedCredits,
    required this.priceLabel,
  });

  final int purchasedCredits;
  final String priceLabel;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool _isSubmitting = false;

  Future<void> _handlePurchase() async {
    if (_isSubmitting) return;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login again.')));
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    try {
      final DocumentReference<Map<String, dynamic>> userDoc = FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction
            .get(userDoc);
        final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
        final int currentCredits = _readInt(
          data['credits'] ?? data['creditBalance'],
        );
        final int nextCredits = currentCredits + widget.purchasedCredits;

        transaction.set(userDoc, {
          'credits': nextCredits,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final DocumentReference<Map<String, dynamic>> historyRef = userDoc
            .collection('creditPurchases')
            .doc();
        transaction.set(historyRef, {
          'creditsAdded': widget.purchasedCredits,
          'price': widget.priceLabel,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PaymentResultScreen(
            success: true,
            purchasedCredits: widget.purchasedCredits,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
                    color: const Color(0xFF1F2224),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Method',
                    style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: const Color(0xFF000000), fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDADADA), width: 2),
                ),
                child: Row(
                  children: [
                    Image.asset(Images.applePay, height: 26),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Apple Pay',
                          style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: const Color(0xFF1F2224), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pay with apple pay',
                          style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF284968),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      child: _isSubmitting
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
                              'Continue With Apple Pay',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                height: 1.2,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF3C3C43)),
                      const SizedBox(width: 6),
                      Text(
                        'Your payment is encrypted and secure',
                        style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
