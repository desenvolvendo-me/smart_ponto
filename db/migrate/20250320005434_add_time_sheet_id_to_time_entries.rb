class AddTimeSheetIdToTimeEntries < ActiveRecord::Migration[8.0]
  def change
    add_reference :time_entries, :time_sheet, null: false, foreign_key: true
  end
end
