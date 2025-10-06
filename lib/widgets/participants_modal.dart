import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ParticipantsModal extends StatefulWidget {
  const ParticipantsModal({super.key});

  @override
  State<ParticipantsModal> createState() => _ParticipantsModalState();
}

class _ParticipantsModalState extends State<ParticipantsModal> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Upraviť účastníkov',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Add participant section
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Meno účastníka',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF5E18EA)),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  onSubmitted: (value) => _addParticipant(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addParticipant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E18EA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Pridať'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Participants list
          Consumer<AppState>(
            builder: (context, appState, child) {
              return Column(
                children: appState.participants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final participant = entry.value;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      border: Border.all(color: const Color(0xFFD9D9D9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: participant.selected,
                          onChanged: (value) {
                            appState.toggleParticipant(index);
                          },
                          activeColor: const Color(0xFF5E18EA),
                        ),
                        Expanded(
                          child: Text(
                            participant.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (appState.participants.length > 1)
                          GestureDetector(
                            onTap: () => appState.removeParticipant(index),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
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
    );
  }
  
  void _addParticipant() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      context.read<AppState>().addParticipant(name);
      _nameController.clear();
    }
  }
}
