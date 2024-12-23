require 'rails_helper'

RSpec.describe ChatbotController, type: :controller do
  let(:stock_data) do
    [
      {
        "code" => "LSE",
        "stockExchange" => "London Stock Exchange",
        "topStocks" => [
          { "code" => "CRDA", "stockName" => "CRODA INTERNATIONAL PLC", "price" => 4807.00 },
          { "code" => "GSK", "stockName" => "GSK PLC", "price" => 1574.80 }
        ]
      },
      {
        "code" => "NYSE",
        "stockExchange" => "New York Stock Exchange",
        "topStocks" => [
          { "code" => "AHT", "stockName" => "Ashford Hospitality Trust", "price" => 1.72 },
          { "code" => "KUKE", "stockName" => "Kuke Music Holding Ltd", "price" => 1.20 }
        ]
      }
    ]
  end

  before do
    allow(controller).to receive(:get_stock_data).and_return(stock_data)
    controller.instance_variable_set(:@stock_data, stock_data)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "initializes chat history with the welcome message" do
      get :index
      expect(session[:chat_history]).to eq([])
    end
  end

  describe "POST #message" do
    it "redirects to root path" do
      post :message, params: { message: "LSE" }
      expect(response).to redirect_to(root_path)
    end

    it "adds user message to chat history" do
      post :message, params: { message: "LSE" }
      expect(session[:chat_history]).to include({ role: 'user', message: "LSE" })
    end

    context "when user selects an exchange" do
      it "sets the selected exchange in session" do
        post :message, params: { message: "LSE" }
        expect(session[:selected_exchange]).to eq("LSE")
      end

      it "adds AI response with stock list to chat history" do
        post :message, params: { message: "LSE" }
        expect(session[:chat_history]).to include({ role: 'ai', message: "You selected LSE. Please select a stock:\nCRODA INTERNATIONAL PLC\nGSK PLC" })
      end
    end

    context "when user selects a stock" do
      before do
        post :message, params: { message: "LSE" }
      end

      it "sets the selected stock code in session" do
        post :message, params: { message: "CRDA" }
        expect(session[:selected_stock_code].downcase).to eq("crda")
      end

      it "adds AI response with stock price to chat history" do
        post :message, params: { message: "CRDA" }
        expect(session[:chat_history]).to include({ role: 'ai', message: "The price of CRODA INTERNATIONAL PLC is 4807.0" })
      end
    end

    context "when user enters invalid input" do
      it "adds AI response with error message to chat history" do
        post :message, params: { message: "Invalid Input" }
        expect(session[:chat_history]).to include({ role: 'ai', message: "I didn't understand. Please select a Stock Exchange (LSE, NYSE, NASDAQ) or a valid stock." })
      end
    end

    context "when user selects 'main menu'" do
      it "resets the session " do
        post :message, params: { message: "lse" }
        post :message, params: { message: "main menu" }
        expect(session[:chat_history]).to be_empty
      end
    end
  end
end
