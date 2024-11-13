# Elixir LiveView Poll Application

## Overview

This is a simple polling application built with **Phoenix LiveView**. It allows users to create polls, vote on them, and see real-time updates on poll results. The app is mobile-friendly (designed with a mobile-first approach) and uses **Tailwind CSS** for styling and **Chart.js** for dynamic chart visualizations of poll results. 

The solution includes a Dockerized PostgreSQL database for persistent storage of users, polls, and votes, and all functionality runs locally with `mix phx.server`.

## Features

- **User Registration**: Users can register by entering a username.
- **Create Polls**: Registered users can create new polls.
- **Vote in Polls**: Users can vote in any existing poll and see instant, real-time results.
- **One Vote per Poll**: Each user can only vote once in each poll.
- **Real-Time Updates**: LiveView provides real-time poll result updates without refreshing the page.
- **Mobile-First, Responsive Design**: The UI adapts for both mobile and desktop, using Tailwind CSS.
- **Data Visualization with Chart.js**: Poll results are visualized with responsive charts.
- **JS Hooks**: JavaScript hooks are used for finer client-side interactivity.
- **Phoenix PubSub for Broadcasts**: PubSub ensures that vote updates are broadcasted in real-time to all connected clients.

## Prerequisites

- **Docker & Docker Compose**: Ensure Docker is installed to run the database container.
- **Elixir and Phoenix**: The app was developed using Elixir and the Phoenix framework.

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/elixir-liveview-polling.git
cd elixir-liveview-polling
```

### 2. Database Setup with Docker

This project includes a docker-compose.yml file to simplify database setup.

Start the Database:

```bash
docker-compose up -d
```

Run Database Migrations and Seed Data:

```bash
    mix ecto.create
    mix ecto.migrate
    mix run priv/repo/seeds.exs
```

### 3. Install Dependencies

Install Elixir and JavaScript dependencies:

```bash
mix deps.get
cd assets && npm install
```

### 4. Run the Server

Start the Phoenix server:

```bash
mix phx.server
```

The application will be available at [http://localhost:4000](http://localhost:4000).

## Application Usage

1. **Register** by entering a username on the home page.
2. **Create Polls** by navigating to the "New Poll" page.
3. **Vote in Polls** by selecting an option in any poll.
4. **View Real-Time Results** which are updated instantly using LiveView and Phoenix PubSub.
5. **View Poll Results in Charts** rendered by Chart.js.

## Key Design and Implementation Details

### JavaScript Hooks
- **Real-Time Chart Updates**: JS hooks work with LiveView to trigger Chart.js updates dynamically as poll results change.
- **Custom Interactivity**: JavaScript hooks enhance interactivity, adding custom client-side behavior for animations and chart updates.

### Responsive Design (Mobile-First)
- **Tailwind CSS**: A mobile-first approach with Tailwind CSS ensures that the app is responsive and adapts well to different screen sizes.

### Chart.js Integration
- **Poll Result Visualization**: Chart.js visualizes poll results in dynamic, real-time bar charts, enhancing the user experience and making data interpretation easy.

### Phoenix PubSub for Real-Time Updates
- **Broadcasting Poll Updates**: Phoenix PubSub is used to broadcast new votes in real-time. When a user submits a vote, a message is sent to all connected clients, updating poll results instantly.
- **Seamless Client Syncing**: Using PubSub with LiveView means clients see live updates as votes are cast, without requiring full-page reloads.

### Dockerization
- **Persistent Database Setup**: The PostgreSQL database runs in a Docker container, isolated from your local environment for ease of use.
- **Automated Database Initialization**: `docker-compose` along with `mix ecto` commands handle migrations and seed data setup, streamlining project setup.

## Project Structure

- **Phoenix Contexts** organize the code for polls, users, and votes into manageable, modular components.
- **Ecto Schemas** handle data persistence for users, polls, and votes with validations to enforce business rules.
- **JS Hooks and LiveView Components** manage real-time updates and user interactions, optimizing the front-end experience.

## Testing

Core functionality, such as poll creation, voting, and result display, is covered by unit tests. To run tests:

```bash
mix test
```

## Design Decisions & Trade-Offs

- **LiveView Over Traditional SPA**: LiveView was chosen for real-time updates without requiring a full SPA framework like React or Vue. This reduces complexity and keeps the application server-rendered.
- **Chart.js for Visualization**: Chart.js was used for simplicity and responsive chart rendering, although other libraries could offer more customization.
- **Single Vote Limit**: The application limits each user to a single vote per poll. This was enforced at the database level for consistency.

## Dependencies

The project uses the following dependencies:

- **Elixir**: "~> 1.16.0"
- **Phoenix**: "~> 1.7.12"
- **Phoenix Live View**: "~> 0.20.2"
- **Chart.js**: "^4.4.6" for rendering dynamic poll result charts

## License

This project is licensed under the MIT License.
