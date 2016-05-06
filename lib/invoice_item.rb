class InvoiceItem
  def initialize(user, item)
    @user = user
    @item = item
  end

  def total
    format_amount(amount)
  end

  def start_date
    if is_subscription?
      item.period.start
    end
  end

  def end_date
    if is_subscription?
      item.period.end
    end
  end

  def is_subscription?
    item.type === 'subscription'
  end

  def as_stripe_invoice_item
    item
  end

  protected

  attr_accessor :user, :item

  def format_amount(amount)
    BankTeller::format_amount(amount)
  end
end
