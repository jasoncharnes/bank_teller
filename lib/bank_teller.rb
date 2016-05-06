require "bank_teller/version"
require 'bank_teller/engine' if defined?(Rails)

module BankTeller
  protected

  # The current currency.
  #
  # @return [String]
  @@currency = 'usd'

  # The current currency symbol.
  #
  # @return [String]
  @@currency_symbol = '$'

  # The custom currency formatter.
  #
  # @return [Lambda]
  @@format_currency_using = nil

  # Set the currency to be used when billing users.
  #
  # @param currency [Integer]
  # @param symbol [String]
  # @return [Boolean]
  def self.use_currency(currency, symbol = nil)
    @@currency = currency
    symbol = self.guess_currency_symbol(currency) if symbol.nil?
    self.use_currency_symbol(symbol)
  end

  def self.guess_currency_symbol(currency)
    case currency.downcase
    when 'usd', 'cad', 'aud'
      '$'
    when 'eur'
      '€'
    when 'gbp'
      '£'
    else
      raise 'You must explicitly specify the currency symbol.'
    end
  end

  def self.use_currency_symbol(symbol)
    @@currency_symbol = symbol
  end

  def self.uses_currency
    @@currency
  end

  def self.uses_currency_symbol
    @@currency_symbol
  end

  def self.formatCurrencyUsing(callback)
    @@format_currency_using = callback
  end

  def self.format_amount(amount)
    self.format_currency_using(amount) if @@format_currency_using
    amount = sprintf("%03d", amount).insert(-3, ".")

    if amount.start_with?('-')
      return "-#{self.uses_currency_symbol}#{amount.sub!(/^-/, '')}"
    end

    "#{uses_currency_symbol}#{amount}"
  end
end
