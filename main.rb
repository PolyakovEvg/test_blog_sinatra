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
        message VARCHAR,
        title VARCHAR,
        user_name VARCHAR
        );'
        @db.execute 'CREATE TABLE IF NOT EXISTS
    Comments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_date DATE,
        commentator VARCHAR,
        comment VARCHAR,
        post_id INTEGER
        );'
end

def validation_form hash
    error = hash.select {|key| params[key]== ''}.values.join(', ')
    if error != ''
        return error
    end
end

get '/' do
    erb :index
end

get '/new' do
    erb :new
end

get '/posts' do
    @posts = @db.execute 'select * from Posts order by id desc'
    erb :posts
end

get '/posts/:post_id' do
    post_id = params[:post_id]
    results = @db.execute "select * from Posts where id = ?", [post_id]
    @comments = @db.execute 'select * from Comments where post_id=?',[post_id]
    @row = results[0]
    erb :post_comments
end

post '/new' do
    @post = params[:text_area_message]
    @user_name = params[:user_name]
    @post_title = params[:post_title]
    
    @errors = {
        :user_name => 'Введите имя',
        :post_title => 'Введите тему',
        :text_area_message => 'Отсутствует содержание поста',
    }

    @error_new_post = validation_form @errors
    if @error_new_post
        erb :new
    else
        @sucess = 'Пост добавлен'
        @db.execute 'insert into Posts (message,user_name, title, created_date) values (?,?,?,datetime())',[@post, @user_name,@post_title]
        erb :new
    end
    # if @post != ''
    #     @db.execute 'insert into Posts (message, created_date) values (?,datetime())',[@post]
    #     @sucess = 'Пост добавлен'
    #     erb :new
    # else
    #     @error = 'Пост не написан'
    #     erb :new
    # end
end

post '/posts/:post_id' do
    @post_id = params[:post_id]
    results = @db.execute "select * from Posts where id = ?", [@post_id]
    @row = results[0]
    @comment = params[:text_area_message]
    @commentator = params[:commentator]

    @errors = {
        :commentator => 'Введите имя',
        :text_area_message => 'Оставьте комментарий'
    }

    @error_comment = validation_form @errors
    if @error_comment
        erb :post_comments
    else
        @sucess_comment = 'Ваш комментарий был добавлен'
        @db.execute "INSERT INTO Comments (created_date, commentator, comment, post_id) VALUES (datetime(),?,?,?)",[@commentator,@comment,@post_id]

        @comments = @db.execute 'select * from Comments where post_id = 3'
        redirect to ('/posts/' + @post_id)

    end
    
    # if @comment.length <= 0 
    #     @error_comment = 'Комментарий не введен'
    #     erb :post_comments
    # else
    #     @sucess_comment = 'Ваш комментарий был добавлен'
    #     erb :post_comments
    # end
end