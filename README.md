# Bank Teller
[![Gem Version](https://badge.fury.io/rb/bank_teller.svg)](https://badge.fury.io/rb/bank_teller)
[![Build Status](https://travis-ci.org/jasoncharnes/bank_teller.svg?branch=master)](https://travis-ci.org/jasoncharnes/bank_teller)
[![Code Climate](https://codeclimate.com/github/jasoncharnes/bank_teller/badges/gpa.svg)](https://codeclimate.com/github/jasoncharnes/bank_teller)

Bank Teller is a Ruby on Rails interface for interacting with Stripe. It is an implementation of the Laravel library, [Cashier](http://github.com/laravel/cashier). Major kudos to Taylor Otwell and all of the contributors to Cashier, it's amazing. Bank Teller has some minor API differences from Cashier, mostly to match the Ruby style. To quote the Cashier project: "It handles almost all of the boilerplate subscription billing code you are dreading writing... coupons, swapping subscription, subscription 'quantities', cancellation grace periods, and <strike>invoice PDFs</strike> (coming soon)."

This gem cannot be used as a stand-alone gem. It is very tightly integrated with ActiveSupport and ActiveRecord. This gem is best used in a Ruby on Rails application.

## Still to Come
### Contribute, if you'd like!
- Finish Tests
- Add Webhooks
- Invoice PDFs
- One Off Charges

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bank_teller'
```

And then execute:

    $ bundle

Bank Teller comes with a couple of migrations:
  1. A migration to add fields to a `users` table. A `users` should already exist.
  2. A migration to create a `subscriptions` table.

To add these migrations to your application, run:

    $ rails generate bank_teller:install
    $ rake db:migrate

## Usage
### Setting It Up
Stripe requires a private API key. Once you have aquired your private key, you'll need to set the environment variable `ENV["STRIPE_API_KEY"]` equal to your API key. If you're not sure how to use environment variables, checkout [Figaro](https://github.com/laserlemon/figaro) or my favorite, [dotenv](https://github.com/bkeepers/dotenv).

Once you have your key in place, all you need to do is include the `Billable` module in your `User` class:

```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  include Billable
end
```

### Make Some Money
#### Create a Subscription
```ruby
user = User.find(1)
user.new_subscription('main', 'monthly').create(token)
```

`#new_subscription` is a method call on a `User` object that takes two arguments:
  1. The name of the plan, for internal use
  2. The ID of the plan you created with Stripe

`#create` takes one argument, the stripe credit card token. It sends the subscription to Stripe and creates the subscription record in the databse.

You can also send addtional fields for the user when creating a new subscription.

```ruby
user.new_subscription('main', 'monthly').create(token, { email: 'john@johndoe.com' })
```

To see all the options, [checkout the Stripe docs](https://stripe.com/docs/api#create_customer).

##### Coupons!
```ruby
user.new_subscription('main', 'monthly', coupon: 'code').create(token)
```

<hr>

#### Subscription Status
##### Active(ness)
See if a user has an active subscription:
```ruby
user.subscribed?('main')
```

See if a user's subscription is still on a trial:
```ruby
user.subscription('main').on_trial?
```

See if a user is subscribed to a specific plan:
```ruby
user.subscribed_to_plan?('main', 'monthly')
```

##### Cancellations
See if a user has cancelled their subscription:
```ruby
user.subscription('main').cancelled?
```

See if a user has cancelled their subscription, but still has a grace period:
```ruby
user.subscription('main').on_grace_period?
```

#### Switch Plans
Swap between different Stripe plans:
```ruby
user.subscription('main').swap('another-stripe-plan-id')
```

#### Quantity
Add 1 to the quantity of plans:
```ruby
user.subscription('main').increment_quantity
```

Add n to the quantity of plans:
```ruby
user.subscription('main').increment_quantity(10)
```

Remove 1 from the quantity of plans:
```ruby
user.subscription('main').decrement_quantity
```

Remove n from the quantity of plans:
```ruby
user.subscription('main').decrement_quantity(10)
```

Directly update the quantity of plans:
```ruby
user.subscription('main').update_quantity(20)
```

#### Taxes
To charge tax for your plans, overwrite the `tax_percentage` method in your `User` class:
```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  def tax_percentage
    9.25
  end
end
```

#### Cancel Subscriptions
Cancel a subscription with a grace period (time remaining in the active plan):
```ruby
user.subscription('main').cancel
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jasoncharnes/bank_teller.

