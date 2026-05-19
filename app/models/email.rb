class Email < Contact
  validates :value, format: { with: /\A[a-z0-9_.-]+@([a-z0-9\p{Cyrillic}-]+\.)+[a-z\p{Cyrillic}]{2,}\z/i,
                              message: "invalid email format" }
end
