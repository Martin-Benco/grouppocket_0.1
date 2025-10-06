import 'package:flutter/material.dart';
import 'dart:async';
import '../services/firebase_service.dart';

class AppState extends ChangeNotifier {
  final FirebaseService _firebaseService;
  String? _quicksplitId; // id dokumentu v quicksplits
  bool _createdAfterFirstChange = false; // vytvoriť až pri prvej zmene defaultnej sumy
  StreamSubscription<Map<String, dynamic>?>? _watchSub;

  AppState({required FirebaseService firebaseService}) : _firebaseService = firebaseService {
    _calculateAmounts();
  }

  @override
  void dispose() {
    _watchSub?.cancel();
    super.dispose();
  }
  int _currentPageIndex = 0;
  
  int get currentPageIndex => _currentPageIndex;
  
  void setCurrentPage(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }
  
  // QuickSplit data
  double _amount = 120.0; // Počiatočná suma ako na prototype
  List<Participant> _participants = [
    Participant(name: 'Ty', selected: true, amount: 0.0),
  ];
  String _payer = 'Ty';
  List<SplitItem> _splitItems = [];
  // PayMe konfigurácia príjemcu (demo hodnoty, nahraď vlastnými)
  String _payeeIban = 'SK6807200002891987426353';
  String _payeeName = 'GroupPocket';
  String _currency = 'EUR';
  
  double get amount => _amount;
  List<Participant> get participants => _participants;
  String get payer => _payer;
  List<SplitItem> get splitItems => _splitItems;
  String get payeeIban => _payeeIban;
  String get payeeName => _payeeName;
  String get currency => _currency;

  void setPayee({required String iban, String? name, String? currency}) {
    _payeeIban = iban;
    if (name != null) _payeeName = name;
    if (currency != null) _currency = currency;
    notifyListeners();
  }
  
  void setAmount(double amount) {
    _amount = amount;
    _calculateAmounts();
    notifyListeners();
    _persistQuickSplit();
  }
  
  void setPayer(String payer) {
    _payer = payer;
    notifyListeners();
    _updateQuickSplit();
  }
  
  void toggleParticipant(int index) {
    _participants[index].selected = !_participants[index].selected;
    _calculateAmounts();
    notifyListeners();
  }
  
  void addParticipant(String name, {bool sync = true}) {
    _participants.add(Participant(name: name, selected: true, amount: 0.0));
    _calculateAmounts();
    notifyListeners();
    if (sync) {
      _updateQuickSplit();
    }
  }

  /// Pridá ďalšieho účastníka so štandardným názvom "Kamoš N"
  void addNextFriend() {
    final nextNumber = _participants.length; // pri default 1 (Ty) -> Kamoš 1
    addParticipant('Kamoš $nextNumber');
  }
  
  void removeParticipant(int index) {
    if (_participants.length > 1) {
      _participants.removeAt(index);
      _calculateAmounts();
      notifyListeners();
      _updateQuickSplit();
    }
  }
  
  void addSplitItem(String name, double amount) {
    _splitItems.add(SplitItem(name: name, amount: amount));
    notifyListeners();
    _updateQuickSplit();
  }
  
  void removeSplitItem(int index) {
    _splitItems.removeAt(index);
    notifyListeners();
    _updateQuickSplit();
  }
  
  void _calculateAmounts() {
    final selectedParticipants = _participants.where((p) => p.selected).toList();
    final amountPerPerson = selectedParticipants.isNotEmpty 
        ? _amount / selectedParticipants.length 
        : 0.0;
    
    for (var participant in _participants) {
      participant.amount = participant.selected ? amountPerPerson : 0.0;
    }
  }
  
  double get totalSplitItemsAmount {
    return _splitItems.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Firestore persist
  String? get quicksplitId => _quicksplitId;

  Future<String?> ensureQuickSplitCreated() async {
    if (_quicksplitId == null) {
      _quicksplitId = await _firebaseService.createQuickSplit(_toMap());
      _createdAfterFirstChange = true;
      _startWatching();
    }
    return _quicksplitId;
  }

  void connectToQuickSplit(String id) {
    _quicksplitId = id;
    _createdAfterFirstChange = true;
    _startWatching();
  }

  Future<void> _persistQuickSplit() async {
    if (!_createdAfterFirstChange) {
      _createdAfterFirstChange = true;
      _quicksplitId = await _firebaseService.createQuickSplit(_toMap());
      _startWatching();
    } else {
      await _updateQuickSplit();
    }
  }

  Future<void> _updateQuickSplit() async {
    if (_quicksplitId == null) return;
    await _firebaseService.updateQuickSplit(_quicksplitId!, _toMap());
  }

  Map<String, dynamic> _toMap() {
    return {
      'amount': _amount,
      'participants': _participants
          .map((p) => {'name': p.name, 'selected': p.selected, 'amount': p.amount})
          .toList(),
      'payer': _payer,
      'splitItems': _splitItems
          .map((i) => {'name': i.name, 'amount': i.amount})
          .toList(),
      'currency': _currency,
      'payeeIban': _payeeIban,
      'payeeName': _payeeName,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  void _startWatching() {
    final id = _quicksplitId;
    if (id == null) return;
    _watchSub?.cancel();
    _watchSub = _firebaseService.watchQuickSplit(id).listen((data) {
      if (data == null) return;
      // Aktualizuj lokálny stav z DB (source of truth)
      final amount = (data['amount'] as num?)?.toDouble();
      if (amount != null) {
        _amount = amount;
      }
      final participants = (data['participants'] as List<dynamic>?)
              ?.map((e) => Participant(
                    name: e['name'] as String? ?? '',
                    selected: e['selected'] as bool? ?? true,
                    amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
                  ))
              .toList() ??
          [];
      _participants = participants;
      final payer = data['payer'] as String?;
      if (payer != null) _payer = payer;
      final splitItems = (data['splitItems'] as List<dynamic>?)
              ?.map((e) => SplitItem(
                    name: e['name'] as String? ?? '',
                    amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
                  ))
              .toList() ??
          [];
      _splitItems = splitItems;
      _calculateAmounts();
      notifyListeners();
    });
  }
}

class Participant {
  String name;
  bool selected;
  double amount;
  
  Participant({
    required this.name,
    required this.selected,
    required this.amount,
  });
}

class SplitItem {
  String name;
  double amount;
  
  SplitItem({
    required this.name,
    required this.amount,
  });
}
