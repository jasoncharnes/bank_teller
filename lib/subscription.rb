class Subscription < ActiveRecord::Base
  belongs_to :user

  def valid
    active? || on_trial? || on_grace_period?
  end

  def active?
    ends_at.nil? || on_grace_period?
  end

  def cancelled?
    !ends_at.nil?
  end

  def on_trial?
    if trial_ends_at.nil?
      false
    else
      DateTime.now < trial_ends_at.to_datetime
    end
  end

  def on_grace_period?
    if ends_at.nil?
      return false
    else
      DateTime.now < ends_at.to_datetime
    end
  end

  def increment_quantity(count = 1)
    update_quantity(quantity + count)
    self
  end

  def increment_and_invoice(count = 1)
    increment_quantity(count)
    user.invoice
    self
  end

  def decrement_quantity(count = 1)
    quantity = [1, (self.quantity - count)].max
    update_quantity(quantity)
    self
  end

  def update_quantity(quantity, customer = nil)
    subscription = stripe_subscription
    subscription.quantity = quantity
    subscription.save
    self.quantity = quantity
    self.save
    self
  end

  def no_prorate
    prorate = false
    self
  end

  def anchor_billing_cycle_on(date = 'now')
    billing_cycle_anchor = date
    self
  end

  def swap(plan, *args)
    subscription = stripe_subscription
    subscription.plan = plan
    subscription.prorate = false
    additional_options = args[0]

    if additional_options
      subscription.prorate = additional_options[:prorate] || false

      if anchor = additional_options[:billing_cycle_anchor]
        subscription.billing_cycle_anchor = anchor
      end
    end

    if on_trial?
      subscription.trial_end = trial_ends_at.to_time
    else
      subscription.trial_end = 'now'
    end

    if quantity
      subscription.quantity = quantity
    end

    subscription.save
    user.invoice

    self.stripe_plan = plan
    self.ends_at = nil
    self.save
    self
  end

  def cancel
    subscription = stripe_subscription
    subscription.delete(at_period_end: true)

    if on_trial?
      self.ends_at = trial_ends_at
    else
      self.ends_at = current_period_end.to_time
    end

    self.save
    self
  end

  def cancel_now
    subscription = stripe_subscription
    subscription.delete
    mark_as_cancelled
    self
  end

  def mark_as_cancelled
    self.ends_at = DateTime.now
    self.save
  end

  def stripe_subscription
    user.as_stripe_customer.subscriptions.retrieve(stripe_id)
  end
end
