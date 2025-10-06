// ===== GROUP POCKET V2 SCRIPT =====
console.log('🚀 GroupPocket V2 Script.js načítaný!');

// Globálne premenné
let currentPage = 'quick-split';
let currentUsername = 'Kristína';

// QuickSplit data
let quickSplitData = {
    amount: 0,
    participants: [
        { name: 'Martin (ty)', selected: true, amount: 0 },
        { name: 'Kristína', selected: true, amount: 0 },
        { name: 'Jozef', selected: false, amount: 0 }
    ],
    payer: 'Martin',
    splitItems: []
};

document.addEventListener('DOMContentLoaded', () => {
    console.log('📄 DOM načítaný, inicializujem aplikáciu V2...');
    
    // Inicializácia navigácie
    initializeNavigation();
    
    // Inicializácia stránok
    initializePages();
    
    // Spusti animované demo pre input sumy
    startAmountTypingAnimation();

    console.log('✅ Aplikácia V2 inicializovaná!');
});

// ===== NAVIGÁCIA =====

function initializeNavigation() {
    const navTabs = document.querySelectorAll('.nav-tab');
    
    navTabs.forEach(tab => {
        tab.addEventListener('click', (e) => {
            e.preventDefault();
            const pageId = tab.getAttribute('data-page');
            switchToPage(pageId);
        });
    });
}

