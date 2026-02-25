import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/credits/views/purchase_credits_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  int _readCredits(Map<String, dynamic>? data) {
    final dynamic value = data?['credits'] ?? data?['creditBalance'];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.chevron_left_rounded, size: 24),
                  color: const Color(0xFF1F2224),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Credits',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    height: 1.2,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseAuth.instance.currentUser == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
              builder: (context, snapshot) {
                final int credits = _readCredits(snapshot.data?.data());
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'CREDIT BALANCE',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              height: 22 / 14,
                              color: const Color(0xFF3C3C43),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF284968),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            credits.toString(),
                            style: GoogleFonts.outfit(
                              fontSize: 40,
                              height: 1.2,
                              color: const Color(0xFF3C3C43),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'CR',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                height: 22 / 20,
                                color: const Color(0xFF3C3C43),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_rounded,
                            color: Color(0xFFFF1E1E),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            credits <= 50
                                ? 'Low Credit Balance'
                                : 'Credits available',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              height: 22 / 12,
                              color: const Color(0xFF3C3C43),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PurchaseCreditsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284968),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.cart,
                      width: 27.67,
                      height: 24.03,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Get More Credits',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Purchase History',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1.2,
                      color: Color(0xFF1F2224),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'View All',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    height: 1,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: 7,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) =>
                    const _HistoryTile(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Image.asset(Images.cardOfPayment, width: 24, height: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '50 credits',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    height: 1.2,
                    color: Color(0xFF1F2224),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '2 days ago',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    height: 1.2,
                    color: Color(0xFF3C3C43),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$5.00 USD',
            style: GoogleFonts.outfit(
              fontSize: 14,
              height: 1.2,
              color: Color(0xFF1F2224),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
