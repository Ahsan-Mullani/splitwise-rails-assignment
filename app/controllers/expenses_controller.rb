class ExpensesController < ApplicationController
  def create
    # Determine who paid for the expense
    # Support friend_id from modal, fallback to paid_by_id, then current_user
    paid_by = User.find(params[:friend_id] || params[:paid_by_id] || current_user.id)

    # Tax is optional; default to 0 if not present
    tax = params[:tax] || 0

    # Ensure at least one item is provided before proceeding
    return redirect_back(
      fallback_location: root_path,
      alert: "Please add at least one item"
    ) if params[:items].blank?

    # ========================
    # Process expense items
    # ========================

    # Convert items hash into a safe, structured array
    items = params[:items].values.map do |item|
      # Users selected for this item (who share the cost)
      selected_users = item[:users] || []

      # If no users are selected, assign the cost to the payer
      selected_users = [paid_by.id] if selected_users.empty?

      {
        name: item[:name],
        amount: item[:amount].to_f,
        users: selected_users.map(&:to_i)
      }
    end

    # ========================
    # Create expense
    # ========================

    # Delegate expense creation logic to service object
    ExpenseCreator.call(
      description: params[:description],
      paid_by: paid_by,
      items: items,
      tax: tax.to_f
    )

    # Redirect back with success message
    redirect_back(
      fallback_location: root_path,
      notice: "Expense added successfully"
    )
  end

  def settle_up
    # Friend with whom the current user is settling balances
    friend = User.find(params[:friend_id])

    # Wrap deletions in a transaction to ensure atomicity
    ActiveRecord::Base.transaction do
      # Remove splits where current user owes the friend
      ExpenseSplit
        .joins(:expense)
        .where(
          user_id: current_user.id,
          expenses: { paid_by_id: friend.id }
        )
        .delete_all

      # Remove splits where friend owes the current user
      ExpenseSplit
        .joins(:expense)
        .where(
          user_id: friend.id,
          expenses: { paid_by_id: current_user.id }
        )
        .delete_all
    end

    # Redirect back with confirmation
    redirect_back(
      fallback_location: root_path,
      notice: "Settled up successfully"
    )
  end
end
