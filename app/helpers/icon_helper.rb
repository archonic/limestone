module IconHelper
  AVATAR_SIZES = {xs: 16, sm: 32, md: 64, lg: 128, xl: 256}.freeze

  def avatar(user, size = :sm)
    width = AVATAR_SIZES[size]
    resize_str = "#{width}x#{width}"
    img_or_text = user.avatar.attached? ? 'img' : 'text'
    image_url = if user.avatar.attached?
      user.avatar.variant(resize: resize_str)
    else
      hash = Digest::MD5.hexdigest(user.email.try(:downcase) || 'noemail')
      "https://secure.gravatar.com/avatar/#{hash}?d=blank&s=#{width}"
    end
    circular_icon(
      image_tag(
        image_url,
        class: 'rounded-circle'
      ) + user.full_name.initials,
      style: size.to_s,
      class: "avatar-#{img_or_text}",
      alt: user.full_name
    )
  end

  def circular_icon(content, options = {})
    style = options.delete(:style) || 'medium'
    content_tag(
      :span,
      content,
      options.merge!(
        class: ['circular-icon', style, options[:class]].compact.join(' ')
      )
    )
  end

  # http://fontawesome.io/icons/
  def icon(reference, size = :sm, options = {})
    options.merge!(style: "font-size: #{AVATAR_SIZES[size]}px")
    options.merge!(class: "fa fa-#{reference} #{options[:class]}")
    content_tag(:i, nil, options)
  end
end
