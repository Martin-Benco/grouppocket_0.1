// Firebase konfigurácia pre GroupPocket Flutter aplikáciu
// Nahraď tieto hodnoty svojimi z Firebase Console

const firebaseConfig = {
  'apiKey': 'AIzaSyBe3IpLHA-KOBkVpBL7bHP0RwxwN_DOGoA',
  'authDomain': 'grouppocket-402df.firebaseapp.com',
  'projectId': 'grouppocket-402df',
  'storageBucket': 'grouppocket-402df.firebasestorage.app',
  'messagingSenderId': '321578774200',
  'appId': '1:321578774200:web:a62b3a2ad2e0355e21ce4d',
  'measurementId': 'G-34MYJBFRM9'
};

// Inštrukcie pre nastavenie Firebase:
// 1. Choď do Firebase Console (https://console.firebase.google.com/)
// 2. Vyber projekt "grouppocket-402df" alebo vytvor nový
// 3. Choď do Project Settings (⚙️)
// 4. V sekcii "Your apps" klikni na "Add app" → Flutter
// 5. Skopíruj konfiguračné údaje a nahraď ich v lib/firebase_options.dart
// 6. V Firestore Database vytvor databázu v testovacom móde
// 7. Nastav Firebase pravidlá pre bezpečnosť
