class CreateTimeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :time_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.time :time
      t.string :entry_type
      t.string :status
      t.text :observation
      t.boolean :signature

      t.timestamps
    end

    add_index :time_entries, [:user_id, :date]
    add_index :time_entries, :date
  end
end
