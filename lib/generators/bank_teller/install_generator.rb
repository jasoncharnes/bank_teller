require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module BankTeller
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration

    desc "Install the migrations needed for Bank Teller."
    class_option :provider, type: :string, default: :stripe
    source_root File.expand_path('../templates', __FILE__)

    def self.next_migration_number(dir)
      sleep 1 # Prevents Duplicate Timestamps on FAAAAST Machines
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end

    def alter_users
      if ActiveRecord::Base.connection.table_exists?('users')
        migration_template "add_bank_teller_fields_to_users.rb", "db/migrate/add_bank_teller_fields_to_users.rb"
      else
        raise "You must have a users table to install Bank Teller."
      end
    end

    def create_subscriptions
      migration_template "create_subscriptions.rb", "db/migrate/create_subscriptions.rb"
    end
  end
end
