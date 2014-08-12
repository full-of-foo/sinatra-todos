# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
Bundler.require
# Reload app.js when changed
require "sinatra/reloader" if development?


# DB init
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

# Models
class Task
  include DataMapper::Resource

  property :id, Serial, key: true
  property :name, String, required: true
  property :completed_at, DateTime
  property :created_at, DateTime
end
# Finalize the DataMapper models.
DataMapper.finalize
# Tell DataMapper to update the database according to the definitions above.
DataMapper.auto_upgrade!


get '/task/' do
  content_type :json

  @tasks = Task.all(order: :created_at.desc)
  @tasks.to_json
end

post '/task/' do
  content_type :json

  @task = Task.new(params)
  @task.save ? @task.to_json : halt(500)
end

put '/task/:id' do
  content_type :json

  @task = Task.get(params[:id].to_i)
  @task.update(params)

  @task.save ? @task.to_json : halt(500)
end

get '/task/:id' do
  content_type :json

  @task = Task.get(params[:id].to_i)
  @task ? @task.to_json : halt(404)
end

delete '/task/:id' do
  content_type :json

  Task.get(params[:id].to_i).destroy ? { success: "ok" }.to_json : halt(500)
end


# Seed
if Task.count == 0
  Task.create(name: "Test Task One")
  Task.create(name: "Test Task Two")
end
