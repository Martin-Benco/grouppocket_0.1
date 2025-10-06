import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handlePayment(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E18EA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(225),
              ),
            ),
            child: const Text(
              'Zaplatiť',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _handleShare(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF5E18EA)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(225),
              ),
            ),
            child: const Text(
              'Zdieľať QuickSplit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  void _handlePayment(BuildContext context) {
    final appState = context.read<AppState>();
    final selectedParticipants = appState.participants.where((p) => p.selected).toList();
    
    if (selectedParticipants.isEmpty) {
      _showNotification(context, 'Vyberte aspoň jedného účastníka', 'error');
      return;
    }
    
    if (appState.amount <= 0) {
      _showNotification(context, 'Zadajte sumu väčšiu ako 0', 'error');
      return;
    }
    
    _showPaymentModal(context, selectedParticipants);
  }
  
  void _handleShare(BuildContext context) {
    final appState = context.read<AppState>();
    final selectedParticipants = appState.participants.where((p) => p.selected).toList();
    
    if (selectedParticipants.isEmpty) {
      _showNotification(context, 'Vyberte aspoň jedného účastníka', 'error');
      return;
    }
    
    if (appState.amount <= 0) {
      _showNotification(context, 'Zadajte sumu väčšiu ako 0', 'error');
      return;
    }
    
    _showShareModal(context);
  }
  
  void _showPaymentModal(BuildContext context, List<Participant> participants) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Platba',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kliknite na tlačidlo pre platbu:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...participants.map((participant) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${participant.name}: ${participant.amount.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _openPayMeLink(participant.amount, participant.name),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E18EA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Zaplatiť PayMe'),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD9D9D9)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Zavrieť'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showShareModal(BuildContext context) {
    final shareLink = _generateShareLink();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Zdieľať QuickSplit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Zdieľajte tento link s účastníkmi:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      border: Border.all(color: const Color(0xFFD9D9D9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shareLink,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _copyToClipboard(context, shareLink),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E18EA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Kopírovať'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD9D9D9)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Zavrieť'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _openPayMeLink(double amount, String recipient) {
    // PayMe link formát
    final encodedAmount = Uri.encodeComponent(amount.toStringAsFixed(2));
    final encodedRecipient = Uri.encodeComponent(recipient);
    final paymeLink = 'https://payme.sk/pay?amount=$encodedAmount&recipient=$encodedRecipient';
    
    // TODO: Implementovať otvorenie linku
    print('PayMe link: $paymeLink');
  }
  
  String _generateShareLink() {
    // Vytvor unikátny ID pre zdieľanie
    final shareId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return 'https://grouppocket.app/share/$shareId';
  }
  
  void _copyToClipboard(BuildContext context, String text) {
    // TODO: Implementovať kopírovanie do schránky
    _showNotification(context, 'Link skopírovaný do schránky!', 'success');
  }
  
  void _showNotification(BuildContext context, String message, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: type == 'error' 
            ? const Color(0xFFEF4444)
            : type == 'success'
                ? const Color(0xFF10B981)
                : const Color(0xFF5E18EA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
