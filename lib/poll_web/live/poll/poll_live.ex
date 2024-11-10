defmodule PollWeb.PollLive do
  use PollWeb, :live_view
  alias Poll.Polls
  alias PollWeb.Helpers

  def mount(_params, _session, socket) do
    polls = Polls.list_all_polls()

    {:ok, assign(socket, polls: polls)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Polls</h1>

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
