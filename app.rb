require 'rubygems'
require 'sinatra'
require 'sinatra/cookies'
require 'sinatra/base'
require 'sinatra/param'
require 'json'

class App < Sinatra::Base
  helpers Sinatra::Param
end

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end
end

get '/' do
  if cookies[:status] == 'done'
    erb :success
  else
    erb :form
  end
end

get '/results' do
  protected!
  @hash = JSON.load(File.read('answers.json'))

  @staff = 0
  @register = 0
  @organization = 0
  @fitting_room = 0
  @products = 0
  @price = 0
  @sizes = 0

  @hash.each_value do |value|
    @staff = @staff + (value["staff"].to_f/@hash.length).round(2)
    @register = (@register + value["register"].to_f/@hash.length).round(2)
    @organization = (@organization + value["organization"].to_f/@hash.length).round(2)
    @fitting_room = (@fitting_room + value["fitting_room"].to_f/@hash.length).round(2)
    @products = (@products + value["products"].to_f/@hash.length).round(2)
    @price = (@price + value["price"].to_f/@hash.length).round(2)
    @sizes = (@sizes + value["sizes"].to_f/@hash.length).round(2)
  end
  erb :results
end

post '/form' do
  param :staff,               String, required: true, message: "Please fill out the 'Staff' category."
  param :register,            String, required: true, message: "Please fill out the 'Register' category."
  param :organization,        String, required: true, message: "Please fill out the 'Organization' category."
  param :fitting_room,        String, required: true, message: "Please fill out the 'Fitting Room' category."
  param :products,            String, required: true, message: "Please fill out the 'Products' category."
  param :price,               String, required: true, message: "Please fill out the 'Price' category."
  param :sizes,               String, required: true, message: "Please fill out the 'Sizes' category."
  param :email,               String, required: true, format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, message: "Please enter a valid email address."
  
  file = File.read('answers.json')
  hash = JSON.parse(file)

  if cookies[:status] == 'done'
    erb :already_submitted
  elsif file.include?(params[:email])
    erb :same_email
  else
    hash["#{hash.length}"] = params.to_h
    File.write('answers.json', JSON.dump(hash))
    cookies[:status] = 'done'
    erb :success
  end
end