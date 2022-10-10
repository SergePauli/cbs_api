class SiteUrl < Contact
  validates :value, format: { with: /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?/,
                              message: "invalid site URL" }
end
