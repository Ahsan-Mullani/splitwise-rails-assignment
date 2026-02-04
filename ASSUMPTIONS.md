# Assumptions

This is a simplified Splitwise-style expense sharing app made for the assignment.

I intentionally kept a lot of things simple so the code stays readable and focused on the main logic.

## Users & Auth
- Devise authentication
- Everyone can see all users (no friends or private stuff)
- Email is the unique ID

## Expenses
- Needs payer + description + ≥1 item
- Once created → frozen (no edits/deletes)
- Items are either split equally or 100% to one person
- Tax (optional) split equally among everyone

## Splits
- Calculated when expense is created → saved in ExpenseSplit
- Never recalculated later
- Using BigDecimal, no weird rounding

## Settlements
- One user pays another (can be partial)
- Reduces what’s owed but doesn’t change the expense
- No edit/delete/reverse after creation

## Balances
- No balance column on User
- Always calculated live from splits + settlements
- +ve = people owe you, -ve = you owe people

## Dashboard
- Live numbers
- Only shows people where balance ≠ 0
- "Settle up" button only when you owe money

## Testing
- RSpec for the important logic (balances, splits, settlements)
- Frontend / JS → manual testing

## Not Implemented
- Edit/delete expenses
- Groups
- Multi-currency
- Notifications
- Friends system
- Receipts, feeds, etc.

These trade-offs let me properly implement the core "who owes who" part without the project growing too big.