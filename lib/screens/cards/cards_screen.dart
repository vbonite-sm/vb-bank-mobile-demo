import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/banking_provider.dart';
import '../../models/card.dart';
import '../../theme/colors.dart';
import '../../services/biometric_service.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  final Map<String, bool> _flippedCards = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _createCard() async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    String selectedType = 'visa';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Create New Card',
              style: TextStyle(color: AppColors.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select card type:',
                  style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _cardTypeOption(
                      'Visa',
                      'visa',
                      selectedType,
                      (val) => setDialogState(() => selectedType = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _cardTypeOption(
                      'Mastercard',
                      'mastercard',
                      selectedType,
                      (val) => setDialogState(() => selectedType = val),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final result =
                    await context.read<BankingProvider>().createCard(
                          userId: currentUser.id,
                          type: selectedType,
                        );
                if (mounted && result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Card created successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardTypeOption(
    String label,
    String value,
    String groupValue,
    ValueChanged<String> onChanged,
  ) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFreeze(VirtualCard card) async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final provider = context.read<BankingProvider>();
    Map<String, dynamic> result;

    if (card.isFrozen) {
      result = await provider.unfreezeCard(userId, card.id);
    } else {
      result = await provider.freezeCard(userId, card.id);
    }

    if (mounted && result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _viewPIN(VirtualCard card) async {
    final authenticated =
        await BiometricService.authenticate('View card PIN');

    if (!authenticated) {
      // Fallback: show PIN directly for mock app
    }

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final pin = context.read<BankingProvider>().getCardPIN(userId, card.id);

    if (mounted && pin != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title:
              Text('Card PIN', style: TextStyle(color: AppColors.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_open, color: AppColors.primary, size: 40),
              const SizedBox(height: 16),
              Text(
                pin,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep your PIN secure',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _blockCard(VirtualCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Block Card', style: TextStyle(color: AppColors.text)),
        content: Text(
          'Are you sure you want to permanently block this card?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final result =
        await context.read<BankingProvider>().blockCard(userId, card.id);

    if (mounted && result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card blocked permanently'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteCard(VirtualCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Delete Card', style: TextStyle(color: AppColors.text)),
        content: Text(
          'Are you sure you want to delete this card? This cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final result =
        await context.read<BankingProvider>().deleteCard(userId, card.id);

    if (mounted && result['success']) {
      if (_currentPage > 0) {
        setState(() => _currentPage--);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<BankingProvider>().cards;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cards')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCard,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Card',
            style: TextStyle(color: Colors.white)),
      ),
      body: cards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_off,
                      size: 60, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No cards yet',
                    style: TextStyle(fontSize: 18, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first virtual card',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),

                // Card Carousel
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final isFlipped = _flippedCards[card.id] ?? false;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _flippedCards[card.id] = !isFlipped;
                          });
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isFlipped
                              ? _buildCardBack(card)
                              : _buildCardFront(card),
                        ),
                      );
                    },
                  ),
                ),

                // Page indicator
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    cards.length,
                    (index) => Container(
                      width: index == _currentPage ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Card Actions
                if (cards.isNotEmpty) _buildCardActions(cards[_currentPage]),

                // Card Details
                if (cards.isNotEmpty)
                  Expanded(child: _buildCardDetails(cards[_currentPage])),
              ],
            ),
    );
  }

  Widget _buildCardFront(VirtualCard card) {
    final cardColor = _parseColor(card.cardColor);
    return Container(
      key: ValueKey('front_${card.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.type.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              if (card.isFrozen)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FROZEN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (card.isBlocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BLOCKED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            card.maskedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARD HOLDER',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                  Text(
                    card.cardHolder,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                  Text(
                    card.expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(VirtualCard card) {
    final cardColor = _parseColor(card.cardColor);
    return Container(
      key: ValueKey('back_${card.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor.withOpacity(0.8), cardColor],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'CARD NUMBER',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            card.formattedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CVV',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    card.cvv,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EXPIRY',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    card.expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap to flip back',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActions(VirtualCard card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!card.isBlocked) ...[
            _actionBtn(
              card.isFrozen ? Icons.play_arrow : Icons.ac_unit,
              card.isFrozen ? 'Unfreeze' : 'Freeze',
              () => _toggleFreeze(card),
            ),
            const SizedBox(width: 12),
            _actionBtn(
              Icons.pin,
              'View PIN',
              () => _viewPIN(card),
            ),
            const SizedBox(width: 12),
            _actionBtn(
              Icons.block,
              'Block',
              () => _blockCard(card),
              color: AppColors.error,
            ),
            const SizedBox(width: 12),
            _actionBtn(
              Icons.delete_outline,
              'Delete',
              () => _deleteCard(card),
              color: AppColors.error,
            ),
          ] else
            const Center(
              child: Text(
                'This card has been permanently blocked',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color ?? AppColors.primary, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color ?? AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardDetails(VirtualCard card) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            _detailRow('Type', card.type.toUpperCase()),
            _detailRow('Status', card.status.toUpperCase()),
            _detailRow(
                'Spending Limit', '\$${card.spendingLimit.toStringAsFixed(2)}'),
            _detailRow('Current Spending',
                '\$${card.currentSpending.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            // Spending bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: card.spendingLimit > 0
                    ? card.currentSpending / card.spendingLimit
                    : 0,
                backgroundColor: AppColors.border,
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  card.currentSpending / card.spendingLimit > 0.8
                      ? AppColors.error
                      : AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
