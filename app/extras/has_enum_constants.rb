module HasEnumConstants
  class ConstantsBuilder
    def initialize(namespace, const)
      @namespace = namespace
      @collection = @namespace.const_get(const)
    end

    def constant(name)
      val = name.to_s.downcase
      @collection.push(val)
      @namespace.const_set(name, val)
    end
  end

  # Introduces DSL for constants definition.
  # The all defined contants are put into the `collection` constant.
  #
  # Usage example:
  #   class User
  #     extend HasEnumConstants
  #
  #     constants_group :KINDS do
  #       constant :ADMIN
  #       constant :GUEST
  #     end
  #   end
  #   User::KINDS # => ['admin', 'guest']
  #   User::ADMIN # => 'admin'
  #   User::GUEST # => 'guest'
  def constants_group(collection, &block)
    const_set(collection, [])
    ConstantsBuilder.new(self, collection).instance_eval(&block)
    const_get(collection).freeze
  end
end
