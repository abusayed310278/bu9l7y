import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/credits/views/purchase_credits_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  bool _viewAllEnabled = false;

  int _readCredits(Map<String, dynamic>? data) {
    final dynamic value = data?['credits'] ?? data?['creditBalance'];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  String _formatTimeAgo(DateTime value) {
    final Duration diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final int weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '$weeks weeks ago';
    final int months = (diff.inDays / 30).floor();
    if (months < 12) return '$months months ago';
    final int years = (diff.inDays / 365).floor();
    return '$years years ago';
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
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Credits',
                  style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: const Color(0xFF000000), fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseAuth.instance.currentUser == null
                  ? null
                  : FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                final int credits = _readCredits(snapshot.data?.data());
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))],
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
                          if (credits <= 50) ...[
                            const Icon(Icons.error_rounded, color: Color(0xFFFF1E1E), size: 16),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            credits <= 50 ? 'Low Credit Balance' : 'Credits available',
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
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PurchaseCreditsScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284968),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Images.cart, width: 27.67, height: 24.03, color: Colors.white),
                    const SizedBox(width: 10),
                    Text('Get More Credits', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500)),
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
                    style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Color(0xFF1F2224), fontWeight: FontWeight.w500),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_viewAllEnabled) return;
                    setState(() {
                      _viewAllEnabled = true;
                    });
                  },
                  child: Text(
                    _viewAllEnabled ? 'Showing all' : 'View All',
                    style: GoogleFonts.outfit(fontSize: 12, height: 1, color: const Color(0xFF000000), fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseAuth.instance.currentUser == null
                    ? null
                    : FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('creditPurchases')
                          .orderBy('createdAt', descending: true)
                          .limit(_viewAllEnabled ? 1000 : 5)
                          .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<_PurchaseHistoryItem> items =
                      snapshot.data?.docs.map(_PurchaseHistoryItem.fromDoc).toList() ?? <_PurchaseHistoryItem>[];
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No purchase history yet.',
                        style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: items.length,
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) => _HistoryTile(
                      title: '${items[index].creditsAdded} credits',
                      subtitle: _formatTimeAgo(items[index].createdAt),
                      price: items[index].formattedPrice,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.title, required this.subtitle, required this.price});

  final String title;
  final String subtitle;
  final String price;

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
                  title,
                  style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: Color(0xFF1F2224), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: Color(0xFF3C3C43), fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: Color(0xFF1F2224), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PurchaseHistoryItem {
  const _PurchaseHistoryItem({required this.creditsAdded, required this.formattedPrice, required this.createdAt});

  final int creditsAdded;
  final String formattedPrice;
  final DateTime createdAt;

  static _PurchaseHistoryItem fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final dynamic creditsRaw = data['creditsAdded'];
    final int creditsAdded = creditsRaw is int
        ? creditsRaw
        : creditsRaw is double
        ? creditsRaw.round()
        : int.tryParse((creditsRaw ?? '0').toString().trim()) ?? 0;

    final String rawPrice = (data['price'] as String? ?? '').trim();
    final String formattedPrice = rawPrice.isEmpty
        ? '\$0.00 USD'
        : rawPrice.toUpperCase().contains('USD')
        ? rawPrice
        : '$rawPrice USD';

    final dynamic createdAtRaw = data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    }

    return _PurchaseHistoryItem(creditsAdded: creditsAdded, formattedPrice: formattedPrice, createdAt: createdAt);
  }
}
