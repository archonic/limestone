# frozen_string_literal: true

class String
  def initials(length = 3)
    return nil if blank?
    split.map(&:first)[0..(length - 1)].join('').upcase
  end
end
