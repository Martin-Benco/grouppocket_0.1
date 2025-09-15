# 🚀 GroupPocket - Deploy Instructions

## Firebase Setup

### 1. Firebase CLI Setup
```bash
# Nainštaluj Firebase CLI
npm install -g firebase-tools

# Prihlás sa do Firebase
firebase login

# Inicializuj projekt
firebase init
```

### 2. Vyber tieto možnosti:
- ✅ **Firestore**: Configure a security rules file for Firestore
- ✅ **Hosting**: Configure files for Firebase Hosting
- ✅ **Functions**: (voliteľné)

### 3. Nastavenia:
- **Firestore rules file**: `firestore.rules`
- **Public directory**: `public`
- **Single-page app**: `Yes` (pre SPA routing)
- **GitHub auto-builds**: `No`

### 4. Deploy
```bash
# Deploy všetko
firebase deploy

# Alebo len pravidlá
firebase deploy --only firestore:rules

# Alebo len hosting
firebase deploy --only hosting
```

## 🎯 Ako to funguje

### Vytvorenie skupiny:
1. Klikni "Vytvoriť novú skupinu"
2. Zadaj názov (napr. "Výlet do Tatier")
3. Skupina sa uloží do Firebase s unikátnym ID
4. Zobrazí sa sekcia pre pridávanie členov

### Pridávanie členov:
1. Zadaj meno člena do inputu
2. Klikni "Pridať člena" alebo stlač Enter
3. Člen sa uloží do Firebase a zobrazí sa v zozname

### Rozdelenie výdavkov:
1. Zadaj sumu a počet ľudí
2. Klikni "Rozdeliť sumu"
3. Zobrazia sa Payme tlačidlá pre každého člena
4. Každé tlačidlo otvorí Payme s predvyplnenou sumou

### Pripájanie sa ku skupine:
1. Klikni "Pripájať sa ku skupine"
2. Zadaj ID skupiny (napr. "ABC123")
3. Ak skupina existuje, pripojíš sa k nej

## 🔧 Firebase Console

### Firestore Database:
- **Kolekcia**: `groups`
- **Dokumenty**: Každá skupina má svoj dokument
- **Polia**: `name`, `id`, `createdAt`, `members[]`

### Hosting:
- **URL**: `https://grouppocket-402df.web.app`
- **Súbory**: Všetko z `public/` adresára

## 🐛 Troubleshooting

### Aplikácia sa nenačítava:
1. Skontroluj konzolu pre chyby
2. Over, že Firebase konfigurácia je správna
3. Skontroluj, že Firestore je vytvorená

### Firebase chyby:
1. Over, že pravidlá sú nasadené: `firebase deploy --only firestore:rules`
2. Skontroluj, že databáza je v testovacom móde
3. Over, že projekt ID je správny

### Payme odkazy nefungujú:
1. Skontroluj formát URL parametrov
2. Over, že suma je správne formátovaná
3. Testuj s rôznymi sumami

## 📱 Testovanie

### Lokálne:
1. Otvor `public/index.html` v prehliadači
2. Všetko by malo fungovať bez Firebase (simulácia)

### Na hostingu:
1. `firebase deploy`
2. Otvor `https://grouppocket-402df.web.app`
3. Všetko by malo fungovať s Firebase

## 🎉 Hotovo!

Tvoja aplikácia GroupPocket je teraz plne funkčná s Firebase ukladaním!
