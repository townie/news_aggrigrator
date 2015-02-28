require 'sinatra'
require 'pry'
require 'csv'

configure do
  enable :sessions
end

articles_array = []

def load_articles
  CSV.read("./articles.csv")
end

def sites_hash
  articles_array = load_articles
  articles_hash = {}

  articles_array.each do |article|
    articles_hash[article[1]] = { "article" => article[0] ,"description" => article[2]}
  end

  articles_hash
end

def not_valid_params?
  params["title"] == "" || params["URL"] == "" || params["description"] == ""
end

def submissions_error(error_string)
  session["error"] = error_string
  redirect "/articles/new"
end

def description_length?
  params["description"].length < 20
end

get '/articles' do
  articles_hash = sites_hash
  erb :news_home, locals: { articles_hash: articles_hash }
end

get '/articles/new' do
  erb :submissions, locals: {error_code: session["error"]}
end

post '/articles/new' do
  if not_valid_params?
    submissions_error("empty_string")
  elsif description_length?
    submissions_error("too_few")
  else
    submission_array = [params["title"], params["URL"], params["description"]]
    CSV.open("./articles.csv", "a") do |csv|
      csv << submission_array
    end
    session["error"] = nil
    redirect '/articles'
  end
end
