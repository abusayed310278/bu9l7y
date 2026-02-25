import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/credits/views/payment_method_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchaseCreditsScreen extends StatelessWidget {
  const PurchaseCreditsScreen({super.key});

  void _showPurchaseSheet(BuildContext context, _CreditPackage package) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? '';
    final String uid = user?.uid ?? '';
    final String initialImageUrl = (user?.photoURL ?? '').trim();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _PurchaseSheet(
          package: package,
          accountEmail: email,
          accountUid: uid,
          initialImageUrl: initialImageUrl,
        );
      },
    );
  }

  String _formatPrice(double price) => '\$${price.toStringAsFixed(2)}';

  int _readCredits(Map<String, dynamic>? data) {
    final dynamic raw = data?['credits'] ?? data?['creditBalance'];
    if (raw is int) return raw;
    if (raw is double) return raw.round();
    if (raw is String) return int.tryParse(raw.trim()) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
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
                  const SizedBox(width: 8),
                  Text(
                    'Purchase Credits',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1.2,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
                    height: 104,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF284968),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            height: 1.2,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$credits credits',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            height: 1.2,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('packages')
                      .orderBy('baseCredits')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final List<_CreditPackage> packages = snapshot.data?.docs
                            .map(_CreditPackage.fromDoc)
                            .toList() ??
                        <_CreditPackage>[];
                    if (packages.isEmpty) {
                      return const Center(child: Text('No credit packages found.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: packages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final _CreditPackage package = packages[index];
                        final int total = package.baseCredits + package.bonusCredits;
                        return _CreditPackCard(
                          creditsLabel: '${package.baseCredits} credits',
                          price: _formatPrice(package.price),
                          usdLabel: 'USD',
                          bonusLabel: package.bonusCredits > 0
                              ? '+${package.bonusCredits} bonus credits'
                              : null,
                          features: [
                            '$total credits',
                            package.billingCycle,
                            package.packageInclude,
                          ],
                          selected: true,
                          onPurchase: () => _showPurchaseSheet(context, package),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditPackCard extends StatelessWidget {
  const _CreditPackCard({
    required this.creditsLabel,
    required this.price,
    required this.usdLabel,
    required this.features,
    required this.selected,
    this.bonusLabel,
    this.onPurchase,
  });

  final String creditsLabel;
  final String price;
  final String usdLabel;
  final String? bonusLabel;
  final List<String> features;
  final bool selected;
  final VoidCallback? onPurchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creditsLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        height: 1.2,
                        color: const Color(0xFF3C3C43),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (bonusLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        bonusLabel!,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          height: 1.2,
                          color: const Color(0xFF3C3C43),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      height: 1.2,
                      color: const Color(0xFF3C3C43),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    usdLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      height: 1.2,
                      color: const Color(0xFF3C3C43),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE6E6E6)),
          const SizedBox(height: 10),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Color(0xFF3C3C43),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        height: 1.2,
                        color: const Color(0xFF3C3C43),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: selected
                    ? const Color(0xFF284968)
                    : const Color(0xFFF3F4F6),
                foregroundColor: selected
                    ? Colors.white
                    : const Color(0xFF3C3C43),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Purchase',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseSheet extends StatelessWidget {
  const _PurchaseSheet({
    required this.package,
    required this.accountEmail,
    required this.accountUid,
    required this.initialImageUrl,
  });

  final _CreditPackage package;
  final String accountEmail;
  final String accountUid;
  final String initialImageUrl;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Image.asset(Images.applesPay, height: 26),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Purchase',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                height: 1.2,
                                color: const Color(0xFF1F2224),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$${package.price.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                height: 1.2,
                                color: const Color(0xFF1F2224),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${package.baseCredits + package.bonusCredits} credits',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            height: 1.2,
                            color: const Color(0xFF3C3C43),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // const Divider(height: 1, color: Color(0xFFE6E6E6)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      height: 1.2,
                                      color: const Color(0xFF1F2224),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    accountEmail.isNotEmpty
                                        ? accountEmail
                                        : 'No email',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      height: 1.2,
                                      color: const Color(0xFF3C3C43),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                              stream: accountUid.isEmpty
                                  ? null
                                  : FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(accountUid)
                                      .snapshots(),
                              builder: (context, snapshot) {
                                final Map<String, dynamic>? data = snapshot.data?.data();
                                final String imageUrl = _readImageUrl(data);
                                final String finalImageUrl = imageUrl.isNotEmpty
                                    ? imageUrl
                                    : initialImageUrl;
                                return CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFE6E6E6),
                                  backgroundImage: finalImageUrl.isNotEmpty
                                      ? NetworkImage(finalImageUrl)
                                      : null,
                                  child: finalImageUrl.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          size: 18,
                                          color: Color(0xFF3C3C43),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 0),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
              ),
              child: Row(
                children: [
                  Image.asset(Images.cardOfPayment, width: 24, height: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            height: 1.2,
                            color: const Color(0xFF1F2224),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Apple Pay (Apple Card ...1234)',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            height: 1.2,
                            color: const Color(0xFF3C3C43),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => PaymentMethodScreen(
                          purchasedCredits:
                              package.baseCredits + package.bonusCredits,
                          priceLabel: '\$${package.price.toStringAsFixed(2)}',
                        ),
                      ),
                    );
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284968),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  'Purchase',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _readImageUrl(Map<String, dynamic>? data) {
    final List<dynamic> candidates = <dynamic>[
      data?['avatarUrl'],
      data?['image'],
      data?['profileImage'],
      data?['photoUrl'],
    ];
    for (final dynamic value in candidates) {
      final String url = (value as String? ?? '').trim();
      if (url.isNotEmpty) {
        return url;
      }
    }
    return '';
  }
}

class _CreditPackage {
  _CreditPackage({
    required this.baseCredits,
    required this.bonusCredits,
    required this.billingCycle,
    required this.packageInclude,
    required this.price,
  });

  final int baseCredits;
  final int bonusCredits;
  final String billingCycle;
  final String packageInclude;
  final double price;

  static _CreditPackage fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    return _CreditPackage(
      baseCredits: _readInt(data['baseCredits']),
      bonusCredits: _readInt(data['bonusCredits']),
      billingCycle: _readString(data['billingCycle'], fallback: 'Never expires'),
      packageInclude: _readString(
        data['packageInclude'],
        fallback: 'All quiz topics included',
      ),
      price: _readDouble(data['price']),
    );
  }

  static int _readInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is double) return raw.round();
    if (raw is String) return int.tryParse(raw.trim()) ?? 0;
    return 0;
  }

  static double _readDouble(dynamic raw) {
    if (raw is int) return raw.toDouble();
    if (raw is double) return raw;
    if (raw is String) return double.tryParse(raw.trim()) ?? 0;
    return 0;
  }

  static String _readString(dynamic raw, {required String fallback}) {
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return fallback;
  }
}
