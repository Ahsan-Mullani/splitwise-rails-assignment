class ExpenseSplit < ApplicationRecord
  belongs_to :expense
  belongs_to :user
end
