require "ostruct"
class Pago
  def self.make_payment(order_id:,
                        payment_method:,
                        payment_details:)
    
    Rails.logger.info :payment_type => payment_method
    Rails.logger.info :payment_details => payment_details

    case payment_method
    when :check
      Rails.logger.info "Processing check: " +
      payment_details.fetch(:routing_number).to_s + "/" +
      payment_details.fetch(:account_number).to_s
    when :credit_card
      Rails.logger.info "Processing credit card: " +
      payment_details.fetch(:credit_card_number).to_s + "/" +
      payment_details.fetch(:expiration_month).to_s + "/" +
      payment_details.fetch(:expiration_year).to_s
    when :po
      Rails.logger.info "Processing purchase order: " +
      payment_details.fetch(:po_number).to_s
    else
      raise "Unknown payment method: #{payment_method}"
    end

    sleep 3 unless Rails.env.test?
    Rails.logger.info "Done Processing Payment"
    OpenStruct.new(succeeded?: true)
  end
end