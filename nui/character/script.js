/* ===========================================
   Double Sync - Character Selection Script
   NUI Communication Handler
=========================================== */

// State
let characters = [];
let selectedCharacter = null;
let maxCharacters = 3;

// DOM Elements
const app = document.getElementById('app');
const selectScreen = document.getElementById('character-select');
const createScreen = document.getElementById('character-create');
const charactersContainer = document.getElementById('characters-container');
const slotCount = document.getElementById('slot-count');
const btnPlay = document.getElementById('btn-play');
const btnDelete = document.getElementById('btn-delete');
const btnCreate = document.getElementById('btn-create');
const deleteModal = document.getElementById('delete-modal');
const deleteName = document.getElementById('delete-name');

// ===========================================
// NUI Message Handler
// ===========================================
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'open':
            openUI(data.characters, data.maxCharacters);
            break;
        case 'close':
            closeUI();
            break;
        case 'characterCreated':
            onCharacterCreated(data.character);
            break;
        case 'characterDeleted':
            onCharacterDeleted(data.citizenid);
            break;
        case 'error':
            showError(data.message);
            break;
    }
});

// ===========================================
// UI Functions
// ===========================================
function openUI(chars, max) {
    characters = chars || [];
    maxCharacters = max || 3;
    selectedCharacter = null;
    
    renderCharacters();
    updateButtons();
    showSelectScreen();
    
    app.classList.remove('hidden');
}

function closeUI() {
    app.classList.add('hidden');
    selectedCharacter = null;
}

function showSelectScreen() {
    selectScreen.classList.add('active');
    createScreen.classList.remove('active');
}

function showCreateScreen() {
    if (characters.length >= maxCharacters) {
        showError('Maximum characters reached!');
        return;
    }
    
    selectScreen.classList.remove('active');
    createScreen.classList.add('active');
    
    // Reset form
    document.getElementById('create-form').reset();
}

// ===========================================
// Character Rendering
// ===========================================
function renderCharacters() {
    charactersContainer.innerHTML = '';
    
    // Render existing characters
    characters.forEach((char, index) => {
        const card = createCharacterCard(char, index);
        charactersContainer.appendChild(card);
    });
    
    // Render empty slots
    const emptySlots = maxCharacters - characters.length;
    for (let i = 0; i < emptySlots; i++) {
        const emptyCard = createEmptyCard();
        charactersContainer.appendChild(emptyCard);
    }
    
    // Update slot count
    slotCount.textContent = `${characters.length}/${maxCharacters}`;
}

function createCharacterCard(char, index) {
    const card = document.createElement('div');
    card.className = 'character-card';
    card.onclick = () => selectCharacter(index);
    
    const charinfo = char.charinfo || {};
    const job = char.job || { label: 'Unemployed' };
    const money = char.money || { cash: 0, bank: 0 };
    
    // Calculate age from birthdate
    let age = '??';
    if (charinfo.birthdate) {
        const birth = new Date(charinfo.birthdate);
        const today = new Date();
        age = Math.floor((today - birth) / (365.25 * 24 * 60 * 60 * 1000));
    }
    
    card.innerHTML = `
        <div class="char-name">${charinfo.firstname || 'Unknown'} ${charinfo.lastname || ''}</div>
        <div class="char-info">
            <div class="char-info-row">
                <span class="char-label">Age</span>
                <span class="char-value">${age}</span>
            </div>
            <div class="char-info-row">
                <span class="char-label">Gender</span>
                <span class="char-value">${capitalizeFirst(charinfo.gender || 'Unknown')}</span>
            </div>
            <div class="char-info-row">
                <span class="char-label">Cash</span>
                <span class="char-value">$${formatMoney(money.cash || 0)}</span>
            </div>
            <div class="char-info-row">
                <span class="char-label">Bank</span>
                <span class="char-value">$${formatMoney(money.bank || 0)}</span>
            </div>
        </div>
        <div class="char-job">
            <span class="job-badge">${job.label || 'Unemployed'}</span>
        </div>
    `;
    
    return card;
}

function createEmptyCard() {
    const card = document.createElement('div');
    card.className = 'character-card empty';
    card.onclick = showCreateScreen;
    
    card.innerHTML = `
        <div class="empty-text">
            <span class="empty-icon">+</span>
            <div>Empty Slot</div>
        </div>
    `;
    
    return card;
}

