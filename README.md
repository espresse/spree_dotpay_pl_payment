SpreeDotpayPlPayment
====================

Dotpay.pl payment system for Spree.

Works with Rails 3.1 and Spree 1.0

Install
=======

Add to your Gemfile:

    gem 'spree_dotpay_pl_payment', :git => 'git://github.com/espresse/spree_dotpay_pl_payment.git'

and run

    bundle install

Dotpay.pl Settings
========

You'll have to set a callback URL in your Dotpay account. Assuming that the address of your shop website is
http://shop.example.com your callback then should be:

    http://shop.example.com/gateway/dotpay_pl/comeback


This work based on https://github.com/pronix/spree-ebsin.

