/* ===========================================
   Double Sync - Inventory Script
   Drag & Drop Inventory System
=========================================== */

// State
let playerInventory = [];
let secondaryInventory = [];
let selectedItem = null;
let draggedItem = null;
let maxSlots = 40;
let maxWeight = 50;
let currentWeight = 0;

// DOM Elements
const inventoryDiv = document.getElementById('inventory');
const playerGrid = document.getElementById('player-grid');
const secondaryGrid = document.getElementById('secondary-grid');
const secondaryPanel = document.getElementById('secondary-panel');
const tooltip = document.getElementById('item-tooltip');

// ===========================================
// NUI Message Handler
// ===========================================
window.addEventListener('message', function (event) {
    const data = event.data;

    switch (data.action) {
        case 'open':
            openInventory(data.items, data.maxSlots, data.maxWeight);
            break;
        case 'close':
            closeInventory();
            break;
        case 'openSecondary':
            openSecondary(data.title, data.items, data.maxSlots);
            break;
        case 'update':
            updateInventory(data.items);
            break;
        case 'error':
            showError(data.message);
            break;
    }
});

// ===========================================
// Inventory Functions
// ===========================================
function openInventory(items, slots, weight) {
    playerInventory = items || [];
    maxSlots = slots || 40;
    maxWeight = weight || 50;

    calculateWeight();
    renderPlayerInventory();

    inventoryDiv.classList.remove('hidden');
}

