require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test 'redirects to /login if not logged in' do
    get '/admin/'
    assert_redirected_to '/admin/login'
  end
end