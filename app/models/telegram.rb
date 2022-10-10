class Telegram < Contact
  validates :value, format: { with: /.*\B@(?=\w{5,64}\b)[a-zA-Z0-9]+(?:_[a-zA-Z0-9]+)*.*/,
                              message: "invalid telegram nikname" }
end
