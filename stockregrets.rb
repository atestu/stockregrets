require 'rubygems'
require 'sinatra'
require 'hpricot'
require 'open-uri'
require 'haml'

#  , :proxy => "http://158.50.136.94:80/"

get '/:dollars/:name/:year' do
  docName = open("http://finance.yahoo.com/q?s=#{params[:name].gsub(" ", "%20")}") { |f| Hpricot(f) }
  @ticker = (docName/"title").first.inner_html.split(':')[0]
  docBackThen = open("http://bigcharts.marketwatch.com/historical/default.asp?detect=1&symbol=#{@ticker}&close_date=2%2F7%2F#{params[:year]}&x=26&y=31", :proxy => "http://158.50.136.94:80/" ) { |f| Hpricot(f) }
  docNow = open("http://bigcharts.marketwatch.com/historical/default.asp?detect=1&symbol=#{@ticker}&close_date=#{Date::today.mon()}%2F#{Date::today.day()}%2F#{Date::today.year()}&x=26&y=31", :proxy => "http://158.50.136.94:80/" ) { |f| Hpricot(f) }

  if ((docNow/"nobr").first.inner_html.to_i == 0)
    if (Date::today.day <= 6)
      day = 28
      if (Date::today.month == 1)
        month = 12
        year = Date::today.year - 1
      else
        month = Date::today.mon - 1
        year = Date::today.year
      end
    else
      day = Date::today.day - 5
      month = Date::today.month
      year = Date::today.year
    end
    docNow = open("http://bigcharts.marketwatch.com/historical/default.asp?detect=1&symbol=#{@ticker}&close_date=#{month}%2F#{day}%2F#{year}&x=26&y=31", :proxy => "http://158.50.136.94:80/" ) { |f| Hpricot(f) }
  end
  if ((docBackThen/"nobr").first.inner_html.to_i == 0)
    docBackThen = open("http://bigcharts.marketwatch.com/historical/default.asp?detect=1&symbol=#{@ticker}&close_date=2%2F3%2F#{params[:year]}&x=26&y=31", :proxy => "http://158.50.136.94:80/" ) { |f| Hpricot(f) }
  end
  if ((docBackThen/"nobr").first.inner_html.to_i == 0)
    if Date::today.year > :year
      haml :didntexist
    else
      haml :bttf
    end
  else
    @formerPricePerShare = (docBackThen/"nobr").first.inner_html.to_i
    @currentPricePerShare = (docNow/"nobr").first.inner_html.to_i
    @moneyYouWouldHave = params[:dollars].to_i() * @currentPricePerShare / @formerPricePerShare
    
    @href = "/#{params[:dollars]}/#{@ticker}/#{params[:year]}"
    docBitly = open("http://api.bit.ly/shorten?version=2.0.1&format=xml&longUrl=http://stockregrets.heroku.com" + @href + "&login=atestu&apiKey=R_de497f5fbf142ef6393e5ac94359ae18", :proxy => "http://158.50.136.94:80/") { |f| Hpricot::XML(f) }
    @bitly = (docBitly/"shortUrl").first.inner_html
    if @bitly.nil?
      @bitly = "http://stockregrets.heroku.com/" + @href
    end
    
    @twitterStatus = "http://twitter.com/?status=" + @bitly + " (via @stockregrets)"
    haml :prices
  end
end

get '/0//' do
  redirect "/"
end

get '/' do
  haml :index
end

post '/' do
  redirect "/#{params[:dollars].to_i().to_s()}/#{params[:name]}/#{params[:year]}"
end