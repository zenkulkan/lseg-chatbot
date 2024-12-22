class ChatbotController < ApplicationController
  def index
    # Check if data is already in Redis
    unless $redis.exists?('stock_data')
      # Load stock data from the JSON file
      @stock_data = JSON.parse(File.read(STOCK_DATA_PATH))

      # Store the data in Redis
      $redis.set('stock_data', @stock_data.to_json)
    end

    # Retrieve the data from Redis
    @stock_data = JSON.parse($redis.get('stock_data'))

    # Get the selected exchange and stock from the parameters
    @selected_exchange = params[:exchange]
    @selected_stock_code = params[:stock]

    # Find the selected stock if an exchange and stock code are provided
    if @selected_exchange && @selected_stock_code
      @selected_stock = @stock_data.find { |exchange| exchange['code'] == @selected_exchange }['topStocks'].find { |stock| stock['code'] == @selected_stock_code }
    end
  end
end
