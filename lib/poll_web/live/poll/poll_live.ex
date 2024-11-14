defmodule PollWeb.PollLive do
  use PollWeb, :live_view
  alias Poll.{Polls, Accounts}
  alias Poll.Accounts.User
  alias PollWeb.Helpers

  @limit 3

  def mount(_params, session, socket) do
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

    if connected?(socket), do: Phoenix.PubSub.subscribe(Poll.PubSub, "polls:updates")

    socket =
      socket
      |> assign(
        polls: [],
        offset: 0,
        current_user_id: current_user_id,
        sort_by_date_order: :desc,
        sort_by_popularity_order: :desc,
        sort: :date,
        direction: :desc,
        form: to_form(%{}),
        user_query: "",
        author_filter_applied: false,
        page_number: 1,
        page_title: "Introduct Polls: Main"
      )
      |> load_polls()

    {:ok, socket}
  end

  def handle_event("redirect", _, socket) do
    {:noreply, push_navigate(socket, to: "/new")}
  end

  def handle_event("filter_by_user_query", %{"user_query" => user_query}, socket) do
    Process.send_after(self(), {:filter_by_user_query, user_query}, 500)

    {:noreply,
     socket
     |> assign(polls: [], offset: 0, user_query: user_query, author_filter_applied: false)
     |> load_polls()}
  end

  def handle_event("clear_user_query", _params, socket) do
    {:noreply,
     socket
     |> assign(polls: [], offset: 0, user_query: "")
     |> load_polls()}
  end

  def handle_event("form_submit", %{"user_query" => user_query}, socket) do
    {:noreply,
     socket
     |> assign(polls: [], offset: 0, user_query: user_query)
     |> load_polls()}
  end

  def handle_event("sort_by_date", _params, socket) do
    new_sort_by_date_order = toggle_sort_order(socket.assigns.sort_by_date_order)

    {:noreply,
     socket
     |> assign(
       polls: [],
       offset: 0,
       user_query: "",
       sort: :date,
       direction: new_sort_by_date_order,
       sort_by_date_order: new_sort_by_date_order,
       sort_by_popularity_order: :desc
     )
     |> load_polls()}
  end

  def handle_event("sort_by_popularity", _params, socket) do
    new_sort_by_popularity_order = toggle_sort_order(socket.assigns.sort_by_popularity_order)

    {:noreply,
     socket
     |> assign(
       polls: [],
       offset: 0,
       user_query: "",
       sort: :popularity,
       direction: new_sort_by_popularity_order,
       sort_by_popularity_order: new_sort_by_popularity_order,
       sort_by_date_order: :desc
     )
     |> load_polls()}
  end

  def handle_event("filter_by_author(me)", _params, socket) do
    author_filter_applied? = socket.assigns.author_filter_applied

    {:noreply,
     socket
     |> assign(
       polls: [],
       offset: 0,
       author_filter_applied: !author_filter_applied?,
       user_query: ""
     )
     |> load_polls()}
  end

  def handle_event("load_more_polls", _params, socket) do
    {:noreply, load_polls(socket)}
  end

  def handle_info({:filter_by_user_query, _user_query}, socket) do
    {:noreply, socket |> load_polls()}
  end

  def handle_info({:new_poll, poll}, socket) do
    {:noreply,
     socket |> assign(polls: [poll | socket.assigns.polls], offset: socket.assigns.offset + 1)}
  end

  def handle_info({:vote_cast, updated_poll}, socket) do
    updated_polls =
      Enum.map(socket.assigns.polls, fn poll ->
        if poll.id == updated_poll.id, do: updated_poll, else: poll
      end)

    {:noreply, socket |> assign(polls: updated_polls)}
  end

  defp toggle_sort_order(:desc), do: :asc
  defp toggle_sort_order(:asc), do: :desc

  defp load_polls(socket) do
    polls =
      if socket.assigns.author_filter_applied do
        Polls.list_polls_by_user(socket.assigns.current_user_id, socket.assigns.offset, @limit)
      else
        Polls.list_all_polls(
          socket.assigns.sort,
          socket.assigns.direction,
          socket.assigns.user_query,
          socket.assigns.offset,
          @limit
        )
      end

    assign(socket, polls: socket.assigns.polls ++ polls, offset: socket.assigns.offset + @limit)
  end

  def render(assigns) do
    ~H"""
    <button
      id="back-to-top"
      phx-hook="BackToTop"
      class="fixed bottom-24 right-5 md:right-[2%] lg:right-16 xl:right-[16%] 2xl:right-[20%] z-10 bg-indigo-500 text-white p-6 rounded-full shadow-lg hover:bg-indigo-800 hover:scale-110 transition-transform hidden"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        stroke="white"
        fill="white"
        class="-rotate-90"
        viewBox="0 0 24 24"
      >
        <path d="M10.024 4h6.015l7.961 8-7.961 8h-6.015l7.961-8-7.961-8zm-10.024 16h6.015l7.961-8-7.961-8h-6.015l7.961 8-7.961 8z" />
      </svg>
    </button>

    <section class="container max-w-3xl mx-auto px-4 pt-2 pb-12">
      <div class="flex flex-col md:flex-row items-center gap-8 md:gap-16 mb-6">
        <div class="w-1/2 sm:w-1/3">
          <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 122.9 85.6" class="mb-4">
            <g>
              <path
                class="st0"
                d="M7.5,0h107.9c4.1,0,7.5,3.4,7.5,7.5v70.6c0,4.1-3.4,7.5-7.5,7.5H7.5c-4.1,0-7.5-3.4-7.5-7.5V7.5 C0,3.4,3.4,0,7.5,0L7.5,0z M69.9,63.3h28.5v4H69.9V63.3L69.9,63.3z M69.9,53.1H109v4H69.9V53.1L69.9,53.1z M92.1,35h5.6 c0.3,0,0.5,0.2,0.5,0.5v11c0,0.3-0.2,0.5-0.5,0.5h-5.6c-0.3,0-0.5-0.2-0.5-0.5v-11C91.6,35.3,91.8,35,92.1,35L92.1,35L92.1,35z M70.5,28.3h5.6c0.3,0,0.5,0.2,0.5,0.5v17.8c0,0.3-0.2,0.5-0.5,0.5h-5.6c-0.3,0-0.5-0.2-0.5-0.5V28.8 C69.9,28.5,70.2,28.3,70.5,28.3L70.5,28.3L70.5,28.3L70.5,28.3z M81.3,24.5h5.6c0.3,0,0.5,0.2,0.5,0.5v21.6c0,0.3-0.2,0.5-0.5,0.5 h-5.6c-0.3,0-0.5-0.2-0.5-0.5V25C80.8,24.7,81,24.5,81.3,24.5L81.3,24.5L81.3,24.5z M39.3,48.2l17,0.3c0,6.1-3,11.7-8,15.1 L39.3,48.2L39.3,48.2L39.3,48.2z M37.6,45.3l-0.2-19.8l0-1.3l1.3,0.1h0h0c1.6,0.1,3.2,0.4,4.7,0.8c1.5,0.4,2.9,1,4.3,1.7 c6.9,3.6,11.7,10.8,12.1,19l0.1,1.3l-1.3,0l-19.7-0.6l-1.1,0L37.6,45.3L37.6,45.3L37.6,45.3z M39.8,26.7L40,44.1l17.3,0.5 c-0.7-6.8-4.9-12.7-10.7-15.8c-1.2-0.6-2.5-1.1-3.8-1.5C41.7,27.1,40.8,26.9,39.8,26.7L39.8,26.7L39.8,26.7z M35.9,47.2L45.6,64 c-3,1.7-6.3,2.6-9.7,2.6c-10.7,0-19.4-8.7-19.4-19.4c0-10.4,8.2-19,18.6-19.4L35.9,47.2L35.9,47.2L35.9,47.2z M115.6,14.1H7.2v64.4 h108.4V14.1L115.6,14.1L115.6,14.1z"
              />
            </g>
          </svg>
          <h2 class="text-center text-l md:text-xl text-zinc-900 mb-4 md:mb-0">Introduct Polls</h2>
        </div>

        <div class="mb-2 md:mb-4 text-center md:text-left w-full md:w-1/2">
          <h1 class="text-2xl md:text-4xl text-zinc-900 mb-4 md:mb-0">
            Engage, Discover, Decide with Us!
          </h1>
        </div>
      </div>
      <p class="mb-6 text-md md:text-xl text-zinc-700 leading-relaxed">
        We believe in the power of shared opinions. With our polls, you have a voice in decisions that matter. Our platform
        makes it easy to create, vote, and see results instantly. Whether for your team, your community, or just for fun,
        our polls bring people together in a single, interactive space.
      </p>
      <button
        phx-click="redirect"
        class="flex items-center gap-4 mx-auto px-6 py-3 bg-indigo-500 text-white rounded-lg hover:scale-110 focus:scale-110 transition-transform"
      >
        <span class="font-semibold font-montserrat text-lg">Create Your Poll</span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          stroke="white"
          fill="white"
          viewBox="0 0 24 24"
        >
          <path d="M10.024 4h6.015l7.961 8-7.961 8h-6.015l7.961-8-7.961-8zm-10.024 16h6.015l7.961-8-7.961-8h-6.015l7.961 8-7.961 8z" />
        </svg>
      </button>
    </section>

    <div class="flex flex-col items-center justify-between mb-6 p-4 bg-gray-100 shadow-lg">
      <.form
        for={@form}
        phx-change="filter_by_user_query"
        phx-submit="form_submit"
        class="w-full md:w-1/2 mb-4"
      >
        <div class="relative w-full">
          <input
            name="user_query"
            value={@user_query}
            type="text"
            placeholder="Search polls..."
            class="w-full px-8 py-2 text-gray-700 bg-white border border-indigo-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-300"
          />
          <svg
            width="24"
            height="24"
            stroke="currentColor"
            class="absolute top-2.5 left-2 w-5 h-5"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="m15.985 17.031c-1.479 1.238-3.384 1.985-5.461 1.985-4.697 0-8.509-3.812-8.509-8.508s3.812-8.508 8.509-8.508c4.695 0 8.508 3.812 8.508 8.508 0 2.078-.747 3.984-1.985 5.461l4.749 4.75c.146.146.219.338.219.531 0 .587-.537.75-.75.75-.192 0-.384-.073-.531-.22zm-5.461-13.53c-3.868 0-7.007 3.14-7.007 7.007s3.139 7.007 7.007 7.007c3.866 0 7.007-3.14 7.007-7.007s-3.141-7.007-7.007-7.007zm1.991 6.999c0-.552.448-1 1-1s1 .448 1 1-.448 1-1 1-1-.448-1-1zm-3 0c0-.552.448-1 1-1s1 .448 1 1-.448 1-1 1-1-.448-1-1zm-3 0c0-.552.448-1 1-1s1 .448 1 1-.448 1-1 1-1-.448-1-1z"
              fill-rule="nonzero"
            />
          </svg>
        </div>
      </.form>

      <div class="flex flex-wrap gap-4 justify-center items-center">
        <div class="flex items-center gap-1">
          <span class="text-sm text-gray-600">Sort by Date:</span>
          <button phx-click="sort_by_date" class="hover:scale-110 transition-transform">
            <%= if @sort_by_date_order == :desc do %>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="transition-transform transform rotate-0"
                width="24"
                height="24"
                viewBox="0 0 24 24"
              >
                <path d="M12 3.202l3.839 4.798h-7.678l3.839-4.798zm0-3.202l-8 10h16l-8-10zm8 14h-16l8 10 8-10z" />
              </svg>
            <% else %>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="transition-transform transform rotate-180"
                width="24"
                height="24"
                viewBox="0 0 24 24"
              >
                <path d="M12 0l-8 10h16l-8-10zm3.839 16l-3.839 4.798-3.839-4.798h7.678zm4.161-2h-16l8 10 8-10z" />
              </svg>
            <% end %>
          </button>
        </div>

        <div class="flex items-center gap-1">
          <span class="text-sm text-gray-600">Sort by Popularity:</span>
          <button phx-click="sort_by_popularity">
            <%= if @sort_by_popularity_order == :desc do %>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="transition-transform transform rotate-0"
                width="24"
                height="24"
                viewBox="0 0 24 24"
              >
                <path d="M12 3.202l3.839 4.798h-7.678l3.839-4.798zm0-3.202l-8 10h16l-8-10zm8 14h-16l8 10 8-10z" />
              </svg>
            <% else %>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="transition-transform transform rotate-180"
                width="24"
                height="24"
                viewBox="0 0 24 24"
              >
                <path d="M12 0l-8 10h16l-8-10zm3.839 16l-3.839 4.798-3.839-4.798h7.678zm4.161-2h-16l8 10 8-10z" />
              </svg>
            <% end %>
          </button>
        </div>

        <%= if @current_user_id do %>
          <div>
            <button
              phx-click="filter_by_author(me)"
              class="flex items-center gap-1 hover:scale-110 focus:scale-110 transition-transform"
            >
              <%= if @author_filter_applied do %>
                <span class="text-sm text-gray-600">Show all</span>
              <% else %>
                <span class="text-sm text-gray-600">Show mine</span>
              <% end %>
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
                <path d="M22.906 2.841c1.104-2.412-7.833-2.841-10.907-2.841-2.934 0-12.01.429-10.906 2.841.508 1.11 8.907 12.916 8.907 12.916v5.246l4 2.997v-8.243s8.398-11.806 8.906-12.916zm-10.901-.902c4.243 0 8.144.575 8.144 1.226s-3.9 1.18-8.144 1.18-8.042-.528-8.042-1.18 3.799-1.226 8.042-1.226z" />
              </svg>
            </button>
          </div>
        <% end %>
      </div>
    </div>

    <%= if @user_query != "" do %>
      <div class="flex items-baseline gap-16 mb-6">
        <p>
          <strong>Search:</strong> "<%= @user_query %>"
        </p>
        <button
          phx-click="clear_user_query"
          class="flex items-center gap-2 hover:scale-110 focus:scale-110 transition-transform"
        >
          <span>Clear</span>
          <svg
            width="16"
            height="16"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path d="m12 10.93 5.719-5.72c.146-.146.339-.219.531-.219.404 0 .75.324.75.749 0 .193-.073.385-.219.532l-5.72 5.719 5.719 5.719c.147.147.22.339.22.531 0 .427-.349.75-.75.75-.192 0-.385-.073-.531-.219l-5.719-5.719-5.719 5.719c-.146.146-.339.219-.531.219-.401 0-.75-.323-.75-.75 0-.192.073-.384.22-.531l5.719-5.719-5.72-5.719c-.146-.147-.219-.339-.219-.532 0-.425.346-.749.75-.749.192 0 .385.073.531.219z" />
          </svg>
        </button>
      </div>
    <% else %>
      <div class="flex items-baseline gap-16 mb-6">
        <p>
          <strong>Polls shown: </strong>
        </p>
        <%= if @author_filter_applied do %>
          <button
            phx-click="filter_by_author(me)"
            class="flex items-center gap-2 hover:scale-110 focus:scale-110 transition-transform"
          >
            <span>Published by me</span>
            <svg
              width="16"
              height="16"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path d="m12 10.93 5.719-5.72c.146-.146.339-.219.531-.219.404 0 .75.324.75.749 0 .193-.073.385-.219.532l-5.72 5.719 5.719 5.719c.147.147.22.339.22.531 0 .427-.349.75-.75.75-.192 0-.385-.073-.531-.219l-5.719-5.719-5.719 5.719c-.146.146-.339.219-.531.219-.401 0-.75-.323-.75-.75 0-.192.073-.384.22-.531l5.719-5.719-5.72-5.719c-.146-.147-.219-.339-.219-.532 0-.425.346-.749.75-.749.192 0 .385.073.531.219z" />
            </svg>
          </button>
        <% else %>
          <span>All</span>
        <% end %>
      </div>
    <% end %>

    <div id="polls" phx-hook="InfiniteScroll" class="mx-auto p-4">
      <%= if @polls == [] do %>
        <p class="text-gray-500 text-lg">No polls available.</p>
      <% else %>
        <%= for %{poll: poll, user: user, vote_count: vote_count} <- @polls do %>
          <div class="shadow-md rounded-lg p-6 mb-6 hover:scale-105 hover:shadow-xl transition-transform">
            <.link
              href={~p"/#{poll.id}"}
              class="flex flex-col md:flex-row md:items-center gap-8 md:gap-16"
            >
              <div class="md:w-3/4">
                <h2 class="mb-2 text-lg md:text-2xl text-indigo-800">
                  <%= poll.title %>
                </h2>
                <p class="mb-2 text-sm sm:text-md">
                  <%= poll.description %>
                </p>
              </div>
              <div class="md:w-1/4">
                <p class="text-sm md:text-md text-gray-500">
                  <span class="me-1 text-3xl text-indigo-800"><%= vote_count %></span> votes
                </p>
                <p class="text-sm md:text-md text-gray-500">
                  Author: <%= Helpers.extract_username_from_email(user.email) %>
                </p>
                <p class="text-sm md:text-md text-gray-500">
                  Publication date: <%= Helpers.format_datetime(poll.inserted_at) %>
                </p>
              </div>
            </.link>
          </div>
        <% end %>

        <p class="text-lg">Total: <%= length(@polls) %></p>
      <% end %>
    </div>
    """
  end
end
