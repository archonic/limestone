# frozen_string_literal: true

class PagesController < ApplicationController
  # You may want to manage your static pages with something like HubSpot,
  # or serve static pages with a nginx / apache / whatever directly

  def pro
    unless current_user.pro?
      redirect_to( billing_path,
        flash: {
          warning: "Upgrade to the Pro plan to get access to that page."
        }
      ) && return
    end
  end
end
