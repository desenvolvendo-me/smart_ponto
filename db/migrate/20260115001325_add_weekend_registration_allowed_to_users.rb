class AddWeekendRegistrationAllowedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :weekend_registration_allowed, :boolean, default: false, null: false
    add_index :users, :weekend_registration_allowed
  end
end
