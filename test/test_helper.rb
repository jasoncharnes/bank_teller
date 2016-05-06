require 'minitest/autorun'
require 'minitest/pride'
require 'stripe_mock'
require 'dotenv'
Dotenv.load

Struct.new("Subscription") do
  def create(*args)
    args
  end
end

Struct.new("User", :stripe_id) do
  def as_stripe_customer
    Stripe::Customer.retrieve(stripe_id)
  end

  def subscriptions
    Struct::Subscription.new
  end
end

require 'bank_teller'