function switchToPage(pageId) {
    console.log('🔄 Prepínam na stránku:', pageId);
    
    // Aktualizuj aktívnu navigačnú záložku
    document.querySelectorAll('.nav-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelector(`[data-page="${pageId}"]`).classList.add('active');
    
    // Získaj aktuálnu a novú stránku
    const currentPageElement = document.querySelector('.page.active');
    const newPageElement = document.getElementById(`${pageId}-page`);
    
    if (!newPageElement || newPageElement === currentPageElement) {
            return;
    }
    
    // Urči smer animácie
    const pages = ['quick-split', 'pockets', 'account'];
    const currentIndex = pages.indexOf(currentPage);
    const newIndex = pages.indexOf(pageId);
    
    if (newIndex > currentIndex) {
        // Ideme doprava - nová stránka prichádza z prava
        newPageElement.classList.add('next');
        newPageElement.classList.remove('prev');
        } else {
        // Ideme doľava - nová stránka prichádza z ľava
        newPageElement.classList.add('prev');
        newPageElement.classList.remove('next');
    }
    
    // Spusti animáciu
    setTimeout(() => {
        if (currentPageElement) {
            currentPageElement.classList.remove('active');
            if (newIndex > currentIndex) {
                currentPageElement.classList.add('prev');
        } else {
                currentPageElement.classList.add('next');
            }
        }
        
        newPageElement.classList.add('active');
        newPageElement.classList.remove('prev', 'next');
        
        currentPage = pageId;
        console.log('✅ Stránka prepnutá na:', pageId);
    }, 10);
}

// ===== INICIALIZÁCIA STRÁNOK =====

function initializePages() {
    // QuickSplit stránka
    initializeQuickSplitPage();
    
    // Pockets stránka
    initializePocketsPage();
    
    // Account stránka
    initializeAccountPage();
}

function initializeQuickSplitPage() {
    console.log('⚡ Inicializujem QuickSplit stránku');
    
    // Event listenery pre QuickSplit
    const payButton = document.querySelector('.pay-button');
    const shareButton = document.querySelector('.share-button');
    const amountInput = document.getElementById('amountInputAnimated');
    const splitItemsField = document.querySelector('.split-items-field');
    const editButton = document.querySelector('.edit-button');
    const payerField = document.querySelector('.payer-field');
    
    // Inicializácia účastníkov
    initializeParticipants();
    
    // Inicializácia platiča
    initializePayer();
    
    if (payButton) {
        payButton.addEventListener('click', () => {
            console.log('💰 Klik na Zaplatiť');
            handlePayment();
        });
    }
    
    if (shareButton) {
        shareButton.addEventListener('click', () => {
            console.log('📤 Klik na Zdieľať QuickSplit');
            handleShare();
        });
    }
    
    if (splitItemsField) {
        splitItemsField.addEventListener('click', () => {
            console.log('📝 Klik na Rozdeliť na položky');
            showSplitItemsModal();
        });
    }
    
    if (editButton) {
        editButton.addEventListener('click', () => {
            console.log('✏️ Klik na Upraviť účastníkov');
            showParticipantsModal();
        });
    }
    
    if (payerField) {
        payerField.addEventListener('click', () => {
            console.log('👤 Klik na výber platiča');
            showPayerModal();
        });
    }

    if (amountInput) {
        const lockCaret = (el) => {
            const v = el.value || '';
            const pos = Math.max(0, v.length - 1);
            el.setSelectionRange(pos, pos);
        };

        // Keď používateľ začne písať, zastav animáciu a prepni na bielu
        amountInput.addEventListener('input', (e) => {
            amountInput.classList.add('filled');
            amountInput.classList.remove('animating');
            
            // Sanitizácia: povoliť iba čísla a 1 desatinný oddeľovač
            let raw = e.target.value.replace(/€/g, '');
            raw = raw.replace(',', '.');
            raw = raw.replace(/[^0-9.]/g, '');
            // povoliť len jednu bodku
            const parts = raw.split('.');
            if (parts.length > 2) {
                raw = parts[0] + '.' + parts.slice(1).join('').replace(/\./g, '');
            }
            // nastav späť s €
            e.target.value = (raw || '') + '€';
            
            // Nastav kurzor pred €
            lockCaret(e.target);
            
            // Aktualizuj sumu a prepočítaj
            handleAmountChange();
        });

        amountInput.addEventListener('focus', (e) => {
            amountInput.classList.add('filled');
            amountInput.classList.remove('animating');
            
            // Nastav kurzor pred €
            lockCaret(e.target);
        });

        // Validácia kláves: len čísla, jeden oddeľovač, blokuj mazanie €
        amountInput.addEventListener('keydown', (e) => {
            const value = e.target.value;
            const cursorPos = e.target.selectionStart;
            const len = value.length;

            // caret nikdy za €
            if (cursorPos === len) lockCaret(e.target);

            // Povolené navigačné
            if (['Tab','ArrowLeft','ArrowRight','ArrowUp','ArrowDown','Home','End'].includes(e.key)) {
                // Ak by šiel za €, vráť späť
                setTimeout(() => lockCaret(e.target), 0);
            return;
        }
        
            // Backspace: povoliť, pokiaľ nie sme priamo za začiatkom a nemažeme €
            if (e.key === 'Backspace') {
                if (cursorPos <= 0) return; // nič
                // na pozícii pred € je OK, nemaže znak €
                return; // povolené
            }

            // Delete: ak by mazal €, zablokuj
            if (e.key === 'Delete') {
                if (cursorPos >= len - 1) {
                    e.preventDefault();
                    return;
                }
                return; // inak povolené
            }

            // Čísla
            if (/^[0-9]$/.test(e.key)) return;
            // Desatinný oddeľovač: len jeden
            if (e.key === '.' || e.key === ',') {
                if (value.includes('.')) { e.preventDefault(); return; }
                // nahradíme za bodku počas input eventu
                    return;
                }
                
            // Iné znaky zamietni
            e.preventDefault();
        });

        // Po kliknutí alebo uvoľnení myši uzamkni caret pred €
        amountInput.addEventListener('click', (e) => lockCaret(e.target));
        amountInput.addEventListener('mouseup', (e) => {
            setTimeout(() => lockCaret(e.target), 0);
        });
        amountInput.addEventListener('keyup', (e) => lockCaret(e.target));
        amountInput.addEventListener('select', (e) => lockCaret(e.target));
    }
}

function initializePocketsPage() {
    console.log('👛 Inicializujem Pockets stránku');
    
    // Event listener pre pridanie nového pocketu
    const addPocketButton = document.querySelector('.add-pocket-button');
    
    if (addPocketButton) {
        addPocketButton.addEventListener('click', () => {
            console.log('➕ Klik na pridanie pocketu');
            // TODO: Implementovať pridanie pocketu
            alert('Funkcia pridania pocketu bude implementovaná v ďalšej verzii');
        });
    }
    
    // Event listenery pre pocket karty
    const pocketCards = document.querySelectorAll('.pocket-card');
    pocketCards.forEach(card => {
        card.addEventListener('click', () => {
            console.log('👛 Klik na pocket kartu');
            // TODO: Implementovať otvorenie pocketu
            alert('Funkcia otvorenia pocketu bude implementovaná v ďalšej verzii');
        });
    });
}

function initializeAccountPage() {
    console.log('👤 Inicializujem Account stránku');
    
    // Event listenery pre edit tlačidlá
    const editButtons = document.querySelectorAll('.edit-button');
    editButtons.forEach(button => {
        button.addEventListener('click', () => {
            console.log('✏️ Klik na edit');
            // TODO: Implementovať edit
            alert('Funkcia editovania bude implementovaná v ďalšej verzii');
        });
    });
    
    // Event listener pre toggle switch
    const toggleSwitch = document.querySelector('.toggle-switch');
    if (toggleSwitch) {
        toggleSwitch.addEventListener('click', () => {
            console.log('🔄 Klik na toggle switch');
            toggleSwitch.classList.toggle('active');
        });
    }
    
    // Event listenery pre other sekciu
    const otherItems = document.querySelectorAll('.other-item');
    otherItems.forEach(item => {
        item.addEventListener('click', () => {
            const text = item.querySelector('.other-text').textContent;
            console.log('🔧 Klik na:', text);
            
            if (text.includes('Odhlásiť sa')) {
                if (confirm('Naozaj sa chceš odhlásiť?')) {
                    alert('Funkcia odhlásenia bude implementovaná v ďalšej verzii');
                }
            } else if (text.includes('Zmazať účet')) {
                if (confirm('Naozaj chceš zmazať účet? Táto akcia je nevratná!')) {
                    alert('Funkcia mazania účtu bude implementovaná v ďalšej verzii');
                }
            } else {
                alert('Funkcia bude implementovaná v ďalšej verzii');
            }
        });
    });
}

// ===== POMOCNÉ FUNKCIE =====

function formatMoney(amount) {
    const num = Number(amount);
    if (!isFinite(num)) return '0.00';
    return num.toFixed(2);
}

function showNotification(message, type = 'info') {
    console.log(`📢 Notifikácia (${type}):`, message);
    // TODO: Implementovať notifikácie
}

// ===== RESPONSIVE DESIGN =====

function handleResize() {
    const container = document.querySelector('.container');
    if (window.innerWidth < 375) {
        container.style.maxWidth = '100%';
    } else {
        container.style.maxWidth = '375px';
    }
}

window.addEventListener('resize', handleResize);
handleResize(); // Inicializácia

// ===== TOUCH EVENTS PRE MOBILNÉ ZARIADENIA =====

let touchStartX = 0;
let touchEndX = 0;
let isAnimating = false;

document.addEventListener('touchstart', (e) => {
    if (isAnimating) return;
    touchStartX = e.changedTouches[0].screenX;
});

document.addEventListener('touchend', (e) => {
    if (isAnimating) return;
    touchEndX = e.changedTouches[0].screenX;
    handleSwipe();
});

function handleSwipe() {
    const swipeThreshold = 50;
    const swipeDistance = touchEndX - touchStartX;
    
    if (Math.abs(swipeDistance) > swipeThreshold) {
        isAnimating = true;
        
        if (swipeDistance > 0) {
            // Swipe doprava - predchádzajúca stránka
            switchToPreviousPage();
        } else {
            // Swipe doľava - ďalšia stránka
            switchToNextPage();
        }
        
        // Resetuj animačný flag po dokončení animácie
        setTimeout(() => {
            isAnimating = false;
        }, 300);
    }
}

function switchToPreviousPage() {
    const pages = ['quick-split', 'pockets', 'account'];
    const currentIndex = pages.indexOf(currentPage);
    const previousIndex = currentIndex > 0 ? currentIndex - 1 : pages.length - 1;
    switchToPage(pages[previousIndex]);
}

function switchToNextPage() {
    const pages = ['quick-split', 'pockets', 'account'];
    const currentIndex = pages.indexOf(currentPage);
    const nextIndex = currentIndex < pages.length - 1 ? currentIndex + 1 : 0;
    switchToPage(pages[nextIndex]);
}

// ===== QUICKSPLIT FUNKCIE =====

function initializeParticipants() {
    console.log('👥 Inicializujem účastníkov');
    updateParticipantsDisplay();
}

function initializePayer() {
    console.log('👤 Inicializujem platiča');
    updatePayerDisplay();
}

function updateParticipantsDisplay() {
    const participantsCard = document.querySelector('.participants-card');
    if (!participantsCard) return;
    
    // Aktualizuj zobrazenie účastníkov
    const participantItems = participantsCard.querySelectorAll('.participant-item');
    participantItems.forEach((item, index) => {
        if (quickSplitData.participants[index]) {
            const participant = quickSplitData.participants[index];
            const nameSpan = item.querySelector('.participant-name');
            const checkIcon = item.querySelector('.participant-check');
            const unselectedDiv = item.querySelector('.participant-unselected');
            const amountSpan = item.querySelector('.participant-amount');
            
            if (nameSpan) nameSpan.textContent = participant.name;
            if (amountSpan) amountSpan.textContent = formatMoney(participant.amount) + ' €';
            
            if (participant.selected) {
                if (checkIcon) checkIcon.style.display = 'block';
                if (unselectedDiv) unselectedDiv.style.display = 'none';
            } else {
                if (checkIcon) checkIcon.style.display = 'none';
                if (unselectedDiv) unselectedDiv.style.display = 'block';
            }
        }
    });
    
    // Aktualizuj súčet
    updateSplitSum();
}

function updatePayerDisplay() {
    const payerField = document.querySelector('.payer-field span');
    if (payerField) {
        payerField.textContent = quickSplitData.payer;
    }
}

function updateSplitSum() {
    const splitSum = document.querySelector('.split-sum');
    if (splitSum) {
        const totalAmount = quickSplitData.amount;
        splitSum.textContent = `sumu ${formatMoney(totalAmount)} €`;
    }
}

function calculateAmounts() {
    const selectedParticipants = quickSplitData.participants.filter(p => p.selected);
    const amountPerPerson = selectedParticipants.length > 0 ? quickSplitData.amount / selectedParticipants.length : 0;
    
    quickSplitData.participants.forEach(participant => {
        participant.amount = participant.selected ? amountPerPerson : 0;
    });
    
    updateParticipantsDisplay();
}

function showParticipantsModal() {
    const modal = createModal('Upraviť účastníkov', `
        <div class="participants-modal-content">
            <div class="add-participant">
                <input type="text" id="newParticipantName" placeholder="Meno účastníka" class="participant-input">
                <button id="addParticipantBtn" class="add-participant-btn">Pridať</button>
            </div>
            <div class="participants-list">
                ${quickSplitData.participants.map((participant, index) => `
                    <div class="participant-modal-item">
                        <label class="participant-checkbox">
                            <input type="checkbox" ${participant.selected ? 'checked' : ''} data-index="${index}">
                            <span>${participant.name}</span>
                        </label>
                        <button class="remove-participant-btn" data-index="${index}">×</button>
                    </div>
                `).join('')}
            </div>
        </div>
    `);
    
    // Event listenery pre modal
    const addBtn = modal.querySelector('#addParticipantBtn');
    const nameInput = modal.querySelector('#newParticipantName');
    const checkboxes = modal.querySelectorAll('input[type="checkbox"]');
    const removeBtns = modal.querySelectorAll('.remove-participant-btn');
    
    addBtn.addEventListener('click', () => {
        const name = nameInput.value.trim();
        if (name) {
            quickSplitData.participants.push({ name, selected: true, amount: 0 });
            nameInput.value = '';
            closeModal();
            showParticipantsModal(); // Znovu otvor modal s aktualizovaným zoznamom
        }
    });
    
    nameInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            addBtn.click();
        }
    });
    
    checkboxes.forEach(checkbox => {
        checkbox.addEventListener('change', (e) => {
            const index = parseInt(e.target.dataset.index);
            quickSplitData.participants[index].selected = e.target.checked;
            calculateAmounts();
        });
    });
    
    removeBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            const index = parseInt(e.target.dataset.index);
            if (quickSplitData.participants.length > 1) {
                quickSplitData.participants.splice(index, 1);
                closeModal();
                showParticipantsModal();
            }
        });
    });
}

