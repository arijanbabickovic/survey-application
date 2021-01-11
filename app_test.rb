require_relative 'app.rb'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_submitting_survey_with_data
    post '/form', params = {email: "abc@abc.com", staff: "2", register: "2", organization: "2", fitting_room: "2", products: "2", price: "2", sizes: "5"}
    assert last_response.ok?
  end

  def test_submitting_survey_without_mandatory_field
    post '/form', params = {email: "abc@abc.com", staff: "2", register: "2", organization: "2", fitting_room: "2", products: "2", price: "2"}
    assert last_response.status == 400
  end

  def test_submitting_survey_without_correct_email_address
    post '/form', params = {email: "abcabc.com"}
    assert !params[:email].match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
    assert last_response.status == 400
  end

  def test_submitting_survey_with_duplicate_emails
    post '/form', params = {email: "abc@abc.com", staff: "2", register: "2", organization: "2", fitting_room: "2", products: "2", price: "2", sizes: "5"}
    assert last_response.body.include?("Email Error")
  end

  def test_admin_access
    get '/results'
    assert last_response.body.include?("Not authorized")
  end
end