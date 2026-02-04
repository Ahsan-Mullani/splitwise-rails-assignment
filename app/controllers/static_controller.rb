class StaticController < ApplicationController
  # Ensure user is logged in before accessing any action in this controller
  before_action :authenticate_user!

  def dashboard
    # Current logged-in user
    @user = current_user

    # All users except the current user (used as friends list)
    @friends = User.where.not(id: @user.id)

    # ========================
    # Aggregate totals
    # ========================

    # Net balance for the user
    @total_balance = @user.balance

    # Amount the user owes to others
    @total_i_owe = @user.amount_i_owe

    # Amount others owe to the user
    @total_owed_to_me = @user.amount_owed_to_me

    # ========================
    # Per-friend breakdown
    # ========================

    # Hash of friend_id => amount the user owes
    @friends_i_owe = @user.friends_i_owe

    # Hash of friend_id => amount owed to the user
    @friends_who_owe_me = @user.friends_who_owe_me

    # ========================
    # Preload friend records
    # ========================

    # Load User records for friends the user owes money to
    @friends_i_owe_objects = User.where(id: @friends_i_owe.keys)

    # Load User records for friends who owe the user money
    @friends_who_owe_me_objects = User.where(id: @friends_who_owe_me.keys)

    # ========================
    # Fast lookup hashes
    # ========================

    # Create hash lookup (user_id => User object) for quick access in views
    @friends_i_owe_lookup = @friends_i_owe_objects.index_by(&:id)
    @friends_who_owe_me_lookup = @friends_who_owe_me_objects.index_by(&:id)
  end

  def person
    # Load the selected friend along with related expenses to avoid N+1 queries
    @friend = User
              .includes(:paid_expenses, :expense_splits)
              .find(params[:id])

    # Load other users for sidebar or navigation (excluding current user)
    @other_users = User.where.not(id: current_user.id)

    # Fetch balance details between current user and this friend
    # Fallback ensures safe access if no balance data exists
    balance_hash = current_user.balance_with(@friend)
    @friend_balance_with_current_user =
      balance_hash || { i_owe: 0, owes_me: 0, net: 0 }

    # Load all expenses paid by this friend
    # Includes expense splits and users to prevent N+1 queries in views
    @expenses_paid_by_friend =
      Expense.where(paid_by: @friend)
             .includes(expense_splits: :user)
  end
end
