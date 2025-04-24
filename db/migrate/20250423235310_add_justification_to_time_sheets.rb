class AddJustificationToTimeSheets < ActiveRecord::Migration[8.0]
  def change
    add_column :time_sheets, :justification, :text
    add_column :time_sheets, :justification_status, :string
    add_index :time_sheets, :justification_status
  end
end