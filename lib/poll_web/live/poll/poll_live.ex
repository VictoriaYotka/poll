defmodule PollWeb.PollLive do
  use PollWeb, :live_view
  alias Poll.{Polls, Accounts}
  alias Poll.Accounts.User
  alias PollWeb.Helpers
  alias PollWeb.IconComponent

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
        date_svg_rotation_class: "rotate-0",
        popularity_svg_rotation_class: "rotate-0",
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
       date_svg_rotation_class: toggle_svg_rotation(socket.assigns.date_svg_rotation_class),
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
       popularity_svg_rotation_class:
         toggle_svg_rotation(socket.assigns.popularity_svg_rotation_class),
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

  defp toggle_svg_rotation("rotate-0"), do: "rotate-180"
  defp toggle_svg_rotation("rotate-180"), do: "rotate-0"

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
    <%!-- Back to top button --%>
    <button
      id="back-to-top"
      phx-hook="BackToTop"
      class="fixed bottom-24 right-5 md:right-[2%] lg:right-12 xl:right-[12%] 2xl:right-[16%] z-10 bg-indigo-500 text-white p-6 rounded-full shadow-lg hover:bg-indigo-800 hover:scale-110 transition-transform hidden"
    >
      <IconComponent.render
        id="back-to-top-double_arrow"
        name="double_arrow"
        width="24"
        height="24"
        fill="white"
        class="-rotate-90"
        aria-label="go to top"
      />
    </button>

    <section class="max-w-3xl mx-auto px-4 pt-2 pb-12">
      <div class="flex flex-col md:flex-row items-center gap-8 md:gap-16 mb-6">
        <div class="w-1/2 sm:w-1/3">
        <IconComponent.render
          id="logo-icon"
          name="logo"
          width="full"
          height="full"
          viewBox="0 0 122.9 85.6"
          class="mb-4"
          aria-label="logo"
        />
          <h1 class="text-center text-l md:text-xl text-zinc-900 font-montserrat mb-4 md:mb-0">
            Introduct Polls
          </h1>
        </div>

        <div class="mb-2 md:mb-4 text-center md:text-left w-full md:w-1/2">
          <strong class="text-2xl md:text-4xl text-zinc-900 mb-4 md:mb-0">
            Engage, Discover, Decide with Us!
          </strong>
        </div>
      </div>
      <p class="mb-6 text-md md:text-xl text-zinc-700 leading-relaxed">
        We believe in the power of shared opinions. With our polls, you have a voice in decisions that matter. Our platform
        makes it easy to create, vote, and see results instantly. Whether for your team, your community, or just for fun,
        our polls bring people together in a single, interactive space.
      </p>
      <button
        phx-click="redirect"
        class="flex items-center gap-4 mx-auto px-6 py-3 bg-indigo-500 text-white font-montserrat rounded-lg hover:scale-110 focus:scale-110 transition-transform"
      >
        <span class="font-semibold font-montserrat text-lg">Create Your Poll</span>
        <IconComponent.render
        id="create-link-double_arrow"
          name="double_arrow"
          stroke="white"
          fill="white"
          width="24"
          height="24"
          aria-label="redirect to create poll"
        />
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
          <IconComponent.render
            id="search_icon"
            name="search"
            width="24"
            height="24"
            class="absolute top-2.5 left-2 w-5 h-5"
            aria-label="search"
          />
        </div>
      </.form>

      <div class="flex flex-wrap gap-4 justify-center items-center">
        <div class="flex items-center gap-1">
          <span class="text-sm text-gray-600">Sort by Date:</span>
          <button phx-click="sort_by_date" class="hover:scale-110 transition-transform">
            <IconComponent.render
              id="sort-direction-date"
              name="sort-direction"
              stroke="none"
              class={"transition-transform transform #{@date_svg_rotation_class}"}
              aria-label="change sort direction by date"
            />
          </button>
        </div>

        <div class="flex items-center gap-1">
          <span class="text-sm text-gray-600">Sort by Popularity:</span>
          <button phx-click="sort_by_popularity">
            <IconComponent.render
              id="sort-direction-popularity"
              name="sort-direction"
              stroke="none"
              class={"transition-transform transform #{@popularity_svg_rotation_class}"}
              aria-label="change sort direction by popularity"
            />
          </button>
        </div>

        <%= if @current_user_id do %>
          <div>
            <button
              phx-click="filter_by_author(me)"
              class="flex items-center gap-1 font-montserrat hover:scale-110 focus:scale-110 transition-transform"
            >
              <%= if @author_filter_applied do %>
                <span class="text-sm text-gray-600">Show all</span>
              <% else %>
                <span class="text-sm text-gray-600">Show mine</span>
              <% end %>
              <IconComponent.render
                id="filter_icon"
                name="filter"
                stroke="none"
                aria-label="filter by author: show mine/all"
              />
            </button>
          </div>
        <% end %>
      </div>
    </div>

    <%!-- hint --%>
    <%= if @user_query != "" do %>
      <div class="flex items-baseline gap-16 mb-6">
        <p>
          <strong>Search:</strong> "<%= @user_query %>"
        </p>
        <button
          phx-click="clear_user_query"
          class="flex items-center gap-2 font-montserrat hover:scale-110 focus:scale-110 transition-transform"
        >
          <span>Clear</span>
          <IconComponent.render
            id="clear_search_icon"
            name="close"
            width="16"
            height="16"
            aria-label="clear user query"
          />
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
            class="flex items-center gap-2 font-montserrat hover:scale-110 focus:scale-110 transition-transform"
          >
            <span>Published by me</span>
            <IconComponent.render
              id="clear_filter_icon"
              name="close"
              width="16"
              height="16"
              aria-label="clear filter"
            />
          </button>
        <% else %>
          <span>All</span>
        <% end %>
      </div>
    <% end %>

    <%!-- polls lits --%>
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
                <h2 class="mb-2 text-lg md:text-2xl text-indigo-800 font-montserrat">
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
