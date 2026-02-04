class Settlement < ApplicationRecord
  # User who is making the payment
  belongs_to :payer, class_name: "User"

  # User who is receiving the payment
  belongs_to :payee, class_name: "User"

  # Settlement amount must always be a positive value
  validates :amount, numericality: { greater_than: 0 }
end
