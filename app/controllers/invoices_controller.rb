# frozen_string_literal: true

class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show]

  def show
    respond_to do |format|
      format.html
      format.pdf {
        send_data @invoice.receipt.render,
          filename: "#{@invoice.paid_at.strftime('%Y-%m-%d')}-limestone-receipt.pdf",
          type: "application/pdf",
          disposition: :inline
      }
    end
  end

  private

    def set_invoice
      @invoice = Invoice.find params[:id]
    end
end
