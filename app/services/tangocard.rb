module Tangocard
  class Client
    def initialize
      @conn = Faraday.new ENV['TANGOCARD_ROOTURL'] do |c|
        c.use Faraday::Response::RaiseError
        c.adapter Faraday.default_adapter
      end
      @conn.basic_auth ENV['TANGOCARD_PLATFORM_NAME'], ENV['TANGOCARD_PLATFORM_KEY']
    end

    def create_customer(name)
      resp = @conn.post do |req|
        req.url 'customers'
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          displayName: name,
          customerIdentifier: name.parameterize
        }.to_json
      end
      JSON.parse resp.body
    end

    def create_account(customerIdentifier: '', accountIdentifier: '', email: '', name: '')
      resp = @conn.post do |req|
        req.url "customers/#{customerIdentifier}/accounts"
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          accountIdentifier: accountIdentifier,
          contactEmail: email,
          currencyCode: 'USD',
          displayName: name
        }.to_json
      end
      JSON.parse resp.body
    end

    def get_account(identifier)
      resp = @conn.get "accounts/#{identifier}"
      JSON.parse resp.body
    end
  end
end