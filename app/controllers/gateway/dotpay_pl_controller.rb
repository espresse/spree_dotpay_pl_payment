require 'digest/md5'

class Gateway::DotpayPlController < Spree::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:comeback, :complete]
  
  # Show form Dotpay for pay
  def show
    @order = Order.find(params[:order_id])
    @gateway = @order.available_payment_methods.find{|x| x.id == params[:gateway_id].to_i }
    @order.payments.destroy_all
    payment = @order.payments.create!(:amount => 0, :payment_method_id => @gateway.id)

    if @order.blank? || @gateway.blank?
      flash[:error] = I18n.t("invalid_arguments")
      redirect_to :back
    else
      @bill_address, @ship_address = @order.bill_address, (@order.ship_address || @order.bill_address)
    end
  end
  
  # redirecting from dotpay.pl
  def complete    
    @order = Order.find_by_number(params[:format])
    session[:order_id]=nil
    if @order.state=="complete"
      redirect_to order_url(@order, {:checkout_complete => true, :order_token => @order.token}), :notice => I18n.t("payment_success")
    else
      redirect_to order_url(@order)
    end
  end

  # Result from Dotpay
  def comeback
    @order = Order.find_by_number(params[:control])
    @gateway = @order && @order.payments.first.payment_method

    if dotpay_pl_validate(@gateway, params, request.remote_ip)
      if params[:t_status]=="2" # dotpay state for payment confirmed
        dotpay_pl_payment_success(params)
      elsif params[:t_status] == "4" or params[:t_status] == "5" #dotpay states for cancellation and so on
        dotpay_pl_payment_cancel(params)
      elsif params[:t_status] == "1"  #dotpay state for starting payment processing (1)
        dotpay_pl_payment_new(params) 
      end
      render :text => "OK"
    else
      render :text => "Not valid"
    end    
  end


  private

  # validating dotpay message
  def dotpay_pl_validate(gateway, params, remote_ip)    
    calc_md5 = Digest::MD5.hexdigest(@gateway.preferred_pin + ":" +
      (params[:id].nil? ? "" : params[:id]) + ":" +
      (params[:control].nil? ? "" : params[:control]) + ":" +
      (params[:t_id].nil? ? "" : params[:t_id]) + ":" +
      (params[:amount].nil? ? "" : params[:amount]) + ":" +
      (params[:email].nil? ? "" : params[:email]) + ":" +
      (params[:service].nil? ? "" : params[:service]) + ":" +
      (params[:code].nil? ? "" : params[:code]) + ":" +
      ":" +
      ":" +
      (params[:t_status].nil? ? "" : params[:t_status]))
      md5_valid = (calc_md5 == params[:md5])

      if (remote_ip == @gateway.preferred_dotpay_server_1 || remote_ip == @gateway.preferred_dotpay_server_2) && md5_valid
        valid = true #yes, it is
      else
       valid = false #no, it isn't
      end 
      valid
  end

  # Completed payment process
  def dotpay_pl_payment_success(params)
    @order.payment.started_processing
    if @order.total.to_f == params[:amount].to_f      
      @order.payment.complete     
    end    
    
    @order.finalize!
    
    @order.next
    @order.next
    @order.save
  end

  # payment cancelled by user (dotpay signals 3 to 5)
  def dotpay_pl_payment_cancel(params)
    @order.cancel
  end

  def dotpay_pl_payment_new(params)
    @order.payment.started_processing
    @order.finalize!
  end

end