// ===========================================
// Character Selection
// ===========================================
function selectCharacter(index) {
    selectedCharacter = index;
    
    // Update visual selection
    const cards = document.querySelectorAll('.character-card:not(.empty)');
    cards.forEach((card, i) => {
        card.classList.toggle('selected', i === index);
    });
    
    updateButtons();
}

function updateButtons() {
    const hasSelection = selectedCharacter !== null;
    const canCreate = characters.length < maxCharacters;
    
    btnPlay.disabled = !hasSelection;
    btnDelete.disabled = !hasSelection;
    btnCreate.disabled = !canCreate;
    
    if (!canCreate) {
        btnCreate.querySelector('.btn-icon').textContent = '✓';
    }
}

// ===========================================
// Character Actions
// ===========================================
function playCharacter() {
    if (selectedCharacter === null) return;
    
    const char = characters[selectedCharacter];
    if (!char) return;
    
    // Send to Lua
    fetch(`https://${GetParentResourceName()}/selectCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ citizenid: char.citizenid })
    });
}

function createCharacter(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    
    const charinfo = {
        firstname: formData.get('firstname').trim(),
        lastname: formData.get('lastname').trim(),
        birthdate: formData.get('birthdate'),
        gender: formData.get('gender'),
        nationality: formData.get('nationality').trim() || 'Unknown',
        backstory: formData.get('backstory').trim()
    };
    
    // Validate
    if (!charinfo.firstname || !charinfo.lastname) {
        showError('Please fill in all required fields');
        return;
    }
    
    // Send to Lua
    fetch(`https://${GetParentResourceName()}/createCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ charinfo: charinfo })
    });
}

function confirmDelete() {
    if (selectedCharacter === null) return;
    
    const char = characters[selectedCharacter];
    if (!char) return;
    
    const charinfo = char.charinfo || {};
    deleteName.textContent = `${charinfo.firstname || 'Unknown'} ${charinfo.lastname || ''}`;
    
    deleteModal.classList.remove('hidden');
}

function closeDeleteModal() {
    deleteModal.classList.add('hidden');
}

function deleteCharacter() {
    if (selectedCharacter === null) return;
    
    const char = characters[selectedCharacter];
    if (!char) return;
    
    // Send to Lua
    fetch(`https://${GetParentResourceName()}/deleteCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ citizenid: char.citizenid })
    });
    
    closeDeleteModal();
}

// ===========================================
// Callbacks from Lua
// ===========================================
function onCharacterCreated(character) {
    characters.push(character);
    selectedCharacter = characters.length - 1;
    renderCharacters();
    updateButtons();
    showSelectScreen();
    
    // Select the new character visually
    setTimeout(() => {
        const cards = document.querySelectorAll('.character-card:not(.empty)');
        cards.forEach((card, i) => {
            card.classList.toggle('selected', i === selectedCharacter);
        });
    }, 100);
}

function onCharacterDeleted(citizenid) {
    characters = characters.filter(c => c.citizenid !== citizenid);
    selectedCharacter = null;
    renderCharacters();
    updateButtons();
}

function showError(message) {
    // Simple alert for now - can be replaced with custom notification
    console.error('[DS-Core]', message);
    // TODO: Add custom notification system
}

// ===========================================
// Utility Functions
// ===========================================
function formatMoney(amount) {
    return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function capitalizeFirst(str) {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1);
}

// ===========================================
// Keyboard Handler
// ===========================================
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        if (!deleteModal.classList.contains('hidden')) {
            closeDeleteModal();
        }
        // Don't close the main UI with ESC - only through Lua
    }
});

// ===========================================
// Debug / Development
// ===========================================
function GetParentResourceName() {
    return window.GetParentResourceName ? window.GetParentResourceName() : 'ds-core';
}

// Test data for development (remove in production)
// openUI([
//     {
//         citizenid: 'DS123456',
//         charinfo: { firstname: 'John', lastname: 'Smith', birthdate: '1885-05-15', gender: 'male' },
//         job: { label: 'Sheriff' },
//         money: { cash: 1500, bank: 3000 }
//     }
// ], 3);
