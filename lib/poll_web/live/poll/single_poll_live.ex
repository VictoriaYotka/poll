defmodule PollWeb.SinglePollLive do
  use PollWeb, :live_view
  alias Poll.{Polls, Accounts}
  alias Poll.Accounts.User
  alias PollWeb.IconComponent
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
        <h1 class="mb-2 text-xl sm:text-2xl text-main_accent-800 font-montserrat">
          <%= @poll.title %>
        </h1>
        <p class="mb-2 text-md sm:text-lg md:text-xl"><%= @poll.description %></p>
      </div>
      <div class="md:w-1/4">
        <p class="text-sm md:text-md text-gray-500">
          <span class="ms-1 me-2 text-3xl text-main_accent-800"><%= length(@poll.votes) %></span>
          votes
        </p>
        <div class="flex gap-2">
          <IconComponent.render
            id="user_icon"
            name="user"
            fill="white"
            class="stroke-bright_accent"
            aria-label="current user icon"
          />
          <p class="text-sm md:text-md text-gray-500">
            <%= Helpers.extract_username_from_email(@poll.user.email) %>
          </p>
        </div>
        <div class="flex gap-2">
          <IconComponent.render
            id="calendar"
            name="calendar"
            fill="white"
            class="stroke-bright_accent"
            aria-label="current user icon"
          />
          <p class="text-sm md:text-md text-gray-500">
            <%= Helpers.format_datetime(@poll.inserted_at) %>
          </p>
        </div>
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
          <div class="flex flex-wrap justify-between items-baseline md:w-[71%] mb-6 p-4 shadow-lg rounded-lg bg-neutral-100 hover:shadow-xl transition-transform">
            <strong class="text-lg font-semibold text-gray-800"><%= option.text %></strong>
            <button
              phx-click="vote"
              phx-value-option_id={option.id}
              class="mt-4 ml-auto px-4 py-2 bg-main_accent-600 text-white font-montserrat rounded-md hover:bg-main_accent-800 hover:scale-110 transition-transform"
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
