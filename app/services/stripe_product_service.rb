# frozen_string_literal: true

class StripeProductService
  def initialize(product_model)
    @product_model = product_model
  end

  def create
    # Don't contact Stripe if we already have a stripe_id
    return false if @product_model.stripe_id.present?

    stripe_product = nil
    stripe_product_attrs = {
      name: @product_model.name
    }
    p "Creating Product: #{stripe_product_attrs}"
    begin
      stripe_product = Stripe::Product.create stripe_product_attrs
    rescue Stripe::InvalidRequestError => e
      p "Error creating Product #{@product_model.name}: #{e.json_body[:error]}"
    end

    @product_model.update(stripe_id: stripe_product.id) if stripe_product.present?
  end
end
