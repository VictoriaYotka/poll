defmodule PollWeb.SinglePollLive do
  use PollWeb, :live_view
  alias Poll.Polls
  alias PollWeb.Helpers

  def mount(%{"id" => poll_id}, _session, socket) do
    poll = Polls.get_poll_by_id(poll_id)

    {:ok, assign(socket, poll: poll)}
  end

  def render(assigns) do
    ~H"""
    <div class="mb-4">
      <h2><%= @poll.title %></h2>
      <p><%= @poll.description %></p>
      <p>Author: <%= Helpers.extract_username_from_email(@poll.user.email) %></p>
      <p>Total votes: <%= length(@poll.votes) %></p>
    </div>
    <%= for option <- @poll.options do %>
      <div class="mb-3">
        <h3><%= option.text %></h3>
        <p>Voters: <%= PollWeb.Helpers.make_usernames_list(option.votes) %></p>
      </div>
    <% end %>
    """
  end
end
