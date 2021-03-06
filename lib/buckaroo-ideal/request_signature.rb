require 'digest/md5'
require 'active_support/core_ext/module/delegation'

module Buckaroo
  module Ideal
    #
    # Digital signature generator for +Buckaroo::Ideal::Order+ instances.
    #
    # A digital signature is used to sign your request so the Buckaroo Payment
    # Service can validate that the request was made by your application.
    #
    # A digital signature is composed by generating a MD5 hash of the following
    # values:
    # * Merchant Key:  The +merchant_key+ that is provided by Buckaroo and set
    #   in +Buckaroo::Ideal::Config+.
    # * Invoice Number: The +invoice_number+ that is set in your
    #   +Buckaroo::Ideal::Order+ instance.
    # * Amount: The +amount+ that is set in your +Buckaroo::Ideal::Order+
    #   instance in cents.
    # * Currency: The +currency+ that is set in your +Buckaroo::Ideal::Order+
    #   instance.
    # * Mode: The +test_mode+ that is set in +Buckaroo::Ideal::Config+.
    #
    # To create a signature for an +Buckaroo::Ideal::Order+, instantiate a new
    # +Buckaroo::Ideal::RequestSignature+ and provide the order:
    #
    #     order = Buckaroo::Ideal::Order.new(amount: 100, invoice_number: 'EETNU-123')
    #     signature = Buckaroo::Ideal::Signature.new(order)
    class RequestSignature
      
      # @return [Buckaroo::Ideal::Order] The order that is being signed.
      attr_reader :order
      
      # @return [Boolean] The configured test_mode in +Buckaroo::Ideal::Config+
      delegate :test_mode,    to: Config
      
      # @return [String] The configured merchant_key in +Buckaroo::Ideal::Config+
      delegate :merchant_key, to: Config
      
      # @return [String] The configured secret_key in +Buckaroo::Ideal::Config+
      delegate :secret_key,   to: Config
      
      # Initialize a new +Buckaroo::Ideal::Signature+ instance for the given
      # order.
      #
      # @param [Buckaroo::Ideal::Order] The order that needs to be signed.
      # @param [String] The secret key that is used to sign the order.
      #   Defaults to the configured +Buckaroo::Ideal::Config.secret_key+.
      # @return [Buckaroo::Ideal::Signature] The signature for the order
      #   instance.
      def initialize(order)
        @order  = order
      end
      
      def signature
        salt = [
          merchant_key,
          to_normalized_string(order.invoice_number),
          to_cents(order.amount),
          order.currency,
          to_numeric_boolean(test_mode),
          secret_key
        ].join
        
        Digest::MD5.hexdigest(salt)
      end
      alias_method :to_s, :signature
      
      private
      
      include Util
    end
  end
end
