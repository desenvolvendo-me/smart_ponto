class AddIndicesForPerformance < ActiveRecord::Migration[8.0]
  def change
    add_index :time_entries, :status
    add_index :time_sheets, :approval_status
    add_index :time_sheets, :approved_by
    add_index :time_sheets, :status
  end
end
