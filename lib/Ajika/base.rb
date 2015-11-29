module Ajika
  # Base class for all Ajika applications and middleware.
  class Base
    def initialize(app = nil)
      super()
      @app = app
      yield self if block_given?
    end

    # Access settings defined with Base.set.
    def self.settings
      self
    end

    # Access settings defined with Base.set.
    def settings
      self.class.settings
    end

    class << self

      def from mail
        puts "from: #{mail}"
      end

    end
  end

  # Execution context for classic style (top-level) applications. All
  # DSL methods executed on main are delegated to this class.
  #
  # The Application class should not be subclassed, unless you want to
  # inherit all settings, routes, handlers, and error pages from the
  # top-level. Subclassing Ajika::Base is highly recommended for
  # modular applications.
  class Application < Base
  end

  # Ajika delegation mixin. Mixing this module into an object causes all
  # methods to be delegated to the Ajika::Application class. Used primarily
  # at the top-level.
  module Delegator #:nodoc:
    def self.delegate(*methods)
      methods.each do |method_name|
        define_method(method_name) do |*args, &block|
          return super(*args, &block) if respond_to? method_name
          Delegator.target.send(method_name, *args, &block)
        end
        private method_name
      end
    end

    #delegate :get, :patch, :put, :post
    delegate :from

    class << self
      attr_accessor :target
    end

    self.target = Application
  end
end