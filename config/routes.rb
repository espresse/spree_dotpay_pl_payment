Rails.application.routes.draw do
  # Add your extension routes here
  namespace :gateway do
    match '/dotpay_pl/:gateway_id/:order_id' => 'dotpay_pl#show', :as => :dotpay_pl
    match '/dotpay_pl/comeback/' => 'dotpay_pl#comeback', :as => :dotpay_pl_comeback
    match '/dotpay_pl/complete' => 'dotpay_pl#complete', :as => :dotpay_pl_complete
  end
end
