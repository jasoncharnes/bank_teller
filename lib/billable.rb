require 'subscription_builder'
require 'stripe'

module Billable
  def self.included(base)
    base.class_eval do
      has_many :subscriptions
      Stripe.api_key = ENV["STRIPE_API_KEY"]
    end
  end

  def charge(amount, options = {})
    options.merge!({ currency: preferred_currency })
    options[:amount] = amount

    if !options.key?('source') && stripe_id
      options[:customer] = stripe_id
    end

    if !options.key?('source') && !options.key?('customer')
      raise 'No payment source provided.'
    end

    Stripe::Charge.create(options)
  end

  def refund(charge, options = {})
    options[:charge] = charge
    Stripe::Refund.create(options)
  end

  def invoice_for(description, amount, options = {})
    if !stripe_id
      raise 'User is not a customer. See the create_as_stripe_customer method.'
    end

    options.merge!({
      customer: stripe_id,
      amount: amount,
      currency: preferred_currency,
      description: description
    })

    Stripe::InvoiceItem.create(options)
  end

  def new_subscription(subscription, plan, *args)
    SubscriptionBuilder.new(self, subscription, plan, *args)
  end

  def on_trial?(subscription = 'default', plan = nil)
    return true if on_generic_trial?
    subscription = get_subscription(subscription)

    if plan.nil?
      has_subscription_on_trial?(subscription)
    else
      has_subscription_on_trial?(subscription) && stripe_plan === plan
    end
  end

  def has_subscription_on_trial?(subscription)
    subscription && subscription.on_trial
  end

  def on_generic_trial?
    trial_ends_at && DateTime.now < trial_ends_at.to_datetime
  end

  def subscribed?(subscription = 'default', plan = nil)
    subscription = get_subscription(subscription)

    if subscription.nil?
      false
    elsif plan.nil?
      subscription.valid
    else
      subscription.valid && stripe_plan === plan
    end
  end

  def get_subscription(subscription = 'default')
    subscription_in_db = subscriptions.order(created_at: :desc).first
    subscription_in_db if subscription_in_db.name === subscription
  end

  def subscription(name)
    get_subscription(name)
  end

  def invoice
    Stripe::Invoice.create(customer: stripe_id).pay
  rescue
    false
  end

  def upcoming_invoice
    args = { customer: stripe_id }
    stripe_invoice = Stripe::Invoice.upcoming(args)
    Invoice.new(self, stripe_invoice)
  rescue
    false
  end

  def find_invoice(id)
    stripe_invoice = Stripe::Invoice.retrieve(id)
    Invoice.new(self, stripe_invoice)
  rescue
    false
  end

  def find_invoice_or_fail(id)
    invoice = find_invoice(id)
    raise 'Invoice not found' if invoice.nil?
    invoice
  end

  def download_invoice(id, data, storage_path = nil)
    # Add me
  end

  def invoices(include_pending = false, parameters = {})
    invoices = []
    parameters.merge!({ limit: 24 })
    stripe_invoices = as_stripe_customer.invoices(parameters)

    unless stripe_invoices.nil?
      stripe_invoices.data.each do |invoice|
        if invoice.paid || include_pending
          invoices << Invoice.new(self, invoice)
        end
      end
    end

    invoices
  end

  def invoices_including_pending(parameters = [])
    invoices(true, parameters)
  end

  def update_card(token)
    customer = as_stripe_customer
    token = Stripe::Token.retrieve(token)
    return if token.card.id === customer.default_source

    card = customer.sources.create(source: token)
    customer.default_source = card.id
    customer.save

    if customer.default_source
      source = customer.sources.retrieve(customer.default_source)
    end

    if source
      self.card_brand = source.brand
      self.card_last_four = source.last4
    end

    self.save
  end

  def apply_coupon(coupon)
    customer = as_stripe_customer
    customer.coupon = coupon
    customer.save
  end

  def subscribed_to_plan?(subscription = 'default', plan)
    subscription = get_subscription(subscription)
    return false unless subscription || subscription.valid
    subscription.stripe_plan === plan
  end

  def on_plan(plan)
    subscription = subscriptions.first
    subscription.stripe_plan === plan && subscription.valid
  end

  def has_stripe_id
    !!stripe_id
  end

  def create_as_stripe_customer(token, options = {})
    options.merge!({ email: email })
    customer = Stripe::Customer.create(options)
    self.stripe_id = customer.id
    self.save
    update_card(token) unless token.nil?
    customer
  end

  def as_stripe_customer
    Stripe::Customer.retrieve(stripe_id)
  end

  def preferred_currency
    BankTeller::uses_currency
  end

  def tax_percentage
    0
  end
end
