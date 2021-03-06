ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest-spec-rails'
require 'webmock/minitest'
require "minitest/unit"
require "mocha/mini_test"

require 'hash_dot'
Hash.use_dot_syntax = true

class FakeUser
  attr_reader :id, :team, :name, :is_bot, :profile

  def initialize(id, name, team: 'teamone', is_bot: false, email: nil)
    @id = id
    @name = name
    @team = team
    @is_bot = is_bot
    @profile = {
      first_name: name,
      last_name: name,
      email: email || "#{@name}@example.com"
    }.to_dot
  end
end

USERONE = FakeUser.new 'U12345', 'userone'
USERTWO = FakeUser.new 'U23456', 'usertwo'
TANGO_ROOT = ENV['TANGOCARD_ROOTURL'] || 'http://example.com'

def mock_tango_api(balance: 200)
  @current_balance = balance
  stub_request(:get, /#{TANGO_ROOT}\/accounts\/.*/)
    .to_return(body: { currentBalance: @current_balance }.to_json)

  stub_request(:post, /#{TANGO_ROOT}\/creditCardDeposits/)
    .to_return do |request|
      body = JSON.parse(request.body)
      @current_balance += body['amount']
      { body: { ok: true }.to_json }
    end

  stub_request(:post, "#{TANGO_ROOT}/orders")
    .to_return do |request|
      body = JSON.parse(request.body)
      @current_balance -= body['amount']
      {
        body: {
          ok: true,
          amountCharged: { total: body['amount'] },
          referenceOrderId: 'abc-123',
          reward: {credentials: {'Claim Code' => 'xyz748'}}
        }.to_json
      }
    end

  stub_request(:post, "#{TANGO_ROOT}/creditCardDeposits")
    .to_return do |request|
      body = JSON.parse(request.body)
      @current_balance += body['amount']
      {
        body: {
          status: 'SUCCESS',
        }.to_json
      }
    end
end

def assert_tango_api_requested(method, endpoint)
  assert_requested method, "#{TANGO_ROOT}#{endpoint}"
end

def refute_tango_api_requested(method, endpoint)
  refute_requested method, "#{TANGO_ROOT}#{endpoint}"
end

def stub_slack_client
  Slack::Web::Client.any_instance
    .expects(:oauth_access).at_least(0)
    .returns(user: {id: 'U123'}, team: {id: 'T123'})
  Slack::Web::Client.any_instance
    .expects(:team_info).at_least(0)
    .returns(team: {domain: 'subdomain', name: 'team name'})
  Slack::Web::Client.any_instance
    .expects(:users_list).at_least(0)
    .returns(members: [USERONE, USERTWO])
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
