class AddSignatureToTimeSheets < ActiveRecord::Migration[8.0]
  def change
    add_column :time_sheets, :signature, :boolean
  end
end
