class CreateTimeSheets < ActiveRecord::Migration[8.0]
  def change
    create_table :time_sheets do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.string :status
      t.decimal :total_hours
      t.string :approval_status
      t.integer :approved_by
      t.datetime :approved_at

      t.timestamps
    end

    add_index :time_sheets, [:user_id, :date], unique: true
    add_index :time_sheets, :date
  end
end
