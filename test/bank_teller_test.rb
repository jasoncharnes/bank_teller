require 'test_helper'

class BankTellerTest < Minitest::Test
  def test_currency_is_usd_by_default
    assert BankTeller.uses_currency, 'usd'
  end

  def test_use_currency_changes_currency_with_symbol
    BankTeller.use_currency('eur', '€')
    assert BankTeller.uses_currency, 'eur'
  end

  def test_use_currency_changes_currency_guessing_symbol
    BankTeller.use_currency('gbp')
    assert BankTeller.uses_currency, '£'
  end

  def test_use_currency_symbol_changes_symbol
    BankTeller.use_currency_symbol('?')
    assert BankTeller.uses_currency_symbol, '?'
  end

  def test_format_amount
    BankTeller.use_currency_symbol('$')
    assert BankTeller.format_amount(123331587), '$1233315.87'
  end
end
