class Expense < ApplicationRecord
  belongs_to :paid_by, class_name: 'User'

  has_many :expense_items, dependent: :destroy
  has_many :expense_splits, dependent: :destroy
end
