require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader'
require 'sqlite3'
require 'sequel'
require './modules.rb'
require './data_format.rb'
require './operation.rb'
require 'pry'
require 'yaml'

DB = Sequel.connect(adapter: 'sqlite', database: './test.db')
USER = DB[:user]
PRODUCT = DB[:product]
TEMPLATE = DB[:template]

#DB = Sequel.sqlite('./test.db')
#DB = Sequel.connect('sqlite://test.db')

get '/ww' do
  @db = DB[:user].select(:name).to_a
  DB[:user].insert(name: 'Mike', template_id: 3, bonus:100)
  erb :ww
end

post '/operation' do
  data = JSON.parse(request.body.read)
  item = data["item"][0]["request"]["body"]["raw"]
  formated_data = DataFormat.format(item)
  user_info = Operation.user_info(formated_data)
  products_info = Operation.products_info(formated_data)
  products = Operation.calculation_for_product(products_info)
  total_calculation = Operation.total_calculation(products)
  binding.pry
end
