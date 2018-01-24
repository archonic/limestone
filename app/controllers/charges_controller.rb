class ChargesController < ApplicationController
  before_action :set_charge, only: [:show]

  def show
    respond_to do |format|
      format.html
      format.pdf {
        send_data @charge.receipt.render,
        filename: "#{@charge.created_at.strftime("%Y-%m-%d")}-limestone-receipt.pdf",
        type: "application/pdf",
        disposition: :inline
      }
    end
  end

  def set_charge
    @charge = Charge.find params[:id]
  end
end
