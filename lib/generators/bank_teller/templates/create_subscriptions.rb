class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.string :stripe_id, null: false
      t.string :stripe_plan, null: false
      t.integer :quantity, null: false
      t.string :stripe_plan
      t.datetime :trial_ends_at
      t.datetime :ends_at

      t.timestamps null: false
    end
  end
end
