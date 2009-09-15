require 'rubygems'
require 'sinatra'
require 'hpricot'
require 'open-uri'
require 'haml'

#  

get '/:dollars/:name/:day/:month/:year' do
  docName = open("http://finance.yahoo.com/q?s=#{params[:name].gsub(" ", "%20")}", :proxy => "http://158.50.136.94:80/") { |f| Hpricot(f) }
  @ticker = (docName/"title").first.inner_html.split(':')[0]
  docBackThen = open("http://bigcharts.marketwatch.com/historical/default.asp?detect=1&symbol=#{@ticker}&close_date=#{params[:month]}%2F#{params[:day]}%2F#{params[:year]}&x=26&y=31", :proxy => "http://158.50.136.94:80/" ) { |f| Hpricot(f) }
  docNow = open("http://bigcharts.marketwatch.com/historical/default.asp?detect=1&symbol=#{@ticker}&close_date=#{Date::today.mon()}%2F#{Date::today.mon()}%2F#{Date::today.year()}&x=26&y=31", :proxy => "http://158.50.136.94:80/" ) { |f| Hpricot(f) }

  @formerPricePerShare = (docBackThen/"nobr").first.inner_html.to_i
  @currentPricePerShare = (docNow/"nobr").first.inner_html.to_i
  @moneyYouWouldHave = params[:dollars].to_i() * @currentPricePerShare / @formerPricePerShare

  @href = "/#{params[:dollars]}/#{@ticker}/#{params[:day]}/#{params[:month]}/#{params[:year]}"
  docBitly = open("http://api.bit.ly/shorten?version=2.0.1&format=xml&longUrl=http://stockregrets.heroku.com" + @href + "&login=atestu&apiKey=R_de497f5fbf142ef6393e5ac94359ae18", :proxy => "http://158.50.136.94:80/") { |f| Hpricot::XML(f) }
  @bitly = (docBitly/"shortUrl").first.inner_html
  if @bitly.nil?
    @bitly = "http://stockregrets.heroku.com/" + @href
  end

  @twitterStatus = "http://twitter.com/?status=" + @bitly + " (via @stockregrets)"
  haml :prices
end

get '/0//2/2/' do
  redirect "/"
end

get '/' do
  haml :index
end

post '/' do
  redirect "/#{params[:dollars].to_i().to_s()}/#{params[:name]}/2/2/#{params[:year]}"
end