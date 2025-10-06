# GroupPocket Flutter

GroupPocket je aplikácia pre zdieľanie výdavkov napísaná vo Flutter. Aplikácia umožňuje používateľom jednoducho rozdeliť výdavky medzi priateľov a rodinu.

## Funkcie

- **QuickSplit**: Rýchle rozdelenie výdavkov medzi účastníkov
- **Pockets**: Správa skupinových projektov a výdavkov
- **Account**: Správa používateľského profilu
- **Firebase integrácia**: Ukladanie dát do cloudu
- **Animácie**: Plynulé prechody a animované prvky

## Požiadavky

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Firebase projekt

## Inštalácia

1. **Naklonuj repozitár**
   ```bash
   git clone <repository-url>
   cd grouppocket
   ```

2. **Nainštaluj závislosti**
   ```bash
   flutter pub get
   ```

3. **Nastav Firebase**
   - Vytvor Firebase projekt na https://console.firebase.google.com/
   - Pridaj Android/iOS aplikáciu do projektu
   - Stiahni `google-services.json` (Android) a `GoogleService-Info.plist` (iOS)
   - Umiesť súbory do správnych adresárov:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Aktualizuj Firebase konfiguráciu**
   - Otvor `lib/firebase_options.dart`
   - Nahraď konfiguračné údaje svojimi z Firebase Console

5. **Spusti aplikáciu**
   ```bash
   flutter run
   ```

## Štruktúra projektu

```
lib/
├── main.dart                 # Vstupný bod aplikácie
├── firebase_options.dart     # Firebase konfigurácia
├── models/                   # Datové modely
│   └── pocket.dart
├── providers/                 # State management
│   └── app_state.dart
├── screens/                  # UI obrazovky
│   ├── main_screen.dart
│   ├── quicksplit_screen.dart
│   ├── pockets_screen.dart
│   └── account_screen.dart
├── services/                 # Firebase služby
│   └── firebase_service.dart
└── widgets/                  # Znovupoužiteľné komponenty
    ├── animated_amount_input.dart
    ├── participants_card.dart
    ├── payer_field.dart
    ├── split_items_field.dart
    ├── action_buttons.dart
    ├── participants_modal.dart
    └── split_items_modal.dart
```

## Firebase kolekcie

### quickSplits
- `amount`: Suma na rozdelenie
- `participants`: Zoznam účastníkov
- `payer`: Kto platil
- `splitItems`: Rozdelené položky
- `createdAt`: Dátum vytvorenia
- `userId`: ID používateľa

### pockets
- `title`: Názov pocketu
- `participants`: Počet účastníkov
- `progress`: Pokrok (0.0 - 1.0)
- `status`: Stav (owed/paid/owedToYou)
- `amount`: Suma
- `isRecurring`: Opakujúci sa
- `recurringPeriod`: Obdobie opakovania
- `createdAt`: Dátum vytvorenia
- `userId`: ID používateľa

### shares
- `data`: Zdieľané údaje
- `createdAt`: Dátum vytvorenia

### users
- Profilové údaje používateľa
- `updatedAt`: Dátum aktualizácie

## Vývoj

### Pridanie novej funkcie

1. Vytvor model v `lib/models/`
2. Pridaj provider metódy v `lib/providers/app_state.dart`
3. Implementuj UI v `lib/screens/` alebo `lib/widgets/`
4. Pridaj Firebase operácie v `lib/services/firebase_service.dart`

### Testovanie

```bash
# Spusti testy
flutter test

# Spusti aplikáciu v debug móde
flutter run --debug

# Spusti aplikáciu v release móde
flutter run --release
```

## Deployment

### Android

1. **Vytvor release APK**
   ```bash
   flutter build apk --release
   ```

2. **Vytvor App Bundle**
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Vytvor iOS build**
   ```bash
   flutter build ios --release
   ```

2. **Otvoriť v Xcode a archivovať**

## Príspevky

1. Fork repozitár
2. Vytvor feature branch (`git checkout -b feature/nova-funkcia`)
3. Commit zmeny (`git commit -am 'Pridaj novú funkciu'`)
4. Push do branch (`git push origin feature/nova-funkcia`)
5. Vytvor Pull Request

## Licencia

Tento projekt je licencovaný pod MIT licenciou - pozri [LICENSE](LICENSE) súbor pre detaily.

## Kontakt

Pre otázky a podporu kontaktujte vývojový tím.
