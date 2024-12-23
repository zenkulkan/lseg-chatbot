class ChatbotController < ApplicationController
  before_action :get_stock_data

  def index
    session[:chat_history] ||= []
  end
  def message
    user_message = params[:message].strip
    reset_session if user_message.downcase == "main menu"
    session[:chat_history] ||= []

    unless user_message == "main menu"
      session[:chat_history] << { role: 'user', message: user_message }
      session[:chat_history] << { role: 'ai', message: generate_ai_response(user_message.downcase) }
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
    "You selected #{exchange_code}. Please select a stock:\n#{stocks.map { |stock| stock['stockName'] }.join("\n")}"
  end

  def stock_price_message(exchange_code, stock_code)
    stock = find_stock(stock_code, exchange_code)
    stock ? "The price of #{stock['stockName']} is #{stock['price']}" : "Invalid stock code for #{exchange_code}."
  end

  def extract_exchange_code(input)
    exchange = @stock_data.find { |ex| ex['stockExchange'].downcase.include?(input) || ex['code'].downcase == input }
    exchange ? exchange['code'] : nil
  end

  def extract_stock_code(input, exchange_code)
    return unless exchange_code

    stocks = @stock_data.find { |ex| ex['code'] == exchange_code }['topStocks']
    stock = stocks.find { |s| s['stockName'].downcase.include?(input) || s['code'].downcase == input }
    stock ? stock['code'].downcase : nil
  end

  def find_stock(code, exchange_code)
    exchange = @stock_data.find { |ex| ex['code'] == exchange_code }
    return unless exchange

    exchange['topStocks'].find { |s| s['code'].downcase == code }
  end
end
