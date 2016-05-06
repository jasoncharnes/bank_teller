class Invoice
  def initialize(user, invoice)
    @user = user
    @invoice = invoice
  end

  def date(timezone = nil)
    invoice.to_time.in_time_zone(timezone).to_date
  end

  def total
    format_amount(raw_total)
  end

  def raw_total
    amount = invoice.total - (raw_starting_balance * -1)
    [0, amount].max
  end

  def subtotal
    amount = invoice.subtotal - raw_starting_balance
    amount = [0, amount].max
    format_amount(amount)
  end

  def has_starting_balance?
    raw_starting_balance > 0
  end

  def starting_balance
    format_amount(raw_starting_balance)
  end

  def has_discount
    invoice.subtotal > 0 and
      invoice.subtotal != invoice.total and
        !invoice.discount.nil?
  end

  def discount
    amount = invoice.subtotal - invoice.total
    format_amount(amount)
  end

  def coupon
    invoice.discount.coupon.id if invoice.discount
  end

  def discount_is_percentage?
    coupon and invoice.discount.coupon.percent_off
  end

  def percent_off
    if coupon
      invoice.discount.coupon.percent_off
    else
      0
    end
  end

  def amount_off
    amount = invoice.discount.coupon.amount_off || 0
    format_amount(amount)
  end

  def invoice_items
    invoice_items_by_type('invoiceitem')
  end

  def subscriptions
    invoice_items_by_type('subscription')
  end

  def invoice_items_by_type(type)
    line_items = []

    if lines.data
      lines.data.each do |line|
        if line.type == type
          line_items << InvoiceItem.new(user, line)
        end
      end
    end

    line_items
  end

  def format_amount(amount)
    BankTeller::format_amount(amount)
  end

  def view(data)
    # Coming Soon
  end

  def pdf(data)
    # Coming Soon
  end

  def download(data)
    # Coming Soon
  end

  def raw_starting_balance
    invoice.starting_balance || 0
  end

  def as_stripe_invoice
    invoice
  end

  protected

  attr_accessor :user, :invoice
end
