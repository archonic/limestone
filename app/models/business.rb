# This is a false class to create an administrate page
# on which business metrics go.
class Business
  def self.model_name
    self
  end

  def self.human(*args)
    'Business'
  end
end
