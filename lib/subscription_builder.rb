class SubscriptionBuilder
  def initialize(user, name, plan, *args)
    @user = user
    @name = name
    @plan = plan
    @trial_days = args[0][:trial_days] || 0
    @quantity = args[0][:quantity] || 1
    @skip_trial = args[0][:skip_trial] || false
    @coupon = args[0][:coupon]
    @metadata = args[0][:metadata]
  end

  def add(options = {})
    create(nil, options)
  end

  def create(token = nil, options = {})
    customer = get_stripe_customer(token, options)
    stripe_subscription = customer.subscriptions.create(pay_load)

    if skip_trial
      trial_ends_at = nil
    else
      trial_ends_at = trial_days ? trial_days.days.from_now.to_time.to_i : nil
    end

    user.subscriptions.create do |subscription|
      subscription.name = name
      subscription.stripe_id = stripe_subscription.id
      subscription.stripe_plan = plan
      subscription.quantity = quantity
      subscription.trial_ends_at = trial_ends_at
      ends_at = nil
    end
  end

  protected

  attr_accessor :user
  attr_accessor :name
  attr_accessor :plan
  attr_accessor :quantity
  attr_accessor :trial_days
  attr_accessor :skip_trial
  attr_accessor :coupon
  attr_accessor :metadata

  def get_stripe_customer(token = nil, options = {})
    if !user.stripe_id.nil?
      customer = user.as_stripe_customer
      user.update_card(token) if token
    else
      options = options.merge!({ coupon: coupon })
      customer = user.create_as_stripe_customer(token, options)
    end
    customer
  end

  def pay_load
    {
      plan: plan,
      quantity: quantity,
      trial_end: get_trial_end_for_pay_load,
      tax_percent: get_tax_percent_for_pay_load,
      metadata: metadata
    }
  end

  def get_trial_end_for_pay_load
    if skip_trial
      'now'
    else
      trial_days.days.from_now.to_time.to_i if trial_days
    end
  end

  def get_tax_percent_for_pay_load
    user.try(:tax_percentage)
  end
end
