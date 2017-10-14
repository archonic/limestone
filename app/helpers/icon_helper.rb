module IconHelper
  def avatar(user, size=:sm)
    circular_icon image_tag(user.avatar_url(size), class: 'rounded-circle') + user.full_name.initials, style: size.to_s, class: 'avatar', alt: user.full_name
  end

  def circular_icon(content, options={})
    style = options.delete(:style) || 'medium'
    content_tag :span,
      content,
      options.merge!(class: ['circular-icon', style, options[:class]].compact.join(' '))
  end
end
