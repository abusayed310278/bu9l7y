import 'package:bu9l7y/core/constants/assets.dart';
import 'package:bu9l7y/feature/credits/views/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchaseCreditsScreen extends StatelessWidget {
  const PurchaseCreditsScreen({super.key});

  void _showPurchaseSheet(BuildContext context, String credits, String price) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _PurchaseSheet(credits: credits, price: price);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Purchase Credits',
                    style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: const Color(0xFF000000), fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 104,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF284968), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Balance',
                      style: GoogleFonts.outfit(fontSize: 16, height: 1.2, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '50 credits',
                      style: GoogleFonts.outfit(fontSize: 32, height: 1.2, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _CreditPackCard(
                creditsLabel: '20 credits',
                price: '\$14.00',
                usdLabel: 'USD',
                features: ['20 credits', 'Never expires', 'All quiz topics included'],
                selected: false,
                onPurchase: () => _showPurchaseSheet(context, '20 credits', '\$14.00'),
              ),
              const SizedBox(height: 12),
              _CreditPackCard(
                creditsLabel: '100 credits',
                price: '\$33.00',
                usdLabel: 'USD',
                bonusLabel: '+20 bonus credits',
                features: ['120 credits', 'Never expires', 'All quiz topics included'],
                selected: true,
                onPurchase: () => _showPurchaseSheet(context, '100 credits', '\$33.00'),
              ),
              const SizedBox(height: 12),
              _CreditPackCard(
                creditsLabel: '250 credits',
                price: '\$60.00',
                usdLabel: 'USD',
                bonusLabel: '+50 bonus credits',
                features: ['300 credits', 'Never expires', 'All quiz topics included'],
                selected: true,
                onPurchase: () => _showPurchaseSheet(context, '250 credits', '\$60.00'),
              ),
              const SizedBox(height: 12),
              _CreditPackCard(
                creditsLabel: '500 credits',
                price: '\$99.00',
                usdLabel: 'USD',
                bonusLabel: '+150 bonus credits',
                features: ['650 credits', 'Never expires', 'All quiz topics included'],
                selected: true,
                onPurchase: () => _showPurchaseSheet(context, '500 credits', '\$99.00'),
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
                      style: GoogleFonts.outfit(fontSize: 24, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
                    ),
                    if (bonusLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        bonusLabel!,
                        style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
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
                    style: GoogleFonts.outfit(fontSize: 20, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w500),
                  ),
                  Text(
                    usdLabel,
                    style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w500),
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
                  const Icon(Icons.check_rounded, size: 14, color: Color(0xFF3C3C43)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
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
                backgroundColor: selected ? const Color(0xFF284968) : const Color(0xFFF3F4F6),
                foregroundColor: selected ? Colors.white : const Color(0xFF3C3C43),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Text('Purchase', style: GoogleFonts.outfit(fontSize: 16, height: 1.2, fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseSheet extends StatelessWidget {
  const _PurchaseSheet({required this.credits, required this.price});

  final String credits;
  final String price;

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
              decoration: BoxDecoration(color: const Color(0xFFE6E6E6), borderRadius: BorderRadius.circular(2)),
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
                              price,
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
                          credits,
                          style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
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
                                    style: GoogleFonts.outfit(fontSize: 14, height: 1.2, color: const Color(0xFF1F2224), fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'bu.ahmed.user@icloud.com',
                                    style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFE6E6E6),
                              child: const Icon(Icons.person, size: 18, color: Color(0xFF3C3C43)),
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
                          style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: const Color(0xFF1F2224), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Apple Pay (Apple Card ...1234)',
                          style: GoogleFonts.outfit(fontSize: 12, height: 1.2, color: const Color(0xFF3C3C43), fontWeight: FontWeight.w400),
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
                      builder: (_) => const PaymentMethodScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284968),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text('Purchase', style: GoogleFonts.outfit(fontSize: 16, height: 1.2, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
