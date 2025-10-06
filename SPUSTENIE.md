# 🚀 GroupPocket Flutter - Spustenie aplikácie

## Rýchle spustenie

### 1. Inštalácia závislostí
```bash
flutter pub get
```

### 2. Spustenie aplikácie
```bash
# Debug móda
flutter run

# Release móda
flutter run --release
```

## Firebase nastavenie

### 1. Vytvorenie Firebase projektu
1. Choď na https://console.firebase.google.com/
2. Klikni "Vytvoriť projekt"
3. Pomenuj projekt "GroupPocket" alebo podobne
4. Povoliť Google Analytics (voliteľné)

### 2. Pridanie aplikácie
1. V Firebase Console klikni "Pridať aplikáciu"
2. Vyber platformu (Android/iOS)
3. Zadaj package name: `com.example.grouppocket`
4. Stiahni konfiguračné súbory:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`

### 3. Umiestnenie súborov
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

### 4. Aktualizácia konfigurácie
1. Otvor `lib/firebase_options.dart`
2. Nahraď konfiguračné údaje svojimi z Firebase Console

### 5. Firestore Database
1. V Firebase Console choď do "Firestore Database"
2. Klikni "Vytvoriť databázu"
3. Vyber "Začať v testovacom móde"
4. Vyber lokáciu (napr. europe-west1)

## Funkcie aplikácie

### ✅ Implementované
- **Navigácia**: Prepínanie medzi QuickSplit, Pockets a Account
- **QuickSplit**: 
  - Animovaný input pre sumu
  - Správa účastníkov
  - Výber platiča
  - Rozdelenie na položky
  - Generovanie PayMe linkov
  - Zdieľanie QuickSplit
- **Pockets**: 
  - Zobrazenie pocket kariet
  - Progress bary
  - Rôzne stavy (dlužíš, zaplatené, dlužia ti)
  - Opakujúce sa výdavky
- **Account**: 
  - Profil používateľa
  - Personalizácia
  - Bezpečnostné nastavenia
  - Odhlásenie/mazanie účtu
- **Animácie**: Plynulé prechody a animované prvky
- **Firebase integrácia**: Ukladanie dát do cloudu

### 🔄 Čakajúce implementácie
- Pridávanie nových pocketov
- Otváranie detailov pocketov
- Editovanie profilu
- Notifikácie
- Offline podpora

## Štruktúra projektu

```
lib/
├── main.dart                    # Vstupný bod
├── firebase_options.dart        # Firebase konfigurácia
├── models/
│   └── pocket.dart              # Pocket model
├── providers/
│   └── app_state.dart          # State management
├── screens/
│   ├── main_screen.dart        # Hlavná navigácia
│   ├── quicksplit_screen.dart  # QuickSplit stránka
│   ├── pockets_screen.dart     # Pockets stránka
│   └── account_screen.dart     # Account stránka
├── services/
│   └── firebase_service.dart   # Firebase operácie
└── widgets/
    ├── animated_amount_input.dart
    ├── participants_card.dart
    ├── payer_field.dart
    ├── split_items_field.dart
    ├── action_buttons.dart
    ├── participants_modal.dart
    └── split_items_modal.dart
```

## Testovanie

### Lokálne testovanie
```bash
# Spusti testy
flutter test

# Spusti aplikáciu s hot reload
flutter run --debug
```

### Firebase testovanie
1. Spusti aplikáciu
2. Vytvor QuickSplit
3. Skontroluj Firebase Console → Firestore Database
4. Mala by sa vytvoriť kolekcia `quickSplits`

## Deployment

### Android
```bash
# Vytvor APK
flutter build apk --release

# Vytvor App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Vytvor iOS build
flutter build ios --release
```

## Troubleshooting

### Firebase chyby
- Skontroluj, či sú konfiguračné súbory na správnom mieste
- Over, že Firestore je vytvorená
- Skontroluj Firebase pravidlá

### Animácie nefungujú
- Skontroluj, či je `flutter_animate` nainštalovaný
- Over, že používaš správne verzie Flutter

### Build chyby
- Spusti `flutter clean`
- Spusti `flutter pub get`
- Skontroluj Flutter verziu: `flutter --version`

## Podpora

Pre otázky a problémy:
1. Skontroluj README.md
2. Pozri Firebase dokumentáciu
3. Skontroluj Flutter dokumentáciu

---

**GroupPocket Flutter** - Moderná aplikácia pre zdieľanie výdavkov 🎉
