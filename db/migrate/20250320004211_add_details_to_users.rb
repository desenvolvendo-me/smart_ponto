class AddDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :employee_id, :string
    add_column :users, :position, :string
    add_column :users, :start_date, :date
    add_column :users, :status, :string
  end
end
