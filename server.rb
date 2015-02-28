require 'sinatra'
require 'pry'
require 'csv'

configure do
  enable :sessions
end

articles_array = []

get '/articles' do
  # binding.pry
  articles_array = CSV.read("./articles.csv")
  erb :news_home, locals: { articles_array: articles_array }
end

# get '/articles/new' do
#   redirect '/articles/new/error_pass' #redundant
# end

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
