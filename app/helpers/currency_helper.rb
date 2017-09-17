module CurrencyHelper
  def charge_pdf_link(charge)
    link_to number_to_currency(charge.amount / 100), charge_path(charge, format: :pdf)
  end
end
