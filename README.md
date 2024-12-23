# LSEG Chatbot Challenge

This project implements a chatbot UI for the LSEG pre-interview coding challenge. It allows users to interact with a chatbot to get stock information from different exchanges (LSEG, NASDAQ, NYSE).

This is a MVP version of the chatbot, focusing on core functionality. To simplify the implementation and prioritize a quick turnaround, I have not included a database in this version.

## Features

*   Select a stock exchange (LSEG, NASDAQ, NYSE).
*   View a list of 5 stocks for the selected exchange.
*   Select a stock to see its latest price.
*   "Go Back" and "Main menu" options for navigation.
*   Chat-like interface with user and AI messages.
*   Interactive stock selection within AI messages.
*   Uses Redis to store stock data from json file.

## Technologies Used

*   Ruby on Rails (web application framework)
*   Redis (in-memory data store)
*   HTML, CSS, JavaScript (frontend)
*   Docker (containerization)
*   RSpec (testing framework)

## How to Run
## Ruby
### Prerequisites

*   Ruby (version 3.2.0)
*   Bundler (gem install bundler)
*   Redis (make sure Redis is installed and running on your system)

### Steps

1.  Clone the repository:

    ```bash
    git clone https://github.com/zenkulkan/lseg-chatbot.git
    ```

2.  Navigate to the project directory:

    ```bash
    cd lseg-chatbot
    ```

3.  Install dependencies:

    ```bash
    bundle install
    ```

4.  Start the Redis server (if not run yet):
    ```base
    redis-server
    ```

5.  Start the Rails server:

    ```bash
    rails server
    ```

6.  Open your web browser and go to `http://localhost:3000` to access the chatbot.

## Docker
### Prerequisites

*   Docker (make sure Docker is installed on your system)

### Steps

1.  Clone the repository:

    ```bash
    git clone https://github.com/zenkulkan/lseg-chatbot.git
    ```

2.  Navigate to the project directory:

    ```bash
    cd lseg-chatbot
    ```

3.  Build the Docker image:

    ```bash
    docker build -t stock-chatbot .
    ```

4.  Run the Docker container:

    ```bash
    docker run -p 3000:3000 -p 6379:6379 stock-chatbot
    ```

5.  Open your web browser and go to `http://localhost:3000` to access the chatbot.

## Code Structure

*   `app/controllers/chatbot_controller.rb`: Contains the controller logic for handling user interactions and generating AI responses.
*   `app/views/chatbot/index.html.erb`: The main view for the chatbot interface.
*   `app/views/chatbot/_chat_history.html.erb`: Partial for rendering the chat history.
*   `app/views/chatbot/_message_form.html.erb`: Partial for rendering the message input form.
*   `app/assets/stylesheets/chatbot.css`: Contains the CSS styles for the chatbot interface.
*   `config/initializers/redis.rb`: Configures the Redis connection.
*   `config/routes.rb`: Defines the routes for the application.
*   `Dockerfile`: Contains instructions for building the Docker image.
*   `spec/controllers/chatbot_controller_spec.rb`: Contains RSpec tests for the chatbot controller.

## Chatbot Logic

The chatbot follows a simple logic:

1.  When the user first accesses the chatbot, the AI prompts the user to select a stock exchange (LSEG, NASDAQ, NYSE).
2.  Once the user selects an exchange, the AI displays a list of 5 stocks traded on that exchange.
3.  The user can then select a stock from the list to see its latest price.
4.  After displaying the stock price, the AI provides "Go Back" and "Main menu" options for navigation.
5.  Selecting "Main menu" will reset the session, clearing all chat history and returning the user to the initial state.

This ensures a fresh start for new interactions and avoids any potential confusion from previous selections.

The chatbot uses the `session` to keep track of the selected exchange and stock. The AI responses are generated dynamically based on the user's selections and the data in the JSON file.

The chatbot is designed to be flexible in recognizing user input. For example:

*   **Exchange selection:** The user can enter the full exchange name ("London Stock Exchange"), a partial name("London") or the code ("LSE").
*   **Stock selection:** The user can enter the full stock name ("CRODA INTERNATIONAL PLC"), a partial name ("CRODA"), or the stock code ("CRDA").

To ensure accuracy and avoid ambiguity, partial names for both exchanges and stocks must have at least 3 characters. If a partial name matches multiple stocks, the chatbot will select the first match. This flexibility enhances the user experience by accommodating different input styles and reducing the need for precise inputs

## Testing

The `spec` directory contains RSpec tests for the `ChatbotController`. These tests cover various scenarios, including:

*   Selecting exchanges
*   Selecting stocks
*   Handling invalid input
*   Resetting the session with "Main menu"

RSpec is a testing framework for Ruby that helps ensure the code works as expected. The tests in this project verify that the chatbot behaves correctly in different situations and that the core logic is functioning as intended.

To run the RSpec tests, navigate to the project directory in your terminal and run the following command:

```bash
bundle exec rspec
```

## Additional Notes

*   The chatbot UI is designed to be simple and intuitive, with a focus on functionality.
*   The code is organized and well-commented to enhance readability and maintainability.
*   Error handling is implemented to gracefully handle invalid inputs and other potential issues.

## Future Improvements

*   Enhance the AI with more sophisticated natural language processing capabilities.
*   Improve the UI with more advanced styling and animations.
*   Implement user authentication and personalization.
*   Use a database (e.g., PostgreSQL, MySQL) to store chat history and user data.
    *   Persistent storage of chat history across sessions.
    *   Implementation of user accounts and personalized experiences.
