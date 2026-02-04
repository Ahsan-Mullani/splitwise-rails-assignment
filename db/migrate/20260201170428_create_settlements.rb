class CreateSettlements < ActiveRecord::Migration[6.1]
  def change
    create_table :settlements do |t|
      t.references :payer, null: false, foreign_key: { to_table: :users }
      t.references :payee, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :note

      t.timestamps
    end
  end
end
