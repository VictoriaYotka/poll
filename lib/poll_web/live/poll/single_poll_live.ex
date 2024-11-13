defmodule PollWeb.SinglePollLive do
  use PollWeb, :live_view
  alias Poll.{Polls, Accounts}
  alias Poll.Accounts.User
  alias PollWeb.Helpers

  def mount(%{"id" => poll_id}, session, socket) do
    current_user_id =
      case session["user_token"] do
        nil ->
          nil

        token ->
          case Accounts.get_user_by_session_token(token) do
            %User{id: id} -> id
            _ -> nil
          end
      end

    poll = Polls.get_poll_by_id(poll_id)
    has_voted = Polls.has_user_voted?(current_user_id, poll_id)

    Phoenix.PubSub.subscribe(Poll.PubSub, "poll_#{poll_id}")

    {:ok,
     assign(socket,
       current_user_id: current_user_id,
       poll_id: poll_id,
       poll: poll,
       has_voted: has_voted,
       page_title: "Introduct Polls: #{poll.title}"
     )}
  end

  def handle_event("vote", %{"option_id" => option_id}, socket) do
    case Polls.create_vote(%{
           user_id: socket.assigns.current_user_id,
           poll_id: socket.assigns.poll.id,
           option_id: option_id
         }) do
      {:ok, updated_option} ->
        Phoenix.PubSub.broadcast(Poll.PubSub, "poll_#{socket.assigns.poll_id}", %{
          event: "vote_updated",
          payload: updated_option
        })

        {:noreply,
         assign(socket,
           option_id: updated_option.id,
           poll: Polls.get_poll_by_id(socket.assigns.poll_id),
           has_voted: true
         )}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_info(%{event: "vote_updated", payload: new_data}, socket) do
    {:noreply,
     assign(socket,
       poll: Polls.get_poll_by_id(socket.assigns.poll_id),
       updated_votes: new_data
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col md:flex-row md:items-center gap-2 md:gap-10 py-4 mb-8">
      <div class="md:w-3/4 md:pe-6 md:border-r-2 md:border-indigo">
        <h2 class="mb-2 text-xl sm:text-2xl text-indigo-800"><%= @poll.title %></h2>
        <p class="mb-2 text-md sm:text-lg md:text-xl"><%= @poll.description %></p>
      </div>
      <div class="md:w-1/4">
        <p class="text-sm md:text-md text-gray-500">
          <span class="me-1 text-3xl text-indigo-800"><%= length(@poll.votes) %></span> votes
        </p>
        <p class="text-sm md:text-md text-gray-500">
          Author: <%= Helpers.extract_username_from_email(@poll.user.email) %>
        </p>

        <p class="text-sm md:text-md text-gray-500">
          Publication date: <%= Helpers.format_datetime(@poll.inserted_at) %>
        </p>
      </div>
    </div>

    <%= if @current_user_id do %>
      <%= if @has_voted do %>
        <div
          id="canvas-container"
          phx-update="ignore"
          phx-hook="VoteChart"
          data-labels={Jason.encode!(Enum.map(@poll.options, & &1.text))}
          data-votes={Jason.encode!(Enum.map(@poll.options, &length(&1.votes)))}
          data-voters={
            Jason.encode!(
              Enum.map(@poll.options, fn option ->
                PollWeb.Helpers.make_usernames_list(option.votes)
              end)
            )
          }
          class="chart-container md:w-[71%]"
        >
          <canvas id="voteChart"></canvas>
        </div>
      <% else %>
        <%= for option <- @poll.options do %>
          <div class="md:flex md:justify-between md:items-baseline md:w-[71%] mb-6 p-4 shadow-lg rounded-lg  bg-neutral-100 hover:shadow-xl transition-transform">
            <h3 class="text-lg font-semibold text-gray-800"><%= option.text %></h3>
            <button
              phx-click="vote"
              phx-value-option_id={option.id}
              class="mt-4 px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 hover:scale-110  transition-transform"
            >
              Vote
            </button>
          </div>
        <% end %>
      <% end %>
    <% else %>
      <p class="md:w-[70%] mb-2 text-sm sm:text-md md:text-lg border border-red-900 p-8 rounded text-red-900 shadow-sm">
        Please
        <.link
          href={~p"/users/log_in"}
          class="inline-block font-bold font-montserrat shadow-sm underline decoration-dotted hover:decoration-solid"
        >
          log in
        </.link>
        to cast your vote and see results
      </p>
    <% end %>
    """
  end
end
