class Email < Contact
  validates :value, format: { with: /([a-z0-9_\.-]+)@([a-z0-9_\.-]+)\.([a-z\.]{2,6})/,
                              message: "invalid email number" }
end
