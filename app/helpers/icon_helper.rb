# frozen_string_literal: true

module IconHelper
  AVATAR_SIZES = { xs: 16, sm: 32, md: 64, lg: 128, xl: 256 }.freeze

  def avatar(user, size = :sm)
    width = AVATAR_SIZES[size]
    resize_str = "#{width}x#{width}"
    img_or_text = user.avatar.attached? ? "img" : "text"
    image_tag = if user.avatar.attached?
      image_tag(
        user.avatar.variant(resize: resize_str),
        class: "rounded-circle"
      )
    else
      ""
    end
    circular_icon(
      image_tag + user.name.initials,
      style: size.to_s,
      class: "avatar-#{img_or_text}",
      alt: user.name
    )
  end

  def circular_icon(content, options = {})
    style = options.delete(:style) || "medium"
    content_tag(
      :span,
      content,
      options.merge!(
        class: ["circular-icon", style, options[:class]].compact.join(" ")
      )
    )
  end

  # https://fontawesome.com/v4.7.0/icons/
  def icon(reference, size = :sm, options = {})
    options[:style] = "font-size: #{AVATAR_SIZES[size]}px"
    options[:class] = "fa fa-#{reference} #{options[:class]}"
    content_tag(:i, nil, options)
  end
end
