import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html; // web-only open
import '../providers/app_state.dart';
import '../widgets/animated_amount_input.dart';
import '../widgets/participants_card.dart';
import '../widgets/payer_field.dart';
import '../widgets/split_items_field.dart';
import '../widgets/action_buttons.dart';

class QuickSplitScreen extends StatefulWidget {
  const QuickSplitScreen({super.key});

  @override
  State<QuickSplitScreen> createState() => _QuickSplitScreenState();
}

class _QuickSplitScreenState extends State<QuickSplitScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width <= 420 ? 20 : (width <= 768 ? 32 : 40);
    final double maxContentWidth = width <= 480 ? 420 : (width <= 1024 ? 560 : 720);
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24), // väčšia medzera pred prvým nadpisom
            // Page title
            Text(
              'Pridať platbu',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12), // menšia medzera po nadpise
            
            // Amount input section - veľký šedý text
            _buildAmountSection(),
            const SizedBox(height: 12), // jednotná menšia medzera medzi položkami
            
            // Split items field
            const SplitItemsField(),
            const SizedBox(height: 32), // väčšia medzera pred ďalším nadpisom
            
            // Split between section
            _buildSplitBetweenSection(),
            const SizedBox(height: 32), // väčšia medzera pred ďalším nadpisom
            
            // Who paid section
            const PayerField(),
            const SizedBox(height: 32), // väčšia medzera nad tlačidlom
            
            // Action buttons - len Zaplatiť tlačidlo
            _buildPayButton(),
          ],
        ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAmountSection() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return GestureDetector(
          onTap: () => _showAmountEditDialog(context, appState),
          child: Container(
            height: 80,
            child: Text(
              '${appState.amount.toStringAsFixed(0)}€',
              style: GoogleFonts.poppins(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF929292),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showAmountEditDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController(text: appState.amount.toStringAsFixed(0));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Zadať sumu',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Suma v €',
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
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Zrušiť',
              style: TextStyle(color: Color(0xFF5E18EA)),
            ),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0.0;
              appState.setAmount(amount);
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF5E18EA)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSplitBetweenSection() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
            return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rozdeliť medzi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                // Plus vpravo
                IconButton(
                  onPressed: () async {
                    final id = await appState.ensureQuickSplitCreated();
                    if (id == null) return;
                    final origin = Uri.base.origin; // http://localhost:8080
                    final shareUrl = '$origin/?qs=$id';
                    _showShareDialog(context, shareUrl);
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF5E18EA)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12), // menšia medzera po nadpise
            const ParticipantsCard(),
          ],
        );
      },
    );
  }
  
  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handlePayMeForYou(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5E18EA),
          foregroundColor: Colors.white,
          // jemne vyššie pre mobil (1.6x)
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(225),
          ),
        ),
        child: Text(
          'Zaplatiť',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
  
  void _handlePayMeForYou() {
    final appState = context.read<AppState>();
    if (appState.amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zadajte sumu väčšiu ako 0'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    final me = appState.participants.firstWhere((p) => p.name == 'Ty', orElse: () => appState.participants.first);
    final amount = me.selected ? me.amount : 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Žiadna suma na platenie pre „Ty“'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    final iban = appState.payeeIban;
    final cc = appState.currency;
    final msg = 'Platba za QuickSplit';
    final cn = appState.payeeName;

    final uri = Uri(
      scheme: 'https',
      host: 'payme.sk',
      path: '/',
      queryParameters: {
        'V': '1', // verzia štandardu
        'IBAN': iban,
        'AM': amount.toStringAsFixed(2),
        'CC': cc,
        'MSG': msg,
        'CN': cn,
      },
    );
    _openExternal(uri);
  }

  void _showShareDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Zdieľať QuickSplit', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Odkaz skopíruj a otvor v druhom okne:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              SelectableText(url, style: const TextStyle(color: Colors.white)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link skopírovaný')));
              },
              child: const Text('Kopírovať', style: TextStyle(color: Color(0xFF5E18EA))),
            ),
            TextButton(
              onPressed: () {
                html.window.open(url, '_blank');
                Navigator.pop(context);
              },
              child: const Text('Otvoriť', style: TextStyle(color: Color(0xFF5E18EA))),
            ),
          ],
        );
      },
    );
  }

  void _openExternal(Uri url) {
    // Flutter web: otvor do novej karty
    html.window.open(url.toString(), '_blank');
  }
}
