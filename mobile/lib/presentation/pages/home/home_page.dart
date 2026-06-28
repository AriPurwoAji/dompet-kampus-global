import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../blocs/account/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/transaction_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hideBalance = false;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(AccountLoadRequested());
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi,';
    if (h < 15) return 'Selamat siang,';
    if (h < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final fullName = user?.name ?? 'User';
        final firstName = user?.firstName ?? 'Kamu';

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) {
              final balance =
                  accountState is AccountLoaded ? accountState.account.balance : 0.0;
              final txns = accountState is AccountLoaded
                  ? accountState.transactions
                  : <TransactionEntity>[];
              final loading = accountState is AccountLoading;

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<AccountBloc>().add(AccountRefreshRequested()),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // ── Navy top section ──────────────────────────────
                      Container(
                        color: AppColors.navy,
                        padding: EdgeInsets.fromLTRB(
                            20, MediaQuery.of(context).padding.top + 12, 20, 24),
                        child: Column(
                          children: [
                            // Greeting row
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.navyMid,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      fullName.isNotEmpty
                                          ? fullName[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_greeting(),
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            color: Colors.white60,
                                            fontSize: 11,
                                          )),
                                      Text(firstName,
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ],
                                  ),
                                ),
                                // Bell
                                Stack(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.navyMid,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.notifications_outlined,
                                          size: 20, color: Colors.white),
                                    ),
                                    Positioned(
                                      top: 7,
                                      right: 7,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.navy, width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Balance card (dark navy inside navy)
                            _buildBalanceCard(balance, loading),
                          ],
                        ),
                      ),

                      // ── White content area ────────────────────────────
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsRow(),
                            const SizedBox(height: 16),
                            const Text('LAYANAN',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate400,
                                  letterSpacing: 0.6,
                                )),
                            const SizedBox(height: 4),
                            _buildFeatureGrid(),
                            const SizedBox(height: 4),
                            _buildDeeplinkBanner(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // ── Transactions ──────────────────────────────────
                      Container(
                        color: AppColors.bg,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: _buildTransactions(txns),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(double balance, bool loading) {
    final actions = [
      {
        'icon': Icons.north_rounded,
        'label': 'Top Up',
        'color': const Color(0xFF60A5FA),
        'route': '/topup',
      },
      {
        'icon': Icons.east_rounded,
        'label': 'Transfer',
        'color': const Color(0xFF34D399),
        'route': '/transfer',
      },
      {
        'icon': Icons.qr_code_rounded,
        'label': 'Bayar',
        'color': const Color(0xFFC4B5FD),
        'route': '/payment',
      },
      {
        'icon': Icons.south_rounded,
        'label': 'Tarik',
        'color': const Color(0xFFFCA5A5),
        'route': '/topup',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyMid,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        children: [
          // Brand row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: AppLogo(size: 18),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Saldo DKG',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  )),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/topup'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.7), width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('+ Isi Saldo',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: AppColors.primaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Balance row
          Row(
            children: [
              loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      _hideBalance
                          ? CurrencyFormatter.maskBalance()
                          : CurrencyFormatter.format(balance),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _hideBalance = !_hideBalance),
                child: Icon(
                  _hideBalance
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 14),
          // Quick actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions.map((a) {
              return GestureDetector(
                onTap: () => context.go(a['route'] as String),
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(a['icon'] as IconData,
                          size: 22, color: a['color'] as Color),
                    ),
                    const SizedBox(height: 6),
                    Text(a['label'] as String,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        )),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.star_outline_rounded,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Poin Kampus',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate400)),
                    Text('1.250',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.greenSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.credit_card_outlined,
                      size: 18, color: AppColors.green),
                ),
                const SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('KTM Digital',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate400)),
                    Text('Aktif',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.smartphone_outlined, 'label': 'Pulsa', 'bg': AppColors.blueSurface, 'fg': AppColors.blue},
      {'icon': Icons.bolt_outlined, 'label': 'PLN', 'bg': AppColors.amberSurface, 'fg': AppColors.amber},
      {'icon': Icons.restaurant_outlined, 'label': 'Kantin', 'bg': AppColors.redSurface, 'fg': AppColors.red},
      {'icon': Icons.receipt_long_outlined, 'label': 'UKT', 'bg': AppColors.violetSurface, 'fg': AppColors.violet},
      {'icon': Icons.wifi_rounded, 'label': 'Paket Data', 'bg': AppColors.greenSurface, 'fg': AppColors.green},
      {'icon': Icons.card_giftcard_rounded, 'label': 'Voucher', 'bg': AppColors.primarySurface, 'fg': AppColors.primary},
      {'icon': Icons.favorite_outline_rounded, 'label': 'Donasi', 'bg': AppColors.pinkSurface, 'fg': AppColors.pink},
      {'icon': Icons.more_horiz_rounded, 'label': 'Lainnya', 'bg': AppColors.line2, 'fg': AppColors.slate500},
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
      childAspectRatio: 0.95,
      children: features.map((f) {
        return GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: f['bg'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(f['icon'] as IconData,
                    size: 26, color: f['fg'] as Color),
              ),
              const SizedBox(height: 6),
              Text(f['label'] as String,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate600,
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeeplinkBanner() {
    return GestureDetector(
      onTap: () => context.go('/merchant'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Coba bayar dari toko online',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  SizedBox(height: 2),
                  Text('Nikmati kemudahan transaksi digital',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        color: Colors.white54,
                      )),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.credit_card_outlined,
                  size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions(List<TransactionEntity> txns) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Transaksi terakhir',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
            GestureDetector(
              onTap: () => context.go('/history'),
              child: const Text('Lihat semua',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.shadowSoft,
          ),
          child: txns.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('Belum ada transaksi',
                        style: TextStyle(
                            color: AppColors.slate400,
                            fontFamily: 'PlusJakartaSans')),
                  ),
                )
              : Column(
                  children: txns
                      .take(4)
                      .toList()
                      .asMap()
                      .entries
                      .map((e) => TransactionRow(txn: e.value, divider: e.key > 0))
                      .toList(),
                ),
        ),
      ],
    );
  }
}
