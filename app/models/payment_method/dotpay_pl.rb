class PaymentMethod::DotpayPl < PaymentMethod

  preference :account_id, :string
  preference :pin, :string
  preference :url, :string, :default => "https://ssl.dotpay.pl/"
  preference :type, :string, :default => "3"
  preference :currency, :string, :default => "PLN"
  preference :language, :string, :default => "pl"
  preference :dotpay_server_1, :string, :default => "217.17.41.5"
  preference :dotpay_server_2, :string, :default => "195.150.9.37"

  def payment_profiles_supported?
    false
  end

end
