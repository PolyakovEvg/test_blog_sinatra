require 'sinatra'
require 'rubygems'
require 'sinatra/reloader'
require 'sqlite3'   


def init_db
    @db = SQLite3::Database.new 'blog.db'
    @db.results_as_hash = true
end

before do
    init_db
end

configure do
    init_db
    @db.execute 'CREATE TABLE IF NOT EXISTS
    Posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_date DATE,
        name VARCHAR
        );'
end

before do
    init_db
end

get '/' do
    erb :index
end

get '/new' do
    erb :new
end

get '/posts' do
    erb :posts
end

post '/new' do
    @post = params[:text_area_message]
    
    if @post != ''
        @db.execute 
        @sucess = 'Пост добавлен'
        erb :new
    else
        @error = 'Пост не написан'
        erb :new
    end
end