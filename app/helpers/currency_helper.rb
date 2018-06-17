# frozen_string_literal: true

module CurrencyHelper
  include ActionView::Helpers::NumberHelper

  def formatted_amount(amount, currency = nil)
    [
      number_to_currency(amount / 100),
      currency.try(:upcase)
    ].join(' ').strip
  end

  def invoice_pdf_link(invoice)
    link_to(
      icon('file-pdf-o', :sm),
      invoice_path(invoice, format: :pdf),
      target: :_blank
    )
  end
end
