// ===== GROUP POCKET DEBUG SCRIPT =====
console.log('🚀 Script.js načítaný!');

// Globálne premenné pre skupiny
let currentGroup = null;
let groupMembers = [];
let groupExpenses = [];
let currentUsername = '';
let connectedGroups = [];

// Session storage kľúče
const STORAGE_KEYS = {
    CONNECTED_GROUPS: 'groupPocket_connectedGroups',
    CURRENT_USERNAME: 'groupPocket_username'
};

document.addEventListener('DOMContentLoaded', () => {
    console.log('📄 DOM načítaný, inicializujem aplikáciu...');
    
    // Elementy pre výdavky
        const form = document.getElementById('expenseForm');
    const resultSection = document.getElementById('result');
    const totalAmountEl = document.getElementById('totalAmount');
    const perPersonEl = document.getElementById('perPerson');
    const paymentButtons = document.getElementById('paymentButtons');
    
    // Elementy pre skupiny
    const groupsCard = document.getElementById('groupsCard');
    const expensesCard = document.getElementById('expensesCard');
    const createGroupBtn = document.getElementById('createGroupBtn');
    const joinGroupBtn = document.getElementById('joinGroupBtn');
    const currentGroupDiv = document.getElementById('currentGroup');
    const groupNameSpan = document.getElementById('groupName');
    const groupIDSpan = document.getElementById('groupID');
    const leaveGroupBtn = document.getElementById('leaveGroupBtn');
    
    // Elementy pre členov
    const memberCountSpan = document.getElementById('memberCount');
    const newMemberNameInput = document.getElementById('newMemberName');
    const addMemberBtn = document.getElementById('addMemberBtn');
    const membersListDiv = document.getElementById('membersList');
    
    // Elementy pre výdavky
    const expenseDescriptionInput = document.getElementById('expenseDescription');
    const expenseAmountInput = document.getElementById('expenseAmount');
    const addExpenseBtn = document.getElementById('addExpenseBtn');
    const expensesListDiv = document.getElementById('expensesList');
    const totalExpensesSpan = document.getElementById('totalExpenses');
    const perPersonAmountSpan = document.getElementById('perPersonAmount');
    
    // Elementy pre pripojené skupiny
    const connectedGroupsDiv = document.getElementById('connectedGroups');
    const connectedGroupsListDiv = document.getElementById('connectedGroupsList');
    
    // Elementy pre debug
    const listGroupsBtn = document.getElementById('listGroupsBtn');
    
    // Elementy pre skupinové akcie
    const splitExpensesBtn = document.getElementById('splitExpensesBtn');
    const backToGroupBtn = document.getElementById('backToGroupBtn');
    const refreshGroupBtn = document.getElementById('refreshGroupBtn');
    const payMeBtn = document.getElementById('payMeBtn');
    
    // Modálne okná
    const createGroupModal = document.getElementById('createGroupModal');
    const joinGroupModal = document.getElementById('joinGroupModal');
    const createGroupForm = document.getElementById('createGroupForm');
    const joinGroupForm = document.getElementById('joinGroupForm');
    const cancelCreateGroup = document.getElementById('cancelCreateGroup');
    const cancelJoinGroup = document.getElementById('cancelJoinGroup');
    
    // Debug: skontroluj či sa našli elementy
    console.log('🔍 Debug elementov:');
    console.log('- Form:', form ? '✅' : '❌');
    console.log('- Result section:', resultSection ? '✅' : '❌');
    console.log('- Groups card:', groupsCard ? '✅' : '❌');
    console.log('- Expenses card:', expensesCard ? '✅' : '❌');

    const DEFAULT_IBAN = 'SK2111000000002932830628';
    const CURRENCY = 'EUR';

    // ===== SESSION STORAGE FUNKCIE =====
    
    function loadFromSession() {
        try {
            const savedGroups = sessionStorage.getItem(STORAGE_KEYS.CONNECTED_GROUPS);
            const savedUsername = sessionStorage.getItem(STORAGE_KEYS.CURRENT_USERNAME);
            
            if (savedGroups) {
                connectedGroups = JSON.parse(savedGroups);
                console.log('📱 Načítané pripojené skupiny:', connectedGroups);
            }
            
            if (savedUsername) {
                currentUsername = savedUsername;
                console.log('👤 Načítaná prezívka:', currentUsername);
            }
            
            updateConnectedGroupsDisplay();
        } catch (error) {
            console.error('❌ Chyba pri načítavaní z session storage:', error);
        }
    }
    
    function saveToSession() {
        try {
            sessionStorage.setItem(STORAGE_KEYS.CONNECTED_GROUPS, JSON.stringify(connectedGroups));
            sessionStorage.setItem(STORAGE_KEYS.CURRENT_USERNAME, currentUsername);
            console.log('💾 Uložené do session storage');
        } catch (error) {
            console.error('❌ Chyba pri ukladaní do session storage:', error);
        }
    }
    
    function addToConnectedGroups(groupData, username) {
        const groupInfo = {
            ...groupData,
            username: username,
            joinedAt: new Date(),
            lastAccessed: new Date()
        };
        
        // Odstráň duplikáty
        connectedGroups = connectedGroups.filter(g => g.id !== groupData.id);
        connectedGroups.push(groupInfo);
        
        saveToSession();
        updateConnectedGroupsDisplay();
    }
    
    function removeFromConnectedGroups(groupId) {
        connectedGroups = connectedGroups.filter(g => g.id !== groupId);
        saveToSession();
        updateConnectedGroupsDisplay();
    }
    
    function updateConnectedGroupsDisplay() {
        if (connectedGroups.length === 0) {
            connectedGroupsDiv.style.display = 'none';
            return;
        }
        
        connectedGroupsDiv.style.display = 'block';
        connectedGroupsListDiv.innerHTML = '';
        
        connectedGroups.forEach(group => {
            const groupDiv = document.createElement('div');
            groupDiv.className = 'connected-group-item';
            groupDiv.innerHTML = `
                <div class="connected-group-info">
                    <h5>${group.name}</h5>
                    <p>ID: ${group.id} • Členovia: ${group.members ? group.members.length : 0}</p>
                </div>
                <div class="connected-group-actions">
                    <button class="btn btn-primary" onclick="joinExistingGroup('${group.id}')">Otvoriť</button>
                    <button class="btn btn-danger" onclick="leaveConnectedGroup('${group.id}')">Odstrániť</button>
                </div>
            `;
            connectedGroupsListDiv.appendChild(groupDiv);
        });
    }
    
    // Globálne funkcie pre onclick
    window.joinExistingGroup = async (groupId) => {
        const group = connectedGroups.find(g => g.id === groupId);
        if (group) {
            await showGroup(group);
        }
    };
    
    window.leaveConnectedGroup = (groupId) => {
        if (confirm('Naozaj chceš odstrániť túto skupinu zo svojich pripojených skupín?')) {
            removeFromConnectedGroups(groupId);
        }
    };

    // ===== FUNKCIE PRE SKUPINY =====
    
    function generateGroupID() {
        return Math.random().toString(36).substring(2, 8).toUpperCase();
    }
    
    async function createGroup(groupName, username) {
        console.log('🏗️ Vytváram skupinu:', groupName, 'pre používateľa:', username);
        console.log('🔍 Firebase DB dostupný:', !!window.firebaseDB);
        console.log('🔍 Firebase funkcie dostupné:', {
            collection: !!window.firebaseCollection,
            addDoc: !!window.firebaseAddDoc
        });
        
        try {
            const groupID = generateGroupID();
            const groupData = {
                name: groupName,
                id: groupID,
                createdAt: new Date(),
                members: [username] // Pridaj tvorcu ako prvého člena
            };
            
            console.log('📝 Ukladám skupinu do databázy:', groupData);
            
            if (window.firebaseDB && window.firebaseCollection && window.firebaseAddDoc) {
                console.log('🔥 Používam Firebase...');
                // Skutočné ukladanie do Firebase
                const groupsRef = window.firebaseCollection(window.firebaseDB, 'groups');
                const docRef = await window.firebaseAddDoc(groupsRef, groupData);
                console.log('✅ Skupina uložená s ID:', docRef.id);
                groupData.firebaseId = docRef.id;
            } else {
                console.log('⚠️ Firebase nie je dostupný, používam simuláciu...');
                // Simulácia pre testovanie
                await new Promise(resolve => setTimeout(resolve, 1000));
                console.log('✅ Skupina úspešne vytvorená (simulácia)!');
            }
            
            // Pridaj do pripojených skupín
            addToConnectedGroups(groupData, username);
            
            return groupData;
            
        } catch (error) {
            console.error('❌ Chyba pri vytváraní skupiny:', error);
            console.error('❌ Error details:', {
                message: error.message,
                stack: error.stack,
                firebaseAvailable: !!window.firebaseDB
            });
            throw error;
        }
    }
    
    async function joinGroup(groupID, username) {
        console.log('🔗 Pripájam sa ku skupine:', groupID, 'ako:', username);
        
        try {
            if (window.firebaseDB) {
                console.log('🔍 Vyhľadávam skupinu v Firebase...');
                
                // Skutočné vyhľadanie v Firebase
                const groupsRef = window.firebaseCollection(window.firebaseDB, 'groups');
                const q = window.firebaseQuery(groupsRef, window.firebaseWhere('id', '==', groupID));
                const querySnapshot = await window.firebaseGetDocs(q);
                
                console.log('📊 Počet nájdených skupín:', querySnapshot.size);
                
                if (querySnapshot.empty) {
                    // Skúsme nájsť všetky skupiny pre debug
                    console.log('🔍 Hľadám všetky skupiny pre debug...');
                    const allGroupsQuery = await window.firebaseGetDocs(groupsRef);
                    console.log('📋 Všetky skupiny v databáze:');
                    allGroupsQuery.forEach((doc, index) => {
                        const data = doc.data();
                        console.log(`${index + 1}. ID: "${data.id}", Name: "${data.name}", Firebase ID: ${doc.id}`);
                    });
                    
                    throw new Error(`Skupina s ID "${groupID}" neexistuje. Skontroluj ID a skús znovu.`);
                }
                
                const doc = querySnapshot.docs[0];
                const groupData = { ...doc.data(), firebaseId: doc.id };
                
                // Pridaj používateľa do skupiny ak tam nie je
                if (!groupData.members.includes(username)) {
                    groupData.members.push(username);
                    
                    // Ulož aktualizovanú skupinu do Firebase
                    if (window.firebaseUpdateDoc) {
                        const groupRef = window.firebaseDoc(window.firebaseDB, 'groups', doc.id);
                        await window.firebaseUpdateDoc(groupRef, {
                            members: groupData.members
                        });
                        console.log('✅ Používateľ pridaný do skupiny v Firebase');
                    }
                }
                
                console.log('✅ Skupina nájdená:', groupData);
                
                // Pridaj do pripojených skupín
                addToConnectedGroups(groupData, username);
                
                return groupData;
            } else {
                // Simulácia pre testovanie
                await new Promise(resolve => setTimeout(resolve, 1000));
                const groupData = {
                    name: `Skupina ${groupID}`,
                    id: groupID,
                    createdAt: new Date(),
                    members: [username]
                };
                console.log('✅ Úspešne pripojený ku skupine (simulácia)!');
                
                // Pridaj do pripojených skupín
                addToConnectedGroups(groupData, username);
                
                return groupData;
            }
            
        } catch (error) {
            console.error('❌ Chyba pri pripájaní ku skupine:', error);
            throw error;
        }
    }
    
    async function showGroup(groupData) {
        console.log('👥 Zobrazujem skupinu:', groupData);
        console.log('🔍 currentGroupDiv:', currentGroupDiv);
        console.log('🔍 groupNameSpan:', groupNameSpan);
        console.log('🔍 groupIDSpan:', groupIDSpan);
        
        currentGroup = groupData;
        groupMembers = groupData.members || [];
        groupExpenses = groupData.expenses || [];
        
        // Načítať najnovšie dáta z Firebase
        if (window.firebaseDB && groupData.firebaseId) {
            try {
                console.log('🔄 Načítavam najnovšie dáta z Firebase...');
                const groupRef = window.firebaseDoc(window.firebaseDB, 'groups', groupData.firebaseId);
                const groupSnap = await window.firebaseGetDoc(groupRef);
                
                if (groupSnap.exists()) {
                    const latestData = groupSnap.data();
                    groupMembers = latestData.members || [];
                    groupExpenses = latestData.expenses || [];
                    console.log('✅ Najnovšie dáta načítané:', { members: groupMembers, expenses: groupExpenses });
                }
            } catch (error) {
                console.error('❌ Chyba pri načítavaní dát z Firebase:', error);
            }
        }
        
        if (groupNameSpan) {
            groupNameSpan.textContent = groupData.name;
        } else {
            console.error('❌ groupNameSpan nenájdený!');
        }
        
        if (groupIDSpan) {
            groupIDSpan.textContent = `ID: ${groupData.id}`;
        } else {
            console.error('❌ groupIDSpan nenájdený!');
        }
        
        updateMembersDisplay();
        updateExpensesDisplay();
        updateExpensesSummary();
        
        // Zobraz len skupinové sekcie, nie starú expenses stránku
        if (currentGroupDiv) {
            currentGroupDiv.style.display = 'block';
            console.log('✅ currentGroupDiv zobrazený');
        } else {
            console.error('❌ currentGroupDiv nenájdený!');
        }
        
        if (expensesCard) {
            expensesCard.style.display = 'none'; // Skryj starú stránku
        }
        
        if (groupsCard) {
            groupsCard.style.display = 'none';
        }
        
        // Zobraz aj pripojené skupiny
        if (connectedGroupsDiv) {
            connectedGroupsDiv.style.display = 'block';
        }
    }
    
    function updateMembersDisplay() {
        console.log('👥 Aktualizujem zobrazenie členov:', groupMembers);
        console.log('🔍 memberCountSpan:', memberCountSpan);
        console.log('🔍 membersListDiv:', membersListDiv);
        
        if (memberCountSpan) {
            memberCountSpan.textContent = groupMembers.length;
        } else {
            console.error('❌ memberCountSpan nenájdený!');
        }
        
        if (membersListDiv) {
            membersListDiv.innerHTML = '';
            groupMembers.forEach((member, index) => {
                const memberDiv = document.createElement('div');
                memberDiv.className = 'member-item';
                
                // Zvýrazniť aktuálneho používateľa
                if (member === currentUsername) {
                    memberDiv.classList.add('current-user');
                }
                
                memberDiv.innerHTML = `
                    <span>${member}</span>
                    <button class="remove-member" data-index="${index}">×</button>
                `;
                membersListDiv.appendChild(memberDiv);
            });
            console.log('✅ Členovia zobrazení');
        } else {
            console.error('❌ membersListDiv nenájdený!');
        }
    }
    
    async function addMember(memberName) {
        if (!memberName.trim()) return;
        
        console.log('👤 Pridávam člena:', memberName);
        groupMembers.push(memberName.trim());
        
        // Uložiť do Firebase
        if (window.firebaseDB && currentGroup.firebaseId) {
            try {
                const groupRef = window.firebaseDoc(window.firebaseDB, 'groups', currentGroup.firebaseId);
                await window.firebaseUpdateDoc(groupRef, {
                    members: groupMembers
                });
                console.log('✅ Člen uložený do Firebase');
                
                // Aktualizovať zobrazenie po úspešnom uložení
                updateMembersDisplay();
                updateExpensesSummary();
            } catch (error) {
                console.error('❌ Chyba pri ukladaní člena:', error);
                // Aj pri chybe aktualizovať zobrazenie (lokálne)
                updateMembersDisplay();
                updateExpensesSummary();
            }
        } else {
            // Ak nie je Firebase, aktualizovať len lokálne
            updateMembersDisplay();
            updateExpensesSummary();
        }
        
        newMemberNameInput.value = '';
    }
    
    async function removeMember(index) {
        console.log('🗑️ Odstraňujem člena:', groupMembers[index]);
        groupMembers.splice(index, 1);
        
        // Uložiť do Firebase
        if (window.firebaseDB && currentGroup.firebaseId) {
            try {
                const groupRef = window.firebaseDoc(window.firebaseDB, 'groups', currentGroup.firebaseId);
                await window.firebaseUpdateDoc(groupRef, {
                    members: groupMembers
                });
                console.log('✅ Člen odstránený z Firebase');
                
                // Aktualizovať zobrazenie po úspešnom uložení
                updateMembersDisplay();
                updateExpensesSummary();
            } catch (error) {
                console.error('❌ Chyba pri odstraňovaní člena:', error);
                // Aj pri chybe aktualizovať zobrazenie (lokálne)
                updateMembersDisplay();
                updateExpensesSummary();
            }
        } else {
            // Ak nie je Firebase, aktualizovať len lokálne
            updateMembersDisplay();
            updateExpensesSummary();
        }
    }
    
    function updateExpensesDisplay() {
        console.log('💰 Aktualizujem zobrazenie výdavkov:', groupExpenses);
        console.log('🔍 expensesListDiv:', expensesListDiv);
        
        if (expensesListDiv) {
            expensesListDiv.innerHTML = '';
            
            if (groupExpenses.length === 0) {
                expensesListDiv.innerHTML = '<p style="text-align: center; color: #4a5568; font-style: italic;">Žiadne výdavky</p>';
                console.log('✅ Zobrazené "Žiadne výdavky"');
                return;
            }
            
            groupExpenses.forEach((expense, index) => {
                const expenseDiv = document.createElement('div');
                expenseDiv.className = 'expense-item';
                expenseDiv.innerHTML = `
                    <div class="expense-info">
                        <h6>${expense.description}</h6>
                        <p>Pridal: ${expense.addedBy} • ${new Date(expense.createdAt).toLocaleDateString('sk-SK')}</p>
                    </div>
                    <div class="expense-amount">${formatMoney(expense.amount)} €</div>
                    <div class="expense-actions">
                        <button class="btn btn-danger" onclick="removeExpense(${index})">Odstrániť</button>
                    </div>
                `;
                expensesListDiv.appendChild(expenseDiv);
            });
            console.log('✅ Výdavky zobrazené');
        } else {
            console.error('❌ expensesListDiv nenájdený!');
        }
    }
    
    function updateExpensesSummary() {
        console.log('📊 Aktualizujem summary výdavkov');
        
        const totalExpenses = calculateTotalExpenses();
        const perPersonAmount = calculatePerPersonAmount();
        
        if (totalExpensesSpan) {
            totalExpensesSpan.textContent = `${formatMoney(totalExpenses)} €`;
        }
        
        if (perPersonAmountSpan) {
            perPersonAmountSpan.textContent = `${formatMoney(perPersonAmount)} €`;
        }
        
        console.log('✅ Summary aktualizované:', { total: totalExpenses, perPerson: perPersonAmount });
    }
    
    async function addExpense(description, amount) {
        if (!description.trim() || !amount || amount <= 0) return;
        
        console.log('💰 Pridávam výdavok:', description, amount);
        
        const expense = {
            description: description.trim(),
            amount: parseFloat(amount),
            addedBy: currentUsername,
            createdAt: new Date()
        };
        
        groupExpenses.push(expense);
        
        // Uložiť do Firebase
        if (window.firebaseDB && currentGroup.firebaseId) {
            try {
                const groupRef = window.firebaseDoc(window.firebaseDB, 'groups', currentGroup.firebaseId);
                await window.firebaseUpdateDoc(groupRef, {
                    expenses: groupExpenses
                });
                console.log('✅ Výdavok uložený do Firebase');
                
                // Aktualizovať zobrazenie po úspešnom uložení
                updateExpensesDisplay();
                updateExpensesSummary();
            } catch (error) {
                console.error('❌ Chyba pri ukladaní výdavku:', error);
                // Aj pri chybe aktualizovať zobrazenie (lokálne)
                updateExpensesDisplay();
                updateExpensesSummary();
            }
        } else {
            // Ak nie je Firebase, aktualizovať len lokálne
            updateExpensesDisplay();
            updateExpensesSummary();
        }
        
        expenseDescriptionInput.value = '';
        expenseAmountInput.value = '';
    }
    
    async function removeExpense(index) {
        if (confirm('Naozaj chceš odstrániť tento výdavok?')) {
            console.log('🗑️ Odstraňujem výdavok:', groupExpenses[index]);
            groupExpenses.splice(index, 1);
            
            // Uložiť do Firebase
            if (window.firebaseDB && currentGroup.firebaseId) {
                try {
                    const groupRef = window.firebaseDoc(window.firebaseDB, 'groups', currentGroup.firebaseId);
                    await window.firebaseUpdateDoc(groupRef, {
                        expenses: groupExpenses
                    });
                    console.log('✅ Výdavok odstránený z Firebase');
                    
                    // Aktualizovať zobrazenie po úspešnom uložení
                    updateExpensesDisplay();
                    updateExpensesSummary();
                } catch (error) {
                    console.error('❌ Chyba pri odstraňovaní výdavku:', error);
                    // Aj pri chybe aktualizovať zobrazenie (lokálne)
                    updateExpensesDisplay();
                    updateExpensesSummary();
                }
            } else {
                // Ak nie je Firebase, aktualizovať len lokálne
                updateExpensesDisplay();
                updateExpensesSummary();
            }
        }
    }
    
    // Pomocné funkcie
    function formatMoney(amount) {
        return parseFloat(amount).toFixed(2);
    }
    
    function calculateTotalExpenses() {
        return groupExpenses.reduce((total, expense) => total + parseFloat(expense.amount), 0);
    }
    
    function calculatePerPersonAmount() {
        const total = calculateTotalExpenses();
        const memberCount = groupMembers.length;
        return memberCount > 0 ? total / memberCount : 0;
    }
    
    
    function openPaymeLink() {
        const totalExpenses = calculateTotalExpenses();
        const perPersonAmount = calculatePerPersonAmount();
        
        if (totalExpenses === 0) {
            alert('V skupine nie sú žiadne výdavky na rozdelenie.');
            return;
        }
        
        if (groupMembers.length === 0) {
            alert('V skupine nie sú žiadni členovia.');
            return;
        }
        
        const paymeUrl = createPaymeUrl({
            iban: 'SK2111000000002932830628',
            amount: perPersonAmount.toFixed(2),
            currency: 'EUR',
            message: 'GroupPocket'
        });
        
        console.log('💰 Payme URL:', paymeUrl);
        window.open(paymeUrl, '_blank');
    }
    
    // Globálne funkcie pre onclick
    window.removeExpense = removeExpense;
    
    function hideGroup() {
        console.log('👋 Opúšťam skupinu');
        currentGroup = null;
        
        if (currentGroupDiv) {
            currentGroupDiv.style.display = 'none';
        }
        if (expensesCard) {
            expensesCard.style.display = 'none';
        }
        if (groupsCard) {
            groupsCard.style.display = 'block';
        }
        if (connectedGroupsDiv) {
            connectedGroupsDiv.style.display = 'none';
        }
    }
    
    function showSplitExpenses() {
        console.log('💰 Zobrazujem rozdelenie výdavkov');
        
        // Skryj skupinové sekcie a zobraz expenses stránku
        if (currentGroupDiv) {
            currentGroupDiv.style.display = 'none';
        }
        if (expensesCard) {
            expensesCard.style.display = 'block';
        }
        if (groupsCard) {
            groupsCard.style.display = 'none';
        }
        if (connectedGroupsDiv) {
            connectedGroupsDiv.style.display = 'none';
        }
    }
    
    function backToGroup() {
        console.log('🔙 Vraciam sa ku skupine');
        
        // Skryj expenses stránku a zobraz skupinové sekcie
        if (currentGroupDiv) {
            currentGroupDiv.style.display = 'block';
        }
        if (expensesCard) {
            expensesCard.style.display = 'none';
        }
        if (groupsCard) {
            groupsCard.style.display = 'none';
        }
        if (connectedGroupsDiv) {
            connectedGroupsDiv.style.display = 'block';
        }
    }
    
    function showModal(modal) {
        modal.style.display = 'flex';
    }
    
    function hideModal(modal) {
        modal.style.display = 'none';
    }
    
    async function listAllGroups() {
        console.log('📋 Zobrazujem všetky skupiny...');
        
        try {
            if (window.firebaseDB) {
                const groupsRef = window.firebaseCollection(window.firebaseDB, 'groups');
                const querySnapshot = await window.firebaseGetDocs(groupsRef);
                
                console.log('📊 Počet skupín v databáze:', querySnapshot.size);
                
                if (querySnapshot.empty) {
                    alert('V databáze nie sú žiadne skupiny.');
                    return;
                }
                
                let groupsList = 'Všetky skupiny v databáze:\n\n';
                querySnapshot.forEach((doc, index) => {
                    const data = doc.data();
                    groupsList += `${index + 1}. Názov: "${data.name}"\n`;
                    groupsList += `   ID: "${data.id}"\n`;
                    groupsList += `   Členovia: ${data.members ? data.members.length : 0}\n`;
                    groupsList += `   Firebase ID: ${doc.id}\n\n`;
                });
                
                alert(groupsList);
            } else {
                alert('Firebase nie je dostupný.');
            }
        } catch (error) {
            console.error('❌ Chyba pri zobrazovaní skupín:', error);
            alert('Chyba pri načítavaní skupín: ' + error.message);
        }
    }

    function formatMoney(value) {
        const num = Number(value);
        if (!isFinite(num)) return '0.00';
        return num.toFixed(2);
    }

    function createPaymeUrl({ iban, amount, currency, message, vs }) {
        console.log('🔗 Vytváram Payme URL s parametrami:', { iban, amount, currency, message, vs });
        
        // Jednoduchý formát URL pre Payme.sk - len základné parametre
        const params = new URLSearchParams();
        params.set('V', '1');
        params.set('IBAN', iban || 'SK2111000000002932830628');
        params.set('AM', amount || '0.00');
        params.set('CC', currency || 'EUR');
        params.set('MSG', message || 'GroupPocket');
        
        const url = `https://payme.sk/?${params.toString()}`;
        console.log('🔗 Vygenerovaný Payme URL:', url);
        return url;
    }

    function renderButtons(peopleCount, perPersonAmount) {
        console.log('🎯 Renderujem tlačidlá pre', peopleCount, 'ľudí, suma na osobu:', perPersonAmount);
        
        paymentButtons.innerHTML = '';

        const heading = document.createElement('h4');
        heading.textContent = 'Zaplaťte svoj podiel:';
        paymentButtons.appendChild(heading);

        for (let i = 1; i <= peopleCount; i++) {
            console.log(`🔘 Vytváram tlačidlo #${i}`);
            
            const a = document.createElement('a');
            a.className = 'btn btn-payment';
            a.textContent = `Zaplatiť podiel #${i}`;
            a.target = '_blank';
            a.rel = 'noopener noreferrer';

            const url = createPaymeUrl({
                iban: DEFAULT_IBAN,
                amount: formatMoney(perPersonAmount),
                currency: CURRENCY,
                message: 'GroupPocket'
            });

            a.href = url;
            paymentButtons.appendChild(a);
            console.log(`✅ Tlačidlo #${i} pridané s URL:`, url);
        }
        
        console.log('🎯 Všetky tlačidlá vyrenderované!');
    }

    form.addEventListener('submit', (e) => {
        console.log('📝 Formulár odoslaný!');
        e.preventDefault();

        const amountInput = document.getElementById('amount');
        const peopleInput = document.getElementById('people');

        console.log('📊 Hodnoty z formulára:');
        console.log('- Suma:', amountInput.value);
        console.log('- Počet ľudí:', peopleInput.value);

        const total = Number(amountInput.value);
        const people = Math.max(2, Math.min(20, Number(peopleInput.value)));

        console.log('🧮 Vypočítané hodnoty:');
        console.log('- Total:', total);
        console.log('- People:', people);

        if (!isFinite(total) || total <= 0 || !isFinite(people) || people < 2) {
            console.log('❌ Neplatné hodnoty, ukončujem');
            return;
        }

        const perPerson = total / people;
        console.log('💰 Suma na osobu:', perPerson);

        totalAmountEl.textContent = `${formatMoney(total)} €`;
        perPersonEl.textContent = `${formatMoney(perPerson)} €`;

        console.log('🎨 Aktualizujem zobrazenie výsledkov...');
        renderButtons(people, perPerson);

        resultSection.style.display = 'block';
        resultSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
        
        console.log('✅ Aplikácia dokončená!');
    });

    // ===== EVENT LISTENERY PRE SKUPINY =====
    
    // Vytvoriť skupinu
    createGroupBtn.addEventListener('click', () => {
        console.log('🏗️ Klik na vytvoriť skupinu');
        showModal(createGroupModal);
    });
    
    // Pripájať sa ku skupine
    joinGroupBtn.addEventListener('click', () => {
        console.log('🔗 Klik na pripájať sa ku skupine');
        showModal(joinGroupModal);
    });
    
    // Zobraziť všetky skupiny
    if (listGroupsBtn) {
        listGroupsBtn.addEventListener('click', () => {
            console.log('📋 Klik na zobraziť všetky skupiny');
            listAllGroups();
        });
    }
    
    // Rozdeliť výdavky - odstránené z HTML
    // splitExpensesBtn.addEventListener('click', () => {
    //     console.log('💰 Klik na rozdeliť výdavky');
    //     showSplitExpenses();
    // });
    
    // Späť ku skupine
    if (backToGroupBtn) {
        backToGroupBtn.addEventListener('click', () => {
            console.log('🔙 Klik na späť ku skupine');
            backToGroup();
        });
    }
    
    // Obnoviť skupinu
    if (refreshGroupBtn) {
        refreshGroupBtn.addEventListener('click', async () => {
            console.log('🔄 Klik na obnoviť skupinu');
            if (currentGroup) {
                await showGroup(currentGroup);
            }
        });
    }
    
    // Vyplatiť (Payme)
    if (payMeBtn) {
        payMeBtn.addEventListener('click', () => {
            console.log('💰 Klik na vyplatiť');
            openPaymeLink();
        });
    }
    
    // Pridať člena
    if (addMemberBtn) {
        addMemberBtn.addEventListener('click', () => {
            const memberName = newMemberNameInput.value.trim();
            if (memberName) {
                addMember(memberName);
                newMemberNameInput.value = '';
            }
        });
    }
    
    // Pridať výdavok
    if (addExpenseBtn) {
        addExpenseBtn.addEventListener('click', () => {
            const description = expenseDescriptionInput.value.trim();
            const amount = parseFloat(expenseAmountInput.value);
            if (description && amount > 0) {
                addExpense(description, amount);
                expenseDescriptionInput.value = '';
                expenseAmountInput.value = '';
            }
        });
    }
    
    // Event listener pre odstraňovanie členov (delegovaný)
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('remove-member')) {
            const index = parseInt(e.target.getAttribute('data-index'));
            removeMember(index);
        }
    });
    
    // Enter kláves pre pridávanie členov
    if (newMemberNameInput) {
        newMemberNameInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                const memberName = newMemberNameInput.value.trim();
                if (memberName) {
                    addMember(memberName);
                    newMemberNameInput.value = '';
                }
            }
        });
    }
    
    // Enter kláves pre pridávanie výdavkov
    if (expenseDescriptionInput) {
        expenseDescriptionInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                const description = expenseDescriptionInput.value.trim();
                const amount = parseFloat(expenseAmountInput.value);
                if (description && amount > 0) {
                    addExpense(description, amount);
                    expenseDescriptionInput.value = '';
                    expenseAmountInput.value = '';
                }
            }
        });
    }
    
    if (expenseAmountInput) {
        expenseAmountInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                const description = expenseDescriptionInput.value.trim();
                const amount = parseFloat(expenseAmountInput.value);
                if (description && amount > 0) {
                    addExpense(description, amount);
                    expenseDescriptionInput.value = '';
                    expenseAmountInput.value = '';
                }
            }
        });
    }
    
    // Opustiť skupinu
    if (leaveGroupBtn) {
        leaveGroupBtn.addEventListener('click', () => {
            console.log('👋 Klik na opustiť skupinu');
            hideGroup();
        });
    }
    
    // Zrušiť vytvorenie skupiny
    if (cancelCreateGroup) {
        cancelCreateGroup.addEventListener('click', () => {
            console.log('❌ Zrušenie vytvorenia skupiny');
            hideModal(createGroupModal);
            createGroupForm.reset();
        });
    }
    
    // Zrušiť pripájanie sa ku skupine
    if (cancelJoinGroup) {
        cancelJoinGroup.addEventListener('click', () => {
            console.log('❌ Zrušenie pripájania sa ku skupine');
            hideModal(joinGroupModal);
            joinGroupForm.reset();
        });
    }
    
    // Submit vytvorenia skupiny
    if (createGroupForm) {
        createGroupForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        console.log('📝 Submit vytvorenia skupiny');
        
        const groupNameInput = document.getElementById('groupNameInput');
        const usernameInput = document.getElementById('createUsernameInput');
        const groupName = groupNameInput.value.trim();
        const username = usernameInput.value.trim();
        
        if (!groupName) {
            alert('Zadajte názov skupiny!');
            return;
        }
        
        if (!username) {
            alert('Zadajte svoju prezívku!');
            return;
        }
        
        currentUsername = username;
        saveToSession();
        
        try {
            const groupData = await createGroup(groupName, username);
            hideModal(createGroupModal);
            createGroupForm.reset();
            await showGroup(groupData);
        } catch (error) {
            console.error('❌ Chyba v createGroupForm:', error);
            alert('Chyba pri vytváraní skupiny: ' + error.message);
        }
        });
    }
    
    // Submit pripájania sa ku skupine
    if (joinGroupForm) {
        joinGroupForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        console.log('📝 Submit pripájania sa ku skupine');
        
        const groupIDInput = document.getElementById('groupIDInput');
        const usernameInput = document.getElementById('joinUsernameInput');
        const groupID = groupIDInput.value.trim().toUpperCase();
        const username = usernameInput.value.trim();
        
        if (!groupID) {
            alert('Zadajte ID skupiny!');
            return;
        }
        
        if (!username) {
            alert('Zadajte svoju prezívku!');
            return;
        }
        
        currentUsername = username;
        saveToSession();
        
        try {
            const groupData = await joinGroup(groupID, username);
            hideModal(joinGroupModal);
            joinGroupForm.reset();
            await showGroup(groupData);
        } catch (error) {
            alert('Chyba pri pripájaní ku skupine: ' + error.message);
        }
        });
    }
    
    // Zavrieť modálne okná kliknutím mimo ne
    if (createGroupModal) {
        createGroupModal.addEventListener('click', (e) => {
            if (e.target === createGroupModal) {
                hideModal(createGroupModal);
                createGroupForm.reset();
            }
        });
    }
    
    if (joinGroupModal) {
        joinGroupModal.addEventListener('click', (e) => {
            if (e.target === joinGroupModal) {
                hideModal(joinGroupModal);
                joinGroupForm.reset();
            }
        });
    }
    
    // Duplicitné event listenery odstránené - už sú pridané vyššie
    
    expenseAmountInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            const description = expenseDescriptionInput.value.trim();
            const amount = parseFloat(expenseAmountInput.value);
            
            if (description && amount > 0) {
                addExpense(description, amount);
            }
        }
    });
    
    // Načítaj session storage pri štarte
    loadFromSession();
    
    console.log('🎯 Všetky event listenery nastavené!');
});