function showPayerModal() {
    const modal = createModal('Kto platil?', `
        <div class="payer-modal-content">
            ${quickSplitData.participants.map((participant, index) => `
                <div class="payer-option ${participant.name === quickSplitData.payer ? 'selected' : ''}" data-name="${participant.name}">
                    ${participant.name}
                </div>
            `).join('')}
        </div>
    `);
    
    const payerOptions = modal.querySelectorAll('.payer-option');
    payerOptions.forEach(option => {
        option.addEventListener('click', () => {
            quickSplitData.payer = option.dataset.name;
            closeModal();
            updatePayerDisplay();
        });
    });
}

function showSplitItemsModal() {
    const modal = createModal('Rozdeliť na položky', `
        <div class="split-items-modal-content">
            <div class="add-item">
                <input type="text" id="itemName" placeholder="Názov položky" class="item-input">
                <input type="number" id="itemAmount" placeholder="Suma" step="0.01" class="amount-input">
                <button id="addItemBtn" class="add-item-btn">Pridať</button>
            </div>
            <div class="items-list">
                ${quickSplitData.splitItems.map((item, index) => `
                    <div class="item-modal-item">
                        <span class="item-name">${item.name}</span>
                        <span class="item-amount">${formatMoney(item.amount)} €</span>
                        <button class="remove-item-btn" data-index="${index}">×</button>
                    </div>
                `).join('')}
            </div>
            <div class="total-items">
                <strong>Celkom: ${formatMoney(quickSplitData.splitItems.reduce((sum, item) => sum + item.amount, 0))} €</strong>
            </div>
        </div>
    `);
    
    const addBtn = modal.querySelector('#addItemBtn');
    const nameInput = modal.querySelector('#itemName');
    const amountInput = modal.querySelector('#itemAmount');
    const removeBtns = modal.querySelectorAll('.remove-item-btn');
    
    addBtn.addEventListener('click', () => {
        const name = nameInput.value.trim();
        const amount = parseFloat(amountInput.value);
        if (name && amount > 0) {
            quickSplitData.splitItems.push({ name, amount });
            nameInput.value = '';
            amountInput.value = '';
            closeModal();
            showSplitItemsModal();
        }
    });
    
    removeBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            const index = parseInt(e.target.dataset.index);
            quickSplitData.splitItems.splice(index, 1);
            closeModal();
            showSplitItemsModal();
        });
    });
}

