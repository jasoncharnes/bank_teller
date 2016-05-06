require 'test_helper'
require 'active_support/all'
require 'subscription_builder'

class SubsciptionBuilderTest < MiniTest::Test
  def setup
    Stripe.api_key = ENV["STRIPE_API_KEY"]
    @stripe_helper = StripeMock.create_test_helper
    StripeMock.start

    @customer = Stripe::Customer.create({
      email: 'johnny@appleseed.com',
      card: @stripe_helper.generate_card_token
    })

    @user = Struct.new(:user)
    @name = 'main'
    @plan = 'monthly'
    @subscription = SubscriptionBuilder.new(@user, @name, @plan)
  end

  def teardown
    StripeMock.stop
  end

  def test_initialized_with_arguments
    assert_equal @subscription.user, @user
    assert_equal @subscription.name, @name
    assert_equal @subscription.plan, @plan
  end

  def test_initialized_with_extra_arguments
    args = {
      trial_days: 10,
      quantity: 2,
      skip_trial: false,
      coupon: 'code',
      metadata: 'blah'
    }
    subscription = SubscriptionBuilder.new(@user, @name, @plan, args)
    assert_equal subscription.trial_days, args[:trial_days]
    assert_equal subscription.quantity, args[:quantity]
    assert_equal subscription.skip_trial, args[:skip_trial]
    assert_equal subscription.coupon, args[:coupon]
    assert_equal subscription.metadata, args[:metadata]
  end

  def test_creating_a_subscription_with_a_new_customer
    @stripe_helper.create_plan(:id => 'monthly', :amount => 1500)

    @user = Struct::User.new(@customer.id)
    subscription = SubscriptionBuilder.new(@user, @name, @plan, skip_trial: true)
    created_subscription = subscription.create[0]

    assert_equal created_subscription[:name], @name
    assert_equal created_subscription[:stripe_plan], @plan
    assert_equal created_subscription[:quantity], 1
    assert_nil created_subscription[:trial_ends_at]
    refute_nil created_subscription[:stripe_id]
  end

  def test_creating_a_subscription_by_calling_add
    @stripe_helper.create_plan(:id => 'monthly', :amount => 1500)

    @user = Struct::User.new(@customer.id)
    subscription = SubscriptionBuilder.new(@user, @name, @plan, skip_trial: true)
    created_subscription = subscription.add[0]

    assert_equal created_subscription[:name], @name
    assert_equal created_subscription[:stripe_plan], @plan
    assert_equal created_subscription[:quantity], 1
    assert_nil created_subscription[:trial_ends_at]
    refute_nil created_subscription[:stripe_id]
  end
end
