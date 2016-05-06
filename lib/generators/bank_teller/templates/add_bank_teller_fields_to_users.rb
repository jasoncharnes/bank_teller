class AddBankTellerFieldsToUsers < ActiveRecord::Migration
  def self.up
    unless column_exists? :users, :email
      add_column :users, :email, :string
    end

    unless column_exists? :users, :stripe_id
      add_column :users, :stripe_id, :string
    end

    unless column_exists? :users, :card_brand
      add_column :users, :card_brand, :string
    end

    unless column_exists? :users, :card_last_four
      add_column :users, :card_last_four, :string
    end

    unless column_exists? :users, :trial_ends_at
      add_column :users, :trial_ends_at, :datetime
    end
  end

  def self.down
    remove_column :users, :stripe_id, :string
    remove_column :users, :card_brand, :string
    remove_column :users, :card_last_four, :string
    remove_column :users, :trial_ends_at, :datetime
  end
end
