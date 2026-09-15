import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';
import 'ticket_screen.dart';

class DigitalPaymentScreen extends StatefulWidget {
  const DigitalPaymentScreen({
    super.key,
    required this.product,
    required this.address,
    required this.pickupMethod,
  });

  final Product product;
  final String address;
  final String pickupMethod;

  @override
  State<DigitalPaymentScreen> createState() => _DigitalPaymentScreenState();
}

class _DigitalPaymentScreenState extends State<DigitalPaymentScreen> {
  String _method = 'QRIS';
  bool _isProcessing = false;

  int get _deliveryFee => widget.pickupMethod == 'courier' ? 8000 : 0;
  int get _total => widget.product.discountPrice + _deliveryFee;

  String _currency(int value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);

  Future<void> _simulatePayment() async {
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    context.read<CartProvider>().addToCart(widget.product);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TicketScreen(
          product: widget.product,
          address: widget.address,
          paymentMethod: _method,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildBillCard(),
            const SizedBox(height: 16),
            _buildMethodSelector(),
            const SizedBox(height: 16),
            _buildQrCard(),
            const SizedBox(height: 16),
            _buildSimulationCard(),
            const SizedBox(height: 16),
            SizedBox(
              height: 58,
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : _simulatePayment,
                icon: _isProcessing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_isProcessing
                    ? 'Memproses pembayaran...'
                    : 'SAYA SUDAH MEMBAYAR  ${_currency(_total)}'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _BottomItem(icon: Icons.explore_outlined, label: 'Jelajah'),
              _BottomItem(icon: Icons.receipt_long_outlined, label: 'Detail'),
              _BottomItem(icon: Icons.psychology_outlined, label: 'AI Nutrisi'),
              _BottomItem(icon: Icons.local_shipping_outlined, label: 'Kurir'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Row(children: [
        IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded)),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RESCUE OS',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w800)),
            Text('Pembayaran Digital',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
              color: const Color(0xFFF0F3F0),
              borderRadius: BorderRadius.circular(18)),
          child: const Row(children: [
            Icon(Icons.schedule_outlined, color: AppColors.secondary, size: 16),
            SizedBox(width: 5),
            Text('09:56',
                style: TextStyle(
                    color: AppColors.secondary, fontWeight: FontWeight.w800)),
          ]),
        ),
      ]);

  Widget _buildBillCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: Color(0x12000000), blurRadius: 8)
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TOTAL TAGIHAN IN-APP',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('Rp ', style: TextStyle(fontSize: 14)),
            Text(_currency(_total).replaceFirst('Rp ', ''),
                style: const TextStyle(fontSize: 43, fontWeight: FontWeight.w900)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                  color: const Color(0xFFE1F1E6),
                  borderRadius: BorderRadius.circular(24)),
              child: const Row(children: [
                Icon(Icons.electric_bolt_rounded,
                    color: AppColors.primary, size: 16),
                SizedBox(width: 5),
                Text('ECO-FLEET\nDISPATCH',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F5),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(widget.product.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(_currency(widget.product.discountPrice), style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.eco_outlined, color: AppColors.primary, size: 16),
                  const SizedBox(width: 5),
                  Expanded(child: Text(widget.pickupMethod == 'courier' ? 'Kurir Khusus (Eco-Fleet Tersulasi)' : 'Self Pick-up (Ambil Sendiri)')),
                  Text(_currency(_deliveryFee), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                ]),
              ])),
        ]);

  Widget _buildMethodSelector() => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: const Color(0xFFF0F3F0),
            borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          _PaymentMethod(
              icon: Icons.qr_code_2_rounded,
              label: 'QRIS\nInstant',
              selected: _method == 'QRIS',
              onTap: () => setState(() => _method = 'QRIS')),
          _PaymentMethod(
              icon: Icons.account_balance_outlined,
              label: 'VA Bank',
              selected: _method == 'VA Bank',
              onTap: () => setState(() => _method = 'VA Bank')),
          _PaymentMethod(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Saldo\n(450k)',
              selected: _method == 'Saldo',
              onTap: () => setState(() => _method = 'Saldo')),
        ]));

  Widget _buildQrCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 8)]),
        child: Column(children: [
          Row(children: [
            const _BlackTag(label: 'QRIS'),
            const SizedBox(width: 16),
            const Expanded(child: Text('Standar Pembayaran\nNasional', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
            const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 18),
            const SizedBox(width: 5),
            const Text('ASPI / BI\nVERIFIED', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFF0F3F0), borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: QrImageView(data: 'FOODRESCUE-${widget.product.id}-${_total}', version: QrVersions.auto, size: 210),
              ),
              const SizedBox(height: 12),
              const Text('Scan via BCA, GoPay, OVO, Dana,\nShopeePay', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Expanded(child: _ActionButton(icon: Icons.download_rounded, label: 'Unduh QR')),
            const SizedBox(width: 10),
            const Expanded(child: _ActionButton(icon: Icons.copy_outlined, label: 'Salin String')),
          ]),
          const SizedBox(height: 14),
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF0F3F0), borderRadius: BorderRadius.circular(14)),
              child: const Row(children: [
                Icon(Icons.shield_outlined, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('GUARANTEED ESCROW PROTECTION\nDana ditahan aman di escrow Rescue OS sampai serah terima kurir terverifikasi via QR Handover.', style: TextStyle(color: AppColors.mutedText, fontSize: 10, height: 1.35))),
              ])),
        ]);

  Widget _buildSimulationCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFFFFE6D9), borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.circle, color: AppColors.secondary, size: 12),
            SizedBox(width: 8),
            Expanded(child: Text('SIMULASI REAL-TIME PAYMENT HUB', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11))),
            Text('DEV/TEST', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800, fontSize: 9)),
          ]),
          const SizedBox(height: 12),
          const Text('Tekan tombol simulasi di bawah untuk menguji verifikasi pembayaran otomatis dan transisi penugasan kurir.', style: TextStyle(color: Color(0xFF934A2D), fontSize: 11, height: 1.4)),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isProcessing ? null : _simulatePayment, icon: const Icon(Icons.bolt_rounded), label: const Text('Simulasi Pembayaran Berhasil (Sukses)'), style: FilledButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(vertical: 14)))),
        ]);
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(14)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: selected ? Colors.white : AppColors.text, size: 18), const SizedBox(width: 6), Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : AppColors.text, fontSize: 10, fontWeight: FontWeight.w800))])));
}

class _BlackTag extends StatelessWidget {
  const _BlackTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)));
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(onPressed: () {}, icon: Icon(icon, size: 17), label: Text(label, style: const TextStyle(fontSize: 10)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide.none, backgroundColor: const Color(0xFFF0F3F0)));
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: AppColors.text, size: 18), Text(label, style: const TextStyle(fontSize: 9))]);
}