function handlePayment() {
    const selectedParticipants = quickSplitData.participants.filter(p => p.selected);
    if (selectedParticipants.length === 0) {
        showNotification('Vyberte aspoň jedného účastníka', 'error');
        return;
    }
    
    if (quickSplitData.amount <= 0) {
        showNotification('Zadajte sumu väčšiu ako 0', 'error');
        return;
    }
    
    // Generuj PayMe linky pre každého účastníka
    const paymentLinks = selectedParticipants.map(participant => {
        const paymeLink = generatePayMeLink(participant.amount, participant.name);
        return {
            name: participant.name,
            amount: participant.amount,
            link: paymeLink
        };
    });
    
    showPaymentModal(paymentLinks);
}

function handleShare() {
    const selectedParticipants = quickSplitData.participants.filter(p => p.selected);
    if (selectedParticipants.length === 0) {
        showNotification('Vyberte aspoň jedného účastníka', 'error');
        return;
    }
    
    if (quickSplitData.amount <= 0) {
        showNotification('Zadajte sumu väčšiu ako 0', 'error');
        return;
    }
    
    // Vytvor zdieľateľný link
    const shareData = {
        amount: quickSplitData.amount,
        participants: selectedParticipants,
        payer: quickSplitData.payer,
        timestamp: Date.now()
    };
    
    const shareLink = generateShareLink(shareData);
    showShareModal(shareLink);
}

