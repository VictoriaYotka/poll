defmodule PollWeb.PollLive do
  use PollWeb, :live_view
  alias Poll.{Polls, Accounts}
  alias Poll.Accounts.User
  alias PollWeb.Helpers

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

    polls = Polls.list_all_polls()

    {:ok,
     assign(socket,
       polls: polls,
       current_user_id: current_user_id,
       sort_by_date_order: :desc,
       sort_by_popularity_order: :desc,
       form: to_form(%{}),
       user_query: "",
       author_filter_applied: false,
       page_title: "Introduct Polls: Main"
     )}
  end

  def handle_event("redirect", _, socket) do
    {:noreply, push_navigate(socket, to: "/new")}
  end

  def handle_event("filter_by_user_query", %{"user_query" => user_query}, socket) do
    Process.send_after(self(), {:filter_by_user_query, user_query}, 500)
    {:noreply, assign(socket, user_query: user_query, author_filter_applied: false)}
  end

  def handle_event("clear_user_query", _params, socket) do
    {:noreply, assign(socket, polls: Polls.list_all_polls(), user_query: "")}
  end

  def handle_event("form_submit", %{"user_query" => user_query}, socket) do
    {:noreply,
     assign(socket, polls: Polls.list_all_polls(%{query: user_query}), user_query: user_query)}
  end

  def handle_event("sort_by_date", _params, socket) do
    new_sort_by_date_order = toggle_sort_order(socket.assigns.sort_by_date_order)
    polls = Polls.list_all_polls(%{sort: :date, direction: new_sort_by_date_order})

    {:noreply, assign(socket, polls: polls, sort_by_date_order: new_sort_by_date_order)}
  end

  def handle_event("sort_by_popularity", _params, socket) do
    new_sort_by_popularity_order = toggle_sort_order(socket.assigns.sort_by_popularity_order)
    polls = Polls.list_all_polls(%{sort: :popularity, direction: new_sort_by_popularity_order})

    {:noreply,
     assign(socket, polls: polls, sort_by_popularity_order: new_sort_by_popularity_order)}
  end

  def handle_event("filter_by_author(me)", _params, socket) do
    author_filter_applied? = socket.assigns.author_filter_applied

    polls =
      if !author_filter_applied? do
        Polls.list_polls_by_user(socket.assigns.current_user_id)
      else
        Polls.list_all_polls()
      end

    {:noreply,
     assign(socket, polls: polls, author_filter_applied: !author_filter_applied?, user_query: "")}
  end

  def handle_info({:filter_by_user_query, user_query}, socket) do
    polls = Polls.list_all_polls(%{query: user_query})
    {:noreply, assign(socket, polls: polls)}
  end

  defp toggle_sort_order(:desc), do: :asc
  defp toggle_sort_order(:asc), do: :desc

  def render(assigns) do
    ~H"""
    <section class="container mx-auto px-4 py-8">
      <div class="flex flex-col md:flex-row items-center gap-8 md:gap-16">
        <div class="w-full md:w-1/2 flex justify-center md:justify-start">
          <img src={~p"/images/logo.png"} alt="Our Polls Logo" class="max-w-xs md:max-w-full" />
        </div>

        <div class="text-center md:text-left w-full md:w-1/2">
          <h1 class="text-2xl md:text-4xl text-zinc-900 mb-4">
            Engage, Discover, Decide with Us!
          </h1>
        </div>
      </div>
      <p class="mb-6 text-lg md:text-xl text-zinc-700 leading-relaxed">
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

    <div class="flex flex-col md:flex-row items-center md:items-baseline justify-between mb-6 p-4 bg-gray-100 shadow-lg">
      <.form
        for={@form}
        phx-change="filter_by_user_query"
        phx-submit="form_submit"
        class="w-full md:w-1/2"
      >
        <div class="relative w-full mb-4 md:mb-0">
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

        <div>
          <button phx-click="filter_by_author(me)" class="flex items-center gap-1 hover:scale-110 focus:scale-110 transition-transform">
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
    <% end %>

    <%= if @author_filter_applied do %>
      <div class="flex items-baseline gap-16 mb-6">
        <p>
          <strong>My polls:</strong>
        </p>
        <button
          phx-click="filter_by_author(me)"
          class="flex items-center gap-2 hover:scale-110 focus:scale-110 transition-transform"
        >
          <span>Show all</span>
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
    <% end %>

    <div>
      <div class="polls">
        <%= if @polls == [] do %>
          <p>No polls available.</p>
        <% else %>
          <p>Total: <%= length(@polls) %></p>
          <%= for %{poll: poll, user: user, vote_count: vote_count} <- @polls do %>
            <div class="poll mb-4">
              <h2>
                <.link href={~p"/#{poll.id}"}>
                  <%= poll.title %>
                </.link>
              </h2>
              <p><%= poll.description %></p>
              <p>Author: <%= Helpers.extract_username_from_email(user.email) %></p>
              <p>Votes: <%= vote_count %></p>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
