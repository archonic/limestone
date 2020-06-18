# frozen_string_literal: true

class StripeProductService
  def initialize(product_model)
    @product_model = product_model
  end

  def call
    stripe_product = nil
    stripe_product_attrs = {
      product: {
        name: @product_model.name
      },
      id: @product_model.name.downcase.tr(" ", "-"),
      amount: @product_model.amount,
      interval: @product_model.interval,
      currency: @product_model.currency,
      trial_period_days: TRIAL_PERIOD_DAYS
    }
    StripeLogger.info "Creating Product: #{stripe_product_attrs}"
    begin
      stripe_product = Stripe::Product.create stripe_product_attrs
    rescue Stripe::InvalidRequestError => e
      StripeLogger.error "Error creating Product #{@product_model.name}: #{e.json_body[:error]}"
    end

    @product_model.update(stripe_id: stripe_product.id) if stripe_product.present?
  end
end
