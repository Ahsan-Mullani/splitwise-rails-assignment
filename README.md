# Rails Assignment - Splitwise

## Setup
- Clone the repository in your local machine.
- Run `rails db:setup`, this will also seed data in the `User` model
- Run `rails s` to start the server and `rails c` for rails console

## Requirements

- Ruby - 3.0.0
- Rails - 6.1.4
- Git (configured with your Github account)
- Node - 12.13.1


## Things available in the repo
- Webpacker configured and following packages are added and working.
  - Jquery
  - Bootstrap
  - Jgrowl
- Devise installed and `User` model is added. Sign in and Sign up pages have been setup.
- Routes and layouts for following page have been added.
  - Dashboard - This will be the root page.
  - Friend page - `/people/:id`


## Submission
- Make the improvements as specified in your technical assignment task.
- Commit all changes to the single PR.
- Deploy your app to Heroku or any other platform.
- Send us the link of the dpeloyed application and your PR.


## Contact us
If you need any help regarding this assignment or want to join [Commutatus](https://www.commutatus.com/), drop us an email at work@commutatus.com


## Implementation Notes

These are the key features actually built for this assignment:

- **Expense creation with item-level splitting**
  - Each item can be split **equally** among selected participants
  - Or assigned **fully** to a single user
  - Optional **tax** is always split equally among all participants in the expense

- **Dynamic balance calculation** (Splitwise-style)
  - No `balance` field stored on the `User` model
  - Balances are computed live from all expense splits + settlements
  - Shows per-friend breakdown of who owes what

- **Settlement functionality**
  - Users can record payments to each other
  - Supports **partial settlements**
  - Payments reduce outstanding amounts but never modify or re-open past expenses

- **Testing**
  - RSpec test suite covering:
    - User balance calculations
    - Expense creation & splitting logic (via service object)
    - Settlement application and balance impact

For detailed assumptions, simplifications, and out-of-scope features, see [`ASSUMPTIONS.md`]

This keeps the focus on the core expense-sharing and settlement mechanics while staying manageable for the assignment scope.