class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.string :description
      t.references :paid_by, null: false, foreign_key: { to_table: :users }
      t.decimal :total_amount
      t.decimal :tax

      t.timestamps
    end
  end
end
