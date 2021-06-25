class Managers
  def self.for_user(region, user, user_label)
    [
      ["#{region} #{user} #{user_label}", 1]
    ]
  end
end
