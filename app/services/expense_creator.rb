class ExpenseCreator
  # Service entry point for creating an expense with items, splits, and tax
  def self.call(description:, paid_by:, items:, tax: 0)
    # Wrap everything in a transaction to ensure data consistency
    ActiveRecord::Base.transaction do
      # Create the main expense record
      expense = Expense.create!(
        description: description,
        paid_by: paid_by,
        tax: tax
      )

      # Hash to accumulate how much each user owes
      splits = Hash.new(0)

      # Track total amount for the expense (including tax later)
      total_amount = 0.to_d

      # ========================
      # Process expense items
      # ========================

      items.each do |item|
        amount = item[:amount].to_d
        users  = item[:users]

        # Create expense item record
        # If the item is shared, assigned_user_id is nil
        # Otherwise, it is assigned to the first user
        expense.expense_items.create!(
          name: item[:name],
          amount: amount,
          assigned_user_id: item[:shared] ? nil : users.first
        )

        # Add item amount to total
        total_amount += amount

        if item[:shared]
          # Split amount evenly among all selected users
          per_user = amount / users.count
          users.each { |u| splits[u] += per_user }
        else
          # Assign full amount to a single user
          splits[users.first] += amount
        end
      end

      # ========================
      # Handle tax distribution
      # ========================

      if tax.to_d.positive?
        # Distribute tax evenly across all users involved
        tax_split = tax.to_d / splits.keys.count
        splits.each_key { |u| splits[u] += tax_split }

        # Add tax to total expense amount
        total_amount += tax.to_d
      end

      # ========================
      # Create expense splits
      # ========================

      splits.each do |user_id, amount|
        expense.expense_splits.create!(
          user_id: user_id,
          amount: amount
        )
      end

      # Update total amount on the expense
      expense.update!(total_amount: total_amount)

      # Return the created expense
      expense
    end
  end
end
