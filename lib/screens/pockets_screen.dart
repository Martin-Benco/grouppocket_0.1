import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/pocket.dart';

class PocketsScreen extends StatelessWidget {
  const PocketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - v skutočnosti by sa načítavalo z Firebase
    final pockets = [
      Pocket(
        title: 'Nová chladnička',
        participants: 4,
        progress: 0.75,
        status: PocketStatus.owed,
        amount: 20.0,
        isRecurring: false,
      ),
      Pocket(
        title: 'Chata 2025',
        participants: 18,
        progress: 1.0,
        status: PocketStatus.paid,
        amount: 0.0,
        isRecurring: false,
      ),
      Pocket(
        title: 'Kancel',
        participants: 3,
        progress: 1.0,
        status: PocketStatus.paid,
        amount: 250.0,
        isRecurring: true,
        recurringPeriod: 'mesačne',
      ),
      Pocket(
        title: 'Lyžovačka - Alpy',
        participants: 8,
        progress: 0.35,
        status: PocketStatus.owedToYou,
        amount: 350.0,
        isRecurring: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Header
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Pocket cards
            ...pockets.asMap().entries.map((entry) {
              final index = entry.key;
              final pocket = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPocketCard(pocket),
              ).animate().fadeIn(
                delay: (200 + index * 100).ms,
                duration: 600.ms,
              ).slideX(begin: 0.2, end: 0);
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Moje Pockety',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Implementovať pridanie pocketu
            print('Pridať pocket');
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF5E18EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.1, end: 0);
  }
  
  Widget _buildPocketCard(Pocket pocket) {
    return GestureDetector(
      onTap: () {
        // TODO: Implementovať otvorenie pocketu
        print('Otvoriť pocket: ${pocket.title}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              pocket.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Participants
            Text(
              '${pocket.participants} ľudí',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
            
            // Recurring period (if applicable)
            if (pocket.isRecurring && pocket.recurringPeriod != null)
              Text(
                pocket.recurringPeriod!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pocket.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF5E18EA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Status and amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getStatusText(pocket),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(pocket),
                  ),
                ),
                if (pocket.isRecurring && pocket.amount > 0)
                  Text(
                    '${pocket.amount.toStringAsFixed(0)} € ${pocket.recurringPeriod}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                if (pocket.status == PocketStatus.paid && pocket.isRecurring)
                  const Text(
                    '🔄',
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _getStatusText(Pocket pocket) {
    switch (pocket.status) {
      case PocketStatus.owed:
        return 'Dlužíš ${pocket.amount.toStringAsFixed(0)} €';
      case PocketStatus.paid:
        return 'Zaplatené';
      case PocketStatus.owedToYou:
        return 'Dlužia ti ${pocket.amount.toStringAsFixed(0)} €';
    }
  }
  
  Color _getStatusColor(Pocket pocket) {
    switch (pocket.status) {
      case PocketStatus.owed:
        return const Color(0xFFEF4444);
      case PocketStatus.paid:
        return const Color(0xFF10B981);
      case PocketStatus.owedToYou:
        return Colors.white;
    }
  }
}
