class SettlementsController < ApplicationController
  # Ensure only logged-in users can create settlements
  before_action :authenticate_user!

  # POST /settlements
  def create
    payer = current_user
    payee = User.find(params[:payee_id])

    # Calculate current balance between payer and payee
    balance = payer.balance_with(payee)

    # Amount the payer owes to the payee
    amount = balance[:i_owe].to_d

    # Guard clause: nothing to settle
    if amount <= 0
      redirect_back fallback_location: root_path,
                    alert: "Nothing to settle with this user"
      return
    end

    # Create the settlement record
    Settlement.create!(
      payer: payer,
      payee: payee,
      amount: amount,
      note: params[:note]
    )

    # Redirect back with confirmation
    redirect_back fallback_location: root_path,
                  notice: "Settled ₹#{amount} successfully"
  end
end
