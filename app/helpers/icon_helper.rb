module IconHelper
  def avatar(user, size=:sm)
    circular_icon image_tag(user.avatar_url(size)) + user.full_name.initials, style: 'tiny', class: 'avatar', alt: user.full_name
  end

  def circular_icon(content, options={})
    style = options.delete(:style) || 'medium'
    content_tag :span,
      content,
      options.merge!(class: ['rounded-circle', style, options[:class]].compact.join(' '))
  end
end