function generatePayMeLink(amount, recipient) {
    // PayMe link formát
    const encodedAmount = encodeURIComponent(amount.toFixed(2));
    const encodedRecipient = encodeURIComponent(recipient);
    return `https://payme.sk/pay?amount=${encodedAmount}&recipient=${encodedRecipient}`;
}

function generateShareLink(data) {
    // Vytvor unikátny ID pre zdieľanie
    const shareId = Math.random().toString(36).substr(2, 9);
    
    // Ulož do Firebase (ak je dostupné)
    if (window.firebaseDB) {
        try {
            const shareRef = window.firebaseCollection(window.firebaseDB, 'shares');
            window.firebaseAddDoc(shareRef, {
                id: shareId,
                data: data,
                createdAt: new Date()
            });
        } catch (error) {
            console.log('Firebase nie je dostupný, používam lokálne uloženie');
        }
    }
    
    // Vytvor URL
    const baseUrl = window.location.origin;
    return `${baseUrl}?share=${shareId}`;
}

function showPaymentModal(paymentLinks) {
    const modal = createModal('Platba', `
        <div class="payment-modal-content">
            <h4>Kliknite na tlačidlo pre platbu:</h4>
            ${paymentLinks.map(link => `
                <div class="payment-link-item">
                    <span class="payment-info">${link.name}: ${formatMoney(link.amount)} €</span>
                    <a href="${link.link}" target="_blank" class="payme-link-btn">Zaplatiť PayMe</a>
                </div>
            `).join('')}
        </div>
    `);
}

