class SubscriptionBuilder
  attr_accessor :user, :name, :plan
  attr_accessor :quantity, :coupon, :metadata
  attr_accessor :trial_days, :skip_trial

  def initialize(user, name, plan, *args)
    @user = user
    @name = name
    @plan = plan
    if args[0]
      set_instance_vars_for_args(args[0])
    else
      @trial_days = 0
      @quantity = 1
      @skip_trial = false
    end
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

    user.subscriptions.create(
      name: name,
      stripe_id: stripe_subscription.id,
      stripe_plan: plan,
      quantity: quantity,
      trial_ends_at: trial_ends_at
    )
  end

  protected

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

  def set_instance_vars_for_args(args)
    @trial_days   = args[:trial_days] || 0
    @quantity     = args[:quantity] || 1
    @skip_trial   = args[:skip_trial] || false
    @coupon       = args[:coupon]
    @metadata     = args[:metadata]
  end
end
