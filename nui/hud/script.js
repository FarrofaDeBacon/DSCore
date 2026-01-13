/* ===========================================
   Double Sync - HUD Script
   NUI Communication Handler
=========================================== */

// DOM Elements
const hud = document.getElementById('hud');
const moneyDisplays = {
    cash: document.querySelector('#money-cash .money-value'),
    bank: document.querySelector('#money-bank .money-value'),
    gold: document.querySelector('#money-gold .money-value')
};
const statusBars = {
    health: {
        bar: document.getElementById('status-health'),
        fill: document.querySelector('#status-health .status-fill'),
        value: document.querySelector('#status-health .status-value')
    },
    hunger: {
        bar: document.getElementById('status-hunger'),
        fill: document.querySelector('#status-hunger .status-fill'),
        value: document.querySelector('#status-hunger .status-value')
    },
    thirst: {
        bar: document.getElementById('status-thirst'),
        fill: document.querySelector('#status-thirst .status-fill'),
        value: document.querySelector('#status-thirst .status-value')
    },
    stamina: {
        bar: document.getElementById('status-stamina'),
        fill: document.querySelector('#status-stamina .status-fill'),
        value: document.querySelector('#status-stamina .status-value')
    }
};
const playerName = document.getElementById('player-name');
const playerJob = document.querySelector('#player-job .job-badge');
const notificationsContainer = document.getElementById('notifications');

// ===========================================
// NUI Message Handler
// ===========================================
window.addEventListener('message', function (event) {
    const data = event.data;

    switch (data.action) {
        case 'show':
            showHUD();
            break;
        case 'hide':
            hideHUD();
            break;
        case 'updateMoney':
            updateMoney(data.moneyType, data.amount);
            break;
        case 'updateAllMoney':
            updateAllMoney(data.money);
            break;
        case 'updateStatus':
            updateStatus(data.status, data.value);
            break;
        case 'updateAllStatus':
            updateAllStatus(data);
            break;
        case 'updatePlayer':
            updatePlayerInfo(data.name, data.job);
            break;
        case 'notify':
            showNotification(data.message, data.type);
            break;
    }
});

// ===========================================
// HUD Visibility
// ===========================================
function showHUD() {
    hud.classList.remove('hidden');
}

function hideHUD() {
    hud.classList.add('hidden');
}

// ===========================================
// Money Updates
// ===========================================
function updateMoney(type, amount) {
    if (!moneyDisplays[type]) return;

    const element = moneyDisplays[type];
    const container = element.closest('.money-item');

    // Format and update
    const formatted = type === 'gold' ? amount : '$' + formatNumber(amount);
    element.textContent = formatted;

    // Animation
    container.classList.add('updated');
    setTimeout(() => container.classList.remove('updated'), 500);
}

function updateAllMoney(money) {
    if (!money) return;

    Object.keys(money).forEach(type => {
        if (moneyDisplays[type]) {
            const formatted = type === 'gold' ? money[type] : '$' + formatNumber(money[type]);
            moneyDisplays[type].textContent = formatted;
        }
    });
}

// ===========================================
// Status Updates
// ===========================================
function updateStatus(status, value) {
    const bar = statusBars[status];
    if (!bar) return;

    // Clamp value
    value = Math.max(0, Math.min(100, value));

    // Update fill and value
    bar.fill.style.width = value + '%';
    bar.value.textContent = Math.round(value);

    // Status classes
    bar.bar.classList.remove('low', 'critical');
    if (value <= 20) {
        bar.bar.classList.add('critical');
    } else if (value <= 40) {
        bar.bar.classList.add('low');
    }
}

function updateAllStatus(data) {
    if (data.health !== undefined) updateStatus('health', data.health);
    if (data.hunger !== undefined) updateStatus('hunger', data.hunger);
    if (data.thirst !== undefined) updateStatus('thirst', data.thirst);
    if (data.stamina !== undefined) updateStatus('stamina', data.stamina);
}

// ===========================================
// Player Info Updates
// ===========================================
function updatePlayerInfo(name, job) {
    if (name) playerName.textContent = name;
    if (job) playerJob.textContent = job;
}

// ===========================================
// Notifications
// ===========================================
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `<div class="notification-text">${message}</div>`;

    // Click to dismiss
    notification.onclick = () => notification.remove();

    notificationsContainer.appendChild(notification);

    // Auto remove after 5s
    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 5000);
}

// ===========================================
// Utility Functions
// ===========================================
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

// ===========================================
// Development/Debug
// ===========================================
function GetParentResourceName() {
    return window.GetParentResourceName ? window.GetParentResourceName() : 'ds-core';
}

// Test data (remove in production)
// showHUD();
// updateAllMoney({ cash: 1500, bank: 5000, gold: 25 });
// updateAllStatus({ health: 85, hunger: 60, thirst: 45, stamina: 90 });
// updatePlayerInfo('John Smith', 'Sheriff');
// showNotification('Welcome back!', 'success');
