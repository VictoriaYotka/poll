defmodule PollWeb.PollLive do
  use PollWeb, :live_view
  alias Poll.{Polls, Accounts}
  alias PollWeb.Helpers

  def mount(_params, session, socket) do
    current_user_id = Accounts.get_user_by_session_token(session["user_token"]).id
    polls = Polls.list_all_polls()

    {:ok, assign(socket, polls: polls, current_user_id: current_user_id)}
  end

  def handle_event("filter_by_author(me)", _params, socket) do
    my_polls = Polls.list_polls_by_user(socket.assigns.current_user_id)

    {:noreply, assign(socket, polls: my_polls)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <button phx-click="filter_by_author(me)" >Show mine</button>

      <div class="polls">
        <%= if @polls == [] do %>
          <p>No polls available.</p>
        <% else %>
          <%= for poll <- @polls do %>
            <div class="poll mb-4">
              <h2>
                <.link href={~p"/#{poll.id}"}>
                  <%= poll.title %>
                </.link>
              </h2>
              <p><%= poll.description %></p>
              <p>Author: <%= Helpers.extract_username_from_email(poll.user.email) %></p>
              <p>Votes: <%= length(poll.votes) %></p>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
