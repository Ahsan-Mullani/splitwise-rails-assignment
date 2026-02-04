# spec/models/settlement_spec.rb
require "rails_helper"

RSpec.describe Settlement, type: :model do
  describe "associations" do
    # Settlement payer is a User
    it { should belong_to(:payer).class_name("User") }

    # Settlement payee is a User
    it { should belong_to(:payee).class_name("User") }
  end

  describe "validations" do
    # Amount must be a positive number
    it { should validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe "effect on user balances" do
    # Users involved in the settlement
    let!(:user)   { User.create!(email: "user@test.com", password: "password") }
    let!(:friend) { User.create!(email: "friend@test.com", password: "password") }

    # Expense paid by the user
    let!(:expense) do
      Expense.create!(
        description: "Dinner",
        paid_by: user,
        total_amount: 100
      )
    end

    # Friend owes the full amount for this expense
    before do
      ExpenseSplit.create!(
        expense: expense,
        user: friend,
        amount: 100
      )
    end

    it "reduces amount owed after settlement" do
      # Initial state: friend owes the full amount
      expect(friend.amount_i_owe).to eq(100)

      # Friend settles part of the debt
      Settlement.create!(
        payer: friend,
        payee: user,
        amount: 40
      )

      # Remaining balance after settlement
      expect(friend.amount_i_owe).to eq(60)
      expect(user.amount_owed_to_me).to eq(60)
    end
  end
end
