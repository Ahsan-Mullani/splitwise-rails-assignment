class ExpenseItem < ApplicationRecord
  belongs_to :expense
  belongs_to :assigned_user, class_name: 'User', optional: true
end