function showShareModal(shareLink) {
    const modal = createModal('Zdieľať QuickSplit', `
        <div class="share-modal-content">
            <p>Zdieľajte tento link s účastníkmi:</p>
            <div class="share-link-container">
                <input type="text" value="${shareLink}" readonly class="share-link-input">
                <button id="copyLinkBtn" class="copy-link-btn">Kopírovať</button>
            </div>
        </div>
    `);
    
    const copyBtn = modal.querySelector('#copyLinkBtn');
    const linkInput = modal.querySelector('.share-link-input');
    
    copyBtn.addEventListener('click', () => {
        linkInput.select();
        document.execCommand('copy');
        showNotification('Link skopírovaný do schránky!', 'success');
    });
}

// ===== MODAL FUNKCIE =====

function createModal(title, content) {
    // Odstráň existujúce modály
    const existingModals = document.querySelectorAll('.modal');
    existingModals.forEach(modal => modal.remove());
    
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-content">
            <h3>${title}</h3>
            ${content}
            <div class="modal-actions">
                <button class="close-modal-btn">Zavrieť</button>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
    
    // Event listener pre zatvorenie
    const closeBtn = modal.querySelector('.close-modal-btn');
    closeBtn.addEventListener('click', () => closeModal());
    
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeModal();
        }
    });
    
    return modal;
}

function closeModal() {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => modal.remove());
}

function showNotification(message, type = 'info') {
    console.log(`📢 Notifikácia (${type}):`, message);
    
    // Vytvor notifikáciu
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // Štýly pre notifikáciu
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'error' ? '#EF4444' : type === 'success' ? '#10B981' : '#5E18EA'};
        color: white;
        padding: 12px 20px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        z-index: 10000;
        animation: slideInRight 0.3s ease-out;
    `;
    
    document.body.appendChild(notification);
    
    // Odstráň po 3 sekundách
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// ===== AMOUNT INPUT HANDLING =====

function handleAmountChange() {
    const amountInput = document.getElementById('amountInputAnimated');
    if (!amountInput) return;
    
    const value = amountInput.value.replace('€', '').trim();
    const amount = parseFloat(value) || 0;
    
    quickSplitData.amount = amount;
    calculateAmounts();
}

console.log('🎯 GroupPocket V2 Script.js načítaný úspešne!');

// ===== AMOUNT TYPING ANIMATION =====

let amountAnimationInterval;
function startAmountTypingAnimation() {
    const input = document.getElementById('amountInputAnimated');
    if (!input) return;

    const samples = ['30', '60', '120', '12.50'];
    let idx = 0;

    function typeText(text, onComplete) {
        input.classList.add('animating');
        input.classList.remove('filled');
        input.value = '€'; // € je vždy na konci
        let i = 0;
        const speed = 160;
        const typer = setInterval(() => {
            input.value = text.slice(0, i + 1) + '€';
            i++;
            if (i >= text.length) {
                clearInterval(typer);
                setTimeout(() => eraseText(onComplete), 1100);
            }
        }, speed);
    }

    function eraseText(onComplete) {
        let current = input.value.replace('€', '');
        const eraser = setInterval(() => {
            current = current.slice(0, -1);
            input.value = current + '€';
            if (current.length === 0) {
                clearInterval(eraser);
                if (onComplete) onComplete();
            }
        }, 80);
    }

    function cycle() {
        if (document.activeElement === input) return; // nepúšťaj pri písaní
        typeText(samples[idx], () => {
            idx = (idx + 1) % samples.length;
            setTimeout(() => { if (document.activeElement !== input) cycle(); }, 400);
        });
    }

    // spusti po krátkej pauze
    setTimeout(cycle, 600);
}
