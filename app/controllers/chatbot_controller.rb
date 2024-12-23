class ChatbotController < ApplicationController
  before_action :get_stock_data
  def index
    session[:chat_history] ||= [{ role: 'ai', message: ai_initial_message }]
  end

  def message

    user_message = params[:message].strip
    reset_session if user_message.downcase == "main menu"

    session[:chat_history] ||= [{ role: 'ai', message: ai_initial_message }]
    if user_message != "main menu"
      session[:chat_history] << { role: 'user', message: user_message }

      ai_response = generate_ai_response(user_message)
      session[:chat_history] << { role: 'ai', message: ai_response }
    end

    redirect_to root_path
  end

  private

  def get_stock_data
    unless $redis.exists?('stock_data')
      @stock_data = JSON.parse(File.read(STOCK_DATA_PATH))

      $redis.set('stock_data', @stock_data.to_json)
    end

    @stock_data ||= JSON.parse($redis.get('stock_data'))
  end

  def generate_ai_response(user_message)
    exchange_code = extract_exchange_code(user_message)
    stock_code = extract_stock_code(user_message, session[:selected_exchange])

    if exchange_code
      session[:selected_exchange] = exchange_code
      stock_list_message(exchange_code)
    elsif stock_code
      session[:selected_stock_code] = stock_code
      stock_price_message(session[:selected_exchange], stock_code)
    else
      "I didn't understand. Please select a Stock Exchange (LSE, NYSE, NASDAQ) or a valid stock."
    end
  end

  def stock_list_message(exchange_code)
    stocks = @stock_data.find { |ex| ex['code'] == exchange_code }['topStocks']
    message =  "You selected #{exchange_code}. Please select a stock:\n"
    stocks.each { |stock| message += "#{stock['stockName']}\n" }
    message
  end

  def stock_price_message(exchange_code, stock_code)
    stock = find_stock(stock_code, exchange_code)
    if stock
      "The price of #{stock['stockName']} is #{stock['price']}"
    else
      "Invalid stock code for #{exchange_code}."
    end
  end

  def extract_exchange_code(input)
    case input
    when 'LSE', 'London Stock Exchange' then 'LSE'
    when 'NYSE', 'New York Stock Exchange' then 'NYSE'
    when 'NASDAQ' then 'NASDAQ'
    else nil
    end
  end

  def extract_stock_code(input, exchange_code)
    return nil unless exchange_code

    stocks = @stock_data.find { |ex| ex['code'] == exchange_code }['topStocks']
    stock = stocks.find { |s| s['stockName'].include?(input) || s['code'] == input }

    stock ? stock['code'] : nil
  end

  def find_stock(code, exchange_code)
    exchange = @stock_data.find { |ex| ex['code'] == exchange_code }
    return nil unless exchange

    exchange['topStocks'].find { |s| s['code'] == code }
  end

  def ai_initial_message
    [
      'Please select a Stock Exchange',
      'London Stock Exchange',
      'New York Stock Exchange',
      'NASDAQ'
  ].join("\n")
  end
end
