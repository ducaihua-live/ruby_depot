require "pago"
class Order < ApplicationRecord
  enum :pay_type, {
    "Check"           => 0,
    "Credit card"     => 1,
    "Purchase order"  => 2
  }
  has_many :line_items, dependent: :destroy
  has_many :support_requests, dependent: :nullify
  validates :name, :address, :email, presence: true
  validates :pay_type, inclusion: pay_types.keys

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end

  def charge!(pay_type_params)
    payment_details = {}
    payment_method = nil
    case pay_type
    when "Check"
      payment_details[:routing_number] = pay_type_params[:routing_number]
      payment_details[:account_number] = pay_type_params[:account_number]
      payment_method = :check
    when "Credit card"
      month, year = pay_type_params[:expiration_date].split("/")
      payment_details[:credit_card_number] = pay_type_params[:credit_card_number]
      payment_details[:expiration_month] = month
      payment_details[:expiration_year] = year
      payment_details[:cvv] = pay_type_params[:cvv]
      payment_method = :credit_card
    when "Purchase order"
      payment_details[:po_number] = pay_type_params[:po_number]
      payment_method = :po
    end


    Rails.logger.info payment_details: payment_details
    Rails.logger.info payment_method: payment_method
    Rails.logger.info order_id: id

    payment_result = Pago.make_payment(
      order_id: id,
      payment_method: payment_method,
      payment_details: payment_details
    )
    if payment_result.succeeded?
      OrderMailer.received(self).deliver_later
    else
      raise payment_result.error
    end
  end
end
