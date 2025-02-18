class Phone < Contact
  validates :value, presence: { message: "invalid phone number" }
end
