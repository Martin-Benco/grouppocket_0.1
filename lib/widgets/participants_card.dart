import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/app_state.dart';
import 'participants_modal.dart';

class ParticipantsCard extends StatelessWidget {
  const ParticipantsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF929292)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              ...appState.participants.asMap().entries.map((entry) {
                final index = entry.key;
                final participant = entry.value;
                
                return _buildParticipantItem(
                  context,
                  participant,
                  index,
                  appState.participants.length - 1 == index,
                );
              }),
              // Odstránené tlačidlo "Upraviť"
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildParticipantItem(
    BuildContext context,
    Participant participant,
    int index,
    bool isLast,
  ) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                participant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
               if (participant.selected)
                 SvgPicture.asset(
                   'assets/icons/paidstatus.svg',
                   width: 16,
                   height: 16,
                 )
                  else
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF6B7280), width: 2),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '${participant.amount.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Positioned(
            left: 12,
            right: 12,
            bottom: 0,
            child: Container(
              height: 1,
              color: const Color(0xFF929292),
            ),
          ),
      ],
    );
  }
  
  // Zrušené modálne okno na úpravu účastníkov podľa požiadavky
}
