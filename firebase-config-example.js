// Firebase konfigurácia - nahraď tieto hodnoty svojimi z Firebase Console
// Nájdeš ich v: Firebase Console → Project Settings → General → Your apps

const firebaseConfig = {
    apiKey: "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    authDomain: "your-project-id.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project-id.appspot.com",
    messagingSenderId: "123456789012",
    appId: "1:123456789012:web:abcdefghijklmnopqrstuvwxyz"
};

// Inštrukcie:
// 1. Choď do Firebase Console (https://console.firebase.google.com/)
// 2. Vyber svoj projekt alebo vytvor nový
// 3. Choď do Project Settings (⚙️)
// 4. V sekcii "Your apps" klikni na "Add app" → Web (</>)
// 5. Skopíruj konfiguračné údaje a nahraď ich v public/index.html
// 6. V Firestore Database vytvor databázu v testovacom móde
// 7. Deploy pravidlá: firebase deploy --only firestore:rules
