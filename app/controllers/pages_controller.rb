# frozen_string_literal: true

class PagesController < ApplicationController
  def pro
    unless current_user.product.pro?
      redirect_to(billing_path,
        flash: {
          warning: "Upgrade to the Pro plan to get access to that page."
        }
      ) && return
    end
  end
end
