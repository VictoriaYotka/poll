defmodule PollWeb.SinglePollLive do
  use PollWeb, :live_view
  alias Poll.{Polls, Accounts}
  alias PollWeb.Helpers

  def mount(%{"id" => poll_id}, session, socket) do
    current_user_id = Accounts.get_user_by_session_token(session["user_token"]).id
    poll = Polls.get_poll_by_id(poll_id)
    has_voted = Polls.has_user_voted?(current_user_id, poll_id)

    {:ok, assign(socket, current_user_id: current_user_id, poll_id: poll_id, poll: poll, has_voted: has_voted)}
  end

  def handle_event("vote", %{"option_id" => option_id}, socket) do
    case Polls.create_vote(%{
           user_id: socket.assigns.current_user_id,
           poll_id: socket.assigns.poll.id,
           option_id: option_id
         }) do
      {:ok, updated_option} ->
        {:noreply, assign(
         socket,
           option_id: updated_option.id,
           poll: Polls.get_poll_by_id(socket.assigns.poll_id),
           has_voted: true
         )}

      {:error, :already_voted} ->
        {:noreply, assign(socket, error_message: "You have already voted")}

      {:error, :option_not_found} ->
        {:noreply, assign(socket, error_message: "Option not found")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
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

        <%= if @has_voted do %>
          <%= if length(option.votes) >= 1 do %>
            <p>Voters: <%= PollWeb.Helpers.make_usernames_list(option.votes) %></p>
          <% end %>
        <% else %>
          <button phx-click="vote" phx-value-option_id={option.id}>Vote</button>
        <% end %>
      </div>
    <% end %>
    """
  end
end
