require "rails_helper"

RSpec.describe User, type: :model do
  # =========================
  # Associations
  # =========================
  describe "associations" do
    it { should have_many(:paid_expenses).class_name("Expense").with_foreign_key(:paid_by_id) }
    it { should have_many(:expense_splits) }
    it { should have_many(:expenses).through(:expense_splits) }

    it { should have_many(:payments_made).class_name("Settlement").with_foreign_key(:payer_id) }
    it { should have_many(:payments_received).class_name("Settlement").with_foreign_key(:payee_id) }
  end

  # =========================
  # Expense calculations
  # =========================
  describe "expense calculations" do
    let!(:user)   { User.create!(email: "user@test.com", password: "password123") }
    let!(:friend) { User.create!(email: "friend@test.com", password: "password123") }

    let!(:expense) do
      Expense.create!(
        description: "Dinner",
        paid_by: user,
        total_amount: 100
      )
    end

    before do
      ExpenseSplit.create!(expense: expense, user: friend, amount: 50)
      ExpenseSplit.create!(expense: expense, user: user, amount: 50)
    end

    it "calculates raw_amount_owed_to_me" do
      expect(user.raw_amount_owed_to_me).to eq(50)
    end

    it "calculates raw_amount_i_owe" do
      expect(friend.raw_amount_i_owe).to eq(50)
    end
  end

  # =========================
  # Settlement calculations
  # =========================
  describe "settlement calculations" do
    let!(:user)   { User.create!(email: "user@test.com", password: "password123") }
    let!(:friend) { User.create!(email: "friend@test.com", password: "password123") }

    before do
      Settlement.create!(
        payer: friend,
        payee: user,
        amount: 30
      )
    end

    it "calculates total_settled_to_me" do
      expect(user.total_settled_to_me).to eq(30)
    end

    it "calculates total_settled_by_me" do
      expect(friend.total_settled_by_me).to eq(30)
    end
  end

  # =========================
  # Final balances
  # =========================
  describe "final balances" do
    let!(:user)   { User.create!(email: "user@test.com", password: "password123") }
    let!(:friend) { User.create!(email: "friend@test.com", password: "password123") }

    let!(:expense) do
      Expense.create!(
        description: "Lunch",
        paid_by: user,
        total_amount: 80
      )
    end

    before do
      ExpenseSplit.create!(expense: expense, user: friend, amount: 40)
      ExpenseSplit.create!(expense: expense, user: user, amount: 40)

      Settlement.create!(
        payer: friend,
        payee: user,
        amount: 10
      )
    end

    it "calculates amount_owed_to_me after settlements" do
      expect(user.amount_owed_to_me).to eq(30)
    end

    it "calculates balance correctly" do
      expect(user.balance).to eq(30)
    end
  end

  # =========================
  # Friend-wise breakdown
  # =========================
  describe "#friends_i_owe and #friends_who_owe_me" do
    let!(:user)   { User.create!(email: "user@test.com", password: "password123") }
    let!(:friend) { User.create!(email: "friend@test.com", password: "password123") }

    let!(:expense) do
      Expense.create!(
        description: "Shopping",
        paid_by: friend,
        total_amount: 60
      )
    end

    before do
      ExpenseSplit.create!(expense: expense, user: user, amount: 60)
    end

    it "lists friends i owe with amount" do
      result = user.friends_i_owe
      expect(result[friend.id]).to eq(60)
    end

    it "lists friends who owe me correctly" do
      result = friend.friends_who_owe_me
      expect(result[user.id]).to eq(60)
    end
  end

  # =========================
  # Per-friend balance
  # =========================
  describe "#balance_with" do
    let!(:user)   { User.create!(email: "user@test.com", password: "password123") }
    let!(:friend) { User.create!(email: "friend@test.com", password: "password123") }

    let!(:expense) do
      Expense.create!(
        description: "Trip",
        paid_by: friend,
        total_amount: 100
      )
    end

    before do
      ExpenseSplit.create!(expense: expense, user: user, amount: 100)
    end

    it "returns correct per-friend balance hash" do
      balance = user.balance_with(friend)

      expect(balance[:i_owe]).to eq(100)
      expect(balance[:owes_me]).to eq(0)
      expect(balance[:net]).to eq(-100)
    end
  end
end
