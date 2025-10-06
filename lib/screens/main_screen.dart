import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';
import '../services/firebase_service.dart';
import '../screens/quicksplit_screen.dart';
import '../screens/pockets_screen.dart';
// removed account screen per new design

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  final GlobalKey _quickKey = GlobalKey();
  final GlobalKey _pocketsKey = GlobalKey();
  final GlobalKey _barKey = GlobalKey();
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;
  double _barWidth = 0;
  double _trackLeft = 0;
  double _trackWidth = 0;
  double _gap = 24;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculateIndicator(context.read<AppState>().currentPageIndex);
      _handleJoinViaQuery();
    });
  }
  void _handleJoinViaQuery() async {
    final qs = Uri.base.queryParameters['qs'];
    if (qs == null || qs.isEmpty) return;
    final appState = context.read<AppState>();
    // Najprv sa pripoj a načítaj dáta z DB, až potom sa pýtaj prezývku
    if (appState.quicksplitId != qs) {
      appState.connectToQuickSplit(qs);
      // počkaj na prvý snapshot, aby sa lokálny stav naplnil
      try {
        await context.read<FirebaseService>().watchQuickSplit(qs).firstWhere((d) => d != null);
      } catch (_) {}
    }
    // ak je prítomné qs, spýtaj sa na prezývku až po načítaní
    final nickname = await _askForNickname();
    if (nickname == null || nickname.trim().isEmpty) return;
    // pridaj lokálne len ak ešte neexistuje
    final trimmed = nickname.trim();
    final already = appState.participants.any((p) => p.name.trim() == trimmed);
    if (!already) {
      // neprerátavať sumu do DB z tohto klienta, nech serverová verzia ostane
      appState.addParticipant(trimmed, sync: false);
    }
    // zapíš do Firestore
    await context.read<FirebaseService>().addParticipantToQuickSplit(qs, {
      'name': trimmed,
      'selected': true,
      'amount': 0.0,
    });
  }

  Future<String?> _askForNickname() async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Tvoja prezývka', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Zadaj prezývku',
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF929292)),
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zrušiť', style: TextStyle(color: Color(0xFF5E18EA))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('OK', style: TextStyle(color: Color(0xFF5E18EA))),
            ),
          ],
        );
      },
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Po každom rebuilde (napr. zmena šírky okna) prepočítaj pozície indikátora
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculateIndicator(context.read<AppState>().currentPageIndex);
    });
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Navigation headings with underline indicator
          _buildNavigationHeadings(),
          // Page content with animations
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                context.read<AppState>().setCurrentPage(index);
                _recalculateIndicator(index);
              },
              children: const [
                QuickSplitScreen(),
                PocketsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationHeadings() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final activeIndex = appState.currentPageIndex.clamp(0, 1);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: const Color(0xFF141414),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Gap sa dynamicky mení podľa dostupnej šírky kontajnera
              final double gap = (constraints.maxWidth * 0.25).clamp(24.0, 200.0);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      context.read<AppState>().setCurrentPage(0);
                      _recalculateIndicator(0);
                    },
                    child: Text(
                      key: _quickKey,
                      'QuickSplit',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                      SizedBox(width: gap),
                      GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      context.read<AppState>().setCurrentPage(1);
                      _recalculateIndicator(1);
                    },
                    child: Text(
                      key: _pocketsKey,
                      'Pockets',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // baseline (celá čiara) + fialový indikátor pod aktívnym
                  SizedBox(
                    height: 3,
                    child: Stack(
                      key: _barKey,
                      children: [
                        // Biela baseline len v rozsahu, kde sa fialová môže pohybovať
                        Positioned(
                          left: _trackLeft,
                          top: 0,
                          child: Container(
                            width: _trackWidth,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          left: _indicatorLeft,
                          top: 0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            width: _indicatorWidth,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5E18EA),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _recalculateIndicator(int index) {
    // Počkaj na layout a potom zmeriame šírku a pozíciu aktívneho nadpisu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final containerContext = _barKey.currentContext;
      final quickContext = _quickKey.currentContext;
      final pocketsContext = _pocketsKey.currentContext;
      if (containerContext == null || quickContext == null || pocketsContext == null) return;
      final RenderBox containerBox = containerContext.findRenderObject() as RenderBox;
      final RenderBox activeBox = (index == 0 ? quickContext : pocketsContext).findRenderObject() as RenderBox;
      final Offset activeGlobal = activeBox.localToGlobal(Offset.zero);
      final Offset containerGlobal = containerBox.localToGlobal(Offset.zero);
      final double containerWidth = containerBox.size.width;
      final double activeWidth = activeBox.size.width;
      final double activeLeft = activeGlobal.dx - containerGlobal.dx;
      final double activeCenter = activeLeft + activeWidth / 2;

      // Zmeraj centrá QuickSplit a Pockets
      final RenderBox quickBox = quickContext.findRenderObject() as RenderBox;
      final RenderBox pocketsBox = pocketsContext.findRenderObject() as RenderBox;
      final double quickLeft = quickBox.localToGlobal(Offset.zero).dx - containerGlobal.dx;
      final double pocketsLeft = pocketsBox.localToGlobal(Offset.zero).dx - containerGlobal.dx;
      final double quickCenter = quickLeft + quickBox.size.width / 2;
      final double pocketsCenter = pocketsLeft + pocketsBox.size.width / 2;

      // Pevná (responzívna) šírka indikátora: širší než texty, ale nezávislý od nich
      double indicatorWidth = (containerWidth * 0.35).clamp(100, 200);

      // Baseline/trasa sa rozťahuje zo stredu podľa pevnej šírky indikátora
      final double half = indicatorWidth / 2;
      double trackLeft = (quickCenter - half).clamp(0, containerWidth);
      double trackRight = (pocketsCenter + half).clamp(0, containerWidth);
      if (trackRight < trackLeft) {
        final tmp = trackLeft;
        trackLeft = trackRight;
        trackRight = tmp;
      }
      final double trackWidth = (trackRight - trackLeft).clamp(0, containerWidth);

      // Cieľová pozícia indikátora je centrovaná pod aktívnym nadpisom, ale v rámci tracku
      double targetLeft = (activeCenter - indicatorWidth / 2);
      if (targetLeft < trackLeft) targetLeft = trackLeft;
      if (targetLeft + indicatorWidth > trackRight) targetLeft = trackRight - indicatorWidth;

      setState(() {
        _indicatorWidth = indicatorWidth;
        _indicatorLeft = targetLeft;
        _barWidth = containerWidth;
        _trackLeft = trackLeft;
        _trackWidth = trackWidth;
        // Medzera medzi nadpismi rastie so šírkou a reálnymi šírkami textov
        final double available = (containerWidth - (quickBox.size.width + pocketsBox.size.width)).clamp(0, containerWidth);
        final double targetGap = (available * 0.25).clamp(24, containerWidth / 3);
        _gap = targetGap;
      });
    });
  }
}
