// app/javascript/expenses.js

// Run when Turbolinks finishes loading the page
document.addEventListener("turbolinks:load", () => {
  // Wrapper that contains all item blocks
  const itemsWrapper = document.getElementById("items-wrapper");

  // Button used to add a new expense item
  const addButton = document.getElementById("add-item-button");

  // Guard clause: exit early if this page doesn't have the expense modal
  if (!itemsWrapper || !addButton) return;

  // Start indexing new items after existing ones
  let itemIndex = itemsWrapper.querySelectorAll(".item-block").length;

  // ========================
  // Base users template
  // ========================

  // Extract user IDs and emails from the first item
  // This acts as the base template for dynamically added items
  const baseUsers = Array.from(
    itemsWrapper.querySelectorAll(
      ".item-block:first-child .form-check"
    )
  ).map(f => ({
    id: f.querySelector("input").value,
    email: f.querySelector("label").innerText
  }));

  // ========================
  // ADD ITEM
  // ========================

  addButton.addEventListener("click", () => {
    // Create a new item container
    const item = document.createElement("div");
    item.className = "item-block border rounded p-2 mb-3";

    // Build checkbox list for users sharing this item
    const usersHtml = baseUsers
      .map(
        u => `
      <div class="form-check">
        <input
          type="checkbox"
          name="items[${itemIndex}][users][]"
          value="${u.id}"
          checked
          class="form-check-input"
        >
        <label class="form-check-label">${u.email}</label>
      </div>
    `
      )
      .join("");

    // Build full item HTML (name, amount, remove button, users)
    item.innerHTML = `
      <div class="d-flex gap-2 mb-2">
        <input
          type="text"
          name="items[${itemIndex}][name]"
          placeholder="Item name"
          class="form-control"
          required
        >
        <input
          type="number"
          name="items[${itemIndex}][amount]"
          placeholder="Amount"
          step="0.01"
          class="form-control"
          required
        >
        <button
          type="button"
          class="btn btn-outline-danger remove-item"
        >
          ✕
        </button>
      </div>
      ${usersHtml}
    `;

    // Append new item to the DOM
    itemsWrapper.appendChild(item);

    // Increment index for the next item
    itemIndex++;
  });

  // ========================
  // REMOVE ITEM
  // ========================

  // Event delegation for dynamically added remove buttons
  itemsWrapper.addEventListener("click", e => {
    if (e.target.classList.contains("remove-item")) {
      // Remove the closest item block
      e.target.closest(".item-block").remove();
    }
  });
});
