# frozen_string_literal: true

class String
  def initials(n = 3)
    return nil if blank?
    split.map(&:first)[0..(n - 1)].join('').upcase
  end
end