function closeInventory() {
    inventoryDiv.classList.add('hidden');
    hideTooltip();
    selectedItem = null;

    // Notify Lua
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function updateInventory(items) {
    playerInventory = items;
    calculateWeight();
    renderPlayerInventory();
}

function openSecondary(title, items, slots) {
    document.getElementById('secondary-title').textContent = title;
    secondaryInventory = items || [];
    document.getElementById('secondary-slots').textContent = `${items.length}/${slots}`;

    renderSecondaryInventory(slots);
    secondaryPanel.classList.remove('hidden');
}

// ===========================================
// Rendering
// ===========================================
function renderPlayerInventory() {
    playerGrid.innerHTML = '';

    // Create all slots
    for (let i = 0; i < maxSlots; i++) {
        const slot = createSlot(i, 'player');
        const item = playerInventory.find(item => item.slot === i);

        if (item) {
            slot.appendChild(createItem(item));
            slot.classList.add('rarity-' + (item.rarity || 'common'));
        }

        playerGrid.appendChild(slot);
    }

    // Update info
    document.getElementById('player-slots').textContent = `${playerInventory.length}/${maxSlots}`;
    document.getElementById('current-weight').textContent = currentWeight.toFixed(1);
    document.getElementById('max-weight').textContent = maxWeight;
}

function renderSecondaryInventory(slots) {
    secondaryGrid.innerHTML = '';

    for (let i = 0; i < slots; i++) {
        const slot = createSlot(i, 'secondary');
        const item = secondaryInventory.find(item => item.slot === i);

        if (item) {
            slot.appendChild(createItem(item));
        }

        secondaryGrid.appendChild(slot);
    }
}

function createSlot(index, type) {
    const slot = document.createElement('div');
    slot.className = 'inv-slot';
    slot.dataset.slot = index;
    slot.dataset.type = type;

    // Drag & Drop events
    slot.addEventListener('dragover', handleDragOver);
    slot.addEventListener('drop', handleDrop);
    slot.addEventListener('dragleave', handleDragLeave);
    slot.addEventListener('click', handleSlotClick);

    return slot;
}

function createItem(item) {
    const itemDiv = document.createElement('div');
    itemDiv.className = 'slot-item';
    itemDiv.draggable = true;
    itemDiv.dataset.item = JSON.stringify(item);

    // Item image (placeholder for now)
    const img = document.createElement('div');
    img.className = 'item-image';
    img.style.background = getItemColor(item.name);
    img.style.borderRadius = '4px';
    itemDiv.appendChild(img);

    // Count
    if (item.count > 1) {
        const count = document.createElement('span');
        count.className = 'item-count';
        count.textContent = item.count;
        itemDiv.appendChild(count);
    }

    // Name
    const name = document.createElement('span');
    name.className = 'item-name';
    name.textContent = item.label || item.name;
    itemDiv.appendChild(name);

    // Drag events
    itemDiv.addEventListener('dragstart', handleDragStart);
    itemDiv.addEventListener('dragend', handleDragEnd);
    itemDiv.addEventListener('click', (e) => showItemTooltip(e, item));

    return itemDiv;
}

function getItemColor(name) {
    const colors = {
        bread: 'linear-gradient(135deg, #d4a574, #a67c52)',
        water: 'linear-gradient(135deg, #4a90c9, #2c5a8a)',
        apple: 'linear-gradient(135deg, #c44141, #8a2e2e)',
        meat_cooked: 'linear-gradient(135deg, #8b4513, #5d2e0a)',
        bandage: 'linear-gradient(135deg, #f0f0f0, #c0c0c0)',
        wood: 'linear-gradient(135deg, #8b6914, #5d4710)',
        pickaxe: 'linear-gradient(135deg, #505050, #303030)',
        default: 'linear-gradient(135deg, #606060, #404040)'
    };
    return colors[name] || colors.default;
}

// ===========================================
// Drag & Drop
// ===========================================
function handleDragStart(e) {
    draggedItem = JSON.parse(e.target.dataset.item);
    e.target.closest('.inv-slot').classList.add('dragging');
    e.dataTransfer.effectAllowed = 'move';
}

function handleDragEnd(e) {
    e.target.closest('.inv-slot')?.classList.remove('dragging');
    document.querySelectorAll('.drag-over').forEach(el => el.classList.remove('drag-over'));
    draggedItem = null;
}

function handleDragOver(e) {
    e.preventDefault();
    e.currentTarget.classList.add('drag-over');
}

function handleDragLeave(e) {
    e.currentTarget.classList.remove('drag-over');
}

function handleDrop(e) {
    e.preventDefault();
    e.currentTarget.classList.remove('drag-over');

    if (!draggedItem) return;

    const targetSlot = parseInt(e.currentTarget.dataset.slot);
    const targetType = e.currentTarget.dataset.type;

    // Send to Lua
    fetch(`https://${GetParentResourceName()}/moveItem`, {
        method: 'POST',
        body: JSON.stringify({
            item: draggedItem,
            fromSlot: draggedItem.slot,
            toSlot: targetSlot,
            fromType: 'player',
            toType: targetType
        })
    });
}

function handleSlotClick(e) {
    const slot = e.currentTarget;
    document.querySelectorAll('.selected').forEach(el => el.classList.remove('selected'));

    if (slot.querySelector('.slot-item')) {
        slot.classList.add('selected');
    }
}

// ===========================================
// Tooltip
// ===========================================
function showItemTooltip(e, item) {
    e.stopPropagation();
    selectedItem = item;

    document.getElementById('tooltip-name').textContent = item.label || item.name;
    document.getElementById('tooltip-weight').textContent = (item.weight / 1000).toFixed(1) + ' kg';
    document.getElementById('tooltip-desc').textContent = item.description || 'No description';

    tooltip.classList.remove('hidden');
}

function hideTooltip() {
    tooltip.classList.add('hidden');
    selectedItem = null;
}

// ===========================================
// Item Actions
// ===========================================
function useItem() {
    if (!selectedItem) return;

    fetch(`https://${GetParentResourceName()}/useItem`, {
        method: 'POST',
        body: JSON.stringify({ item: selectedItem })
    });

    hideTooltip();
}

function dropItem() {
    if (!selectedItem) return;

    fetch(`https://${GetParentResourceName()}/dropItem`, {
        method: 'POST',
        body: JSON.stringify({ item: selectedItem })
    });

    hideTooltip();
}

function giveItem() {
    if (!selectedItem) return;

    fetch(`https://${GetParentResourceName()}/giveItem`, {
        method: 'POST',
        body: JSON.stringify({ item: selectedItem })
    });

    hideTooltip();
}

// ===========================================
// Utility
// ===========================================
function calculateWeight() {
    currentWeight = playerInventory.reduce((total, item) => {
        return total + ((item.weight || 0) * (item.count || 1)) / 1000;
    }, 0);
}

function showError(message) {
    console.error('[DS-Inventory]', message);
}

function GetParentResourceName() {
    return window.GetParentResourceName ? window.GetParentResourceName() : 'ds-core';
}

// ===========================================
// Keyboard Handler
// ===========================================
document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' || e.key === 'i' || e.key === 'I') {
        if (!inventoryDiv.classList.contains('hidden')) {
            closeInventory();
        }
    }
});

// Click outside tooltip to close
document.addEventListener('click', function (e) {
    if (!tooltip.contains(e.target) && !e.target.closest('.slot-item')) {
        hideTooltip();
    }
});
