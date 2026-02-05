# app/services/expense_creator.rb
# Service object to handle creating an expense along with its items and splits
class ExpenseCreator
  # Params:
  #   description: string describing the expense
  #   paid_by: User object who paid the expense
  #   items: array of hashes, each containing :name, :amount, :users
  #   tax: optional tax amount to be added
  def self.call(description:, paid_by:, items:, tax: 0)
    ActiveRecord::Base.transaction do
      # =========================
      # Create main expense record
      # =========================
      expense = Expense.create!(
        description: description,
        paid_by: paid_by,
        tax: tax
      )

      splits = Hash.new(0) # Tracks how much each user owes
      total_amount = 0.to_d # Tracks total expense including tax

      # =========================
      # Process each item in the expense
      # =========================
      items.each do |item|
        amount = item[:amount].to_d
        users  = item[:users].map(&:to_i)

        # Create individual expense item record
        # If only one user, assign it directly; otherwise leave nil for shared
        expense.expense_items.create!(
          name: item[:name],
          amount: amount,
          assigned_user_id: users.size == 1 ? users.first : nil
        )

        total_amount += amount

        # =========================
        # Split logic for this item
        # =========================
        if users.size > 1
          # Shared expense → split equally among selected users
          per_user_amount = amount / users.size
          users.each { |user_id| splits[user_id] += per_user_amount }
        else
          # Personal expense → assign full amount to the single user
          splits[users.first] += amount
        end
      end

      # =========================
      # Split tax across all users
      # =========================
      if tax.to_d.positive?
        tax_split = tax.to_d / splits.keys.size
        splits.each_key { |user_id| splits[user_id] += tax_split }
        total_amount += tax.to_d
      end

      # =========================
      # Create expense splits for each user
      # =========================
      splits.each do |user_id, amount|
        expense.expense_splits.create!(
          user_id: user_id,
          amount: amount
        )
      end

      # Update total amount on expense
      expense.update!(total_amount: total_amount)

      expense
    end
  end
end
