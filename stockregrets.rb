require 'rubygems'
require 'sinatra'
require 'date'
require 'hpricot'
require 'open-uri'
require 'haml'

#   , :proxy => "http://158.50.136.94:80/"

get '/:dollars/:name/:year' do
  docName = open("http://finance.yahoo.com/q?s=#{params[:name].gsub(" ", "%20")}") { |f| Hpricot(f) }
  @ticker = (docName/"title").first.inner_html.split(':')[0]
  docBackThen = open("http://bigcharts.marketwatch.com/historical/default.asp?symb=#{@ticker}&closeDate=2%2F7%2F#{params[:year]}"  ) { |f| Hpricot(f) }
  docNow = open("http://bigcharts.marketwatch.com/historical/default.asp?&symb=#{@ticker}&closeDate=#{Date.today.mon()}%2F#{Date.today.day()}%2F#{Date.today.year()}"  ) { |f| Hpricot(f) }
puts "http://bigcharts.marketwatch.com/historical/default.asp?&symb=#{@ticker}&closeDate=#{Date.today.mon()}%2F#{Date.today.day()}%2F#{Date.today.year()}"
  if ((docNow/"td")[4].inner_html.to_i == 0)
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
    docNow = open("http://bigcharts.marketwatch.com/historical/default.asp?detect=1&symb=#{@ticker}&closeDate=#{month}%2F#{day}%2F#{year}"  ) { |f| Hpricot(f) }
  end
  if ((docBackThen/"td")[4].inner_html.to_i == 0)
    docBackThen = open("http://bigcharts.marketwatch.com/historical/default.asp?detect=1&symb=#{@ticker}&closeDate=2%2F3%2F#{params[:year]}"  ) { |f| Hpricot(f) }
  end
  if ((docBackThen/"td")[4].inner_html.to_i == 0)
    if Date::today.year > params[:year].to_i
      haml :didntexist
    else
      haml :bttf
    end
  else
    @formerPricePerShare = (docBackThen/"td")[4].inner_html.to_i
    @currentPricePerShare = (docNow/"td")[4].inner_html.to_i
    @moneyYouWouldHave = params[:dollars].to_i() * @currentPricePerShare / @formerPricePerShare

    @twitterStatus = "http://twitter.com/?status=http://stockregrets.heroku.com/#{params[:dollars]}/#{@ticker}/#{params[:year]} (via @stockregrets)"
    haml :prices
  end
end

get '//*/*' do
  redirect "/"
end

get '/*/*/' do
  redirect "/"
end

get '/*//*' do
  redirect "/"
end

get '/' do
  haml :index
end

post '/' do
  redirect "/#{params[:dollars].to_i().to_s()}/#{params[:name]}/#{params[:year]}"
end