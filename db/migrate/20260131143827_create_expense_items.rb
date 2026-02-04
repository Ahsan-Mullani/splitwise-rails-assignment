class CreateExpenseItems < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_items do |t|
      t.references :expense, null: false, foreign_key: true
      t.string :name
      t.decimal :amount
      t.references :assigned_user, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
