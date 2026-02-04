class User < ApplicationRecord
  # Devise authentication modules
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  # =========================
  # Associations
  # =========================

  # Expenses this user paid for
  has_many :paid_expenses,
           class_name: "Expense",
           foreign_key: :paid_by_id,
           dependent: :destroy

  # Expense splits where this user owes a portion
  has_many :expense_splits, dependent: :destroy
  has_many :expenses, through: :expense_splits

  # Settlements made by this user (payments sent)
  has_many :payments_made,
           class_name: "Settlement",
           foreign_key: :payer_id,
           dependent: :destroy

  # Settlements received by this user (payments received)
  has_many :payments_received,
           class_name: "Settlement",
           foreign_key: :payee_id,
           dependent: :destroy

  # =========================
  # Expense-based calculations
  # =========================

  # Total amount others owe this user (before settlements)
  def raw_amount_owed_to_me
    ExpenseSplit
      .joins(:expense)
      .where(expenses: { paid_by_id: id })
      .where.not(user_id: id)
      .sum(:amount)
  end

  # Total amount this user owes others (before settlements)
  def raw_amount_i_owe
    expense_splits
      .joins(:expense)
      .where.not(expenses: { paid_by_id: id })
      .sum(:amount)
  end

  # =========================
  # Settlement calculations
  # =========================

  # Total amount this user has paid to settle debts
  def total_settled_by_me
    payments_made.sum(:amount)
  end

  # Total amount others have paid to this user
  def total_settled_to_me
    payments_received.sum(:amount)
  end

  # =========================
  # Final dashboard numbers
  # =========================

  # Net amount others still owe this user
  def amount_owed_to_me
    raw_amount_owed_to_me - total_settled_to_me
  end

  # Net amount this user still owes others
  def amount_i_owe
    raw_amount_i_owe - total_settled_by_me
  end

  # Overall balance (positive = user is owed money)
  def balance
    amount_owed_to_me - amount_i_owe
  end

  # =========================
  # Friend-wise breakdown
  # =========================

  # Hash of friend_id => amount owed to this user (after settlements)
  def friends_who_owe_me
    # Raw amounts owed per friend
    raw =
      ExpenseSplit
        .joins(:expense)
        .where(expenses: { paid_by_id: id })
        .where.not(user_id: id)
        .group(:user_id)
        .sum(:amount)

    # Amounts already settled by each friend
    settlements =
      payments_received
        .group(:payer_id)
        .sum(:amount)

    # Subtract settlements and keep only positive balances
    raw.each_with_object({}) do |(user_id, amount), result|
      net = amount - settlements.fetch(user_id, 0)
      result[user_id] = net if net > 0
    end
  end

  # Hash of friend_id => amount this user owes (after settlements)
  def friends_i_owe
    # Raw amounts owed per friend
    raw =
      ExpenseSplit
        .joins(:expense)
        .where(user_id: id)
        .where.not(expenses: { paid_by_id: id })
        .group("expenses.paid_by_id")
        .sum(:amount)

    # Amounts already settled by this user
    settlements =
      payments_made
        .group(:payee_id)
        .sum(:amount)

    # Subtract settlements and keep only positive balances
    raw.each_with_object({}) do |(user_id, amount), result|
      net = amount - settlements.fetch(user_id, 0)
      result[user_id] = net if net > 0
    end
  end

  # =========================
  # Per-friend balance
  # =========================

  # Detailed balance breakdown between this user and a specific friend
  def balance_with(friend)
    # Amount friend owes this user (before settlements)
    owes_me =
      ExpenseSplit
        .joins(:expense)
        .where(expenses: { paid_by_id: id }, user_id: friend.id)
        .sum(:amount)

    # Amount this user owes the friend (before settlements)
    i_owe =
      ExpenseSplit
        .joins(:expense)
        .where(expenses: { paid_by_id: friend.id }, user_id: id)
        .sum(:amount)

    # Settlements already paid by the friend
    settled_by_friend =
      payments_received.where(payer_id: friend.id).sum(:amount)

    # Settlements already paid by this user
    settled_by_me =
      payments_made.where(payee_id: friend.id).sum(:amount)

    # Net balance between the two users
    net = (owes_me - settled_by_friend) - (i_owe - settled_by_me)

    {
      owes_me: owes_me - settled_by_friend,
      i_owe: i_owe - settled_by_me,
      net: net
    }
  end
end
