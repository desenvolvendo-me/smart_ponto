class CreateJustificationComments < ActiveRecord::Migration[8.0]
  def change
    create_table :justification_comments do |t|
      t.references :time_sheet, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent_comment, null: true, foreign_key: { to_table: :justification_comments }
      t.text :content, null: false
      t.integer :level, default: 1, null: false
      t.timestamps
    end

    add_index :justification_comments, [:time_sheet_id, :level]
  end
end
