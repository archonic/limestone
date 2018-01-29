module CurrencyHelper
  def invoice_pdf_link(invoice)
    link_to(
      icon('file-pdf-o', :sm),
      invoice_path(invoice, format: :pdf),
      target: :_blank
    )
  end
end
