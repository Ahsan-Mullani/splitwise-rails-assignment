require "rails_helper"

RSpec.describe ExpenseCreator, type: :service do
  # Test users involved in the expense
  let!(:user)   { User.create!(email: "user@test.com", password: "password") }
  let!(:friend) { User.create!(email: "friend@test.com", password: "password") }

  describe ".call" do
    # Sample items passed to the service
    let(:items) do
      [
        {
          name: "Main Dish",
          amount: 100,
          users: [user.id, friend.id],
          shared: true
        },
        {
          name: "Drink",
          amount: 40,
          users: [user.id],
          shared: false
        }
      ]
    end

    it "creates expense with items, splits, and tax correctly" do
      # Invoke the service
      expense = ExpenseCreator.call(
        description: "Dinner",
        paid_by: user,
        items: items,
        tax: 20
      )

      # ========================
      # Expense assertions
      # ========================

      # Expense record should be persisted
      expect(expense).to be_persisted
      expect(expense.description).to eq("Dinner")

      # Total amount = items (100 + 40) + tax (20)
      expect(expense.total_amount).to eq(160)

      # ========================
      # Expense items assertions
      # ========================

      # Two items should be created
      expect(expense.expense_items.count).to eq(2)

      main_dish = expense.expense_items.find_by(name: "Main Dish")
      drink     = expense.expense_items.find_by(name: "Drink")

      # Shared item should not have an assigned user
      expect(main_dish.assigned_user_id).to be_nil

      # Non-shared item should be assigned to the user
      expect(drink.assigned_user_id).to eq(user.id)

      # ========================
      # Expense splits assertions
      # ========================

      # Index splits by user for easier access
      splits = expense.expense_splits.index_by(&:user_id)

      # Main Dish: 100 / 2 = 50 each
      # Tax: 20 / 2 = 10 each
      # User also paid for Drink: +40
      expect(splits[user.id].amount).to eq(50 + 10 + 40)
      expect(splits[friend.id].amount).to eq(50 + 10)
    end
  end
end
