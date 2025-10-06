import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pocket.dart';
import '../providers/app_state.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;
  
  // QuickSplit Firestore
  Future<String?> createQuickSplit(Map<String, dynamic> data) async {
    try {
      final now = FieldValue.serverTimestamp();
      final doc = await _db.collection('quicksplits').add({
        ...data,
        'createdAt': now,
      });
      return doc.id;
    } catch (e) {
      print('Error createQuickSplit: $e');
      return null;
    }
  }

  Future<void> updateQuickSplit(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('quicksplits').doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updateQuickSplit: $e');
    }
  }

  Future<void> addParticipantToQuickSplit(String id, Map<String, dynamic> participant) async {
    try {
      await _db.runTransaction((tx) async {
        final ref = _db.collection('quicksplits').doc(id);
        final snap = await tx.get(ref);
        if (!snap.exists) return;
        final data = snap.data() as Map<String, dynamic>;
        final List<dynamic> current = (data['participants'] as List<dynamic>?) ?? [];
        final String newName = (participant['name'] as String).trim();
        final bool exists = current.any((p) => (p is Map<String, dynamic>) && (p['name'] as String?)?.trim() == newName);
        if (exists) {
          // nič nemeníme, už existuje
          return;
        }
        final updated = [...current, participant];
        tx.update(ref, {
          'participants': updated,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error addParticipantToQuickSplit: $e');
    }
  }

  Stream<Map<String, dynamic>?> watchQuickSplit(String id) {
    return _db.collection('quicksplits').doc(id).snapshots().map((snap) => snap.data());
  }
  
  // Pocket operations
  Future<List<Pocket>> getPockets() async {
    try {
      // Simulované dáta
      await Future.delayed(const Duration(milliseconds: 300));
      
      return [
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
    } catch (e) {
      print('Error getting pockets: $e');
      return [];
    }
  }
  
  Future<void> savePocket(Pocket pocket) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      print('Pocket uložený (simulácia): ${pocket.title}');
    } catch (e) {
      print('Error saving pocket: $e');
    }
  }
  
  // Share operations
  Future<String> saveShareData(Map<String, dynamic> shareData) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final shareId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      print('Share data uložené (simulácia): $shareId');
      return shareId;
    } catch (e) {
      print('Error saving share data: $e');
      return '';
    }
  }
  
  Future<Map<String, dynamic>?> getShareData(String shareId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      print('Share data načítané (simulácia): $shareId');
      return {
        'amount': 100.0,
        'participants': ['Martin', 'Kristína'],
        'payer': 'Martin',
      };
    } catch (e) {
      print('Error getting share data: $e');
      return null;
    }
  }
  
  // User operations
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      print('User profile aktualizovaný (simulácia)');
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }
  
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'name': 'Kristína Špirengová',
        'email': 'spajrengova@gmail.com',
        'phone': '+421 123 456 789',
        'totalCollected': 568.0,
      };
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
  
  // Authentication
  Future<bool> signInAnonymously() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      print('Anonymné prihlásenie (simulácia)');
      return true;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      print('Odhlásenie (simulácia)');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}