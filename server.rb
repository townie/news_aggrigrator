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

get '/articles' do
  articles_hash = sites_hash
  erb :news_home, locals: { articles_hash: articles_hash }
end

get '/articles/new' do
  erb :submissions, locals: {error_code: session["error"]}
end

post '/articles/new' do
  if params["title"] == "" || params["URL"] == "" || params["description"] == ""
    # $error_code = "empty_string"
    session["error"] = "empty_string"
    # render notice: "You have an empty field"
    redirect "/articles/new"
  elsif params["description"].length < 20
    session["error"] = "too_few"
    redirect "/articles/new"
  else
    submission_array = [params["title"], params["URL"], params["description"]]
    CSV.open("./articles.csv", "a") do |csv|
      csv << submission_array
    end
    session["error"] = nil
    redirect '/articles'
  end

end
