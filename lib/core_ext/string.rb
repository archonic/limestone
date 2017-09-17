class String
  def initials(n=3)
    return nil if self.blank?
    self.split.map(&:first)[0..(n-1)].join('').upcase
  end
end
