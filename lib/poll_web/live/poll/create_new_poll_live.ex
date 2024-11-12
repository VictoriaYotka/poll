defmodule PollWeb.CreateNewPollLive do
  use PollWeb, :live_view

  alias Poll.{Polls, Accounts}
  alias Poll.Polls.Poll

  def mount(_params, session, socket) do
    current_user_id = Accounts.get_user_by_session_token(session["user_token"]).id
    changeset = Polls.change_poll(%Poll{})

    {:ok,
     assign(socket,
       form: to_form(changeset),
       current_user_id: current_user_id,
       options: [%{text: ""}, %{text: ""}],
       page_title: "Introduct Polls: Create new poll"
     )}
  end

  def handle_event("add_option", _params, socket) do
    options = socket.assigns.options ++ [%{text: ""}]
    {:noreply, assign(socket, options: options)}
  end

  def handle_event("remove_option", %{"index" => index}, socket) do
    options = socket.assigns.options

    updated_options = List.delete_at(options, String.to_integer(index))

    {:noreply, assign(socket, options: updated_options)}
  end

  def handle_event(
        "validate",
        %{"poll" => poll_params, "options" => options},
        %{assigns: %{current_user_id: current_user_id}} = socket
      ) do
    poll_params = Map.put(poll_params, "user_id", current_user_id)

    changeset = Polls.change_poll(%Poll{}, poll_params)

    {:noreply,
     assign(socket,
       form: to_form(changeset),
       options: Enum.map(options, fn {_, option} -> %{text: option["text"]} end)
     )}
  end

  def handle_event(
        "save",
        %{"poll" => poll_params, "options" => options},
        %{assigns: %{current_user_id: current_user_id}} = socket
      ) do
    poll_params = Map.put(poll_params, "user_id", current_user_id)

    with {:ok, poll} <- Polls.create_poll(poll_params),
         {:ok, :all_inserted} <- Polls.create_options(format_options(options, poll.id)) do
      {:noreply, redirect(socket, to: "/#{poll.id}")}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, error_message} when is_binary(error_message) ->
        {:noreply, assign(socket, form: to_form(%Ecto.Changeset{}))}
    end
  end

  defp format_options(options_params, poll_id) do
    options_params
    |> Map.values()
    |> Enum.map(fn option ->
      Map.put(option, "poll_id", poll_id)
    end)
  end

  defp input_name(idx), do: "option #{idx + 1}"

  def render(assigns) do
    ~H"""
    <div class="md:w-3/4 mx-auto p-6 bg-white rounded-lg shadow-md">
      <.form for={@form} phx-change="validate" phx-submit="save">
        <!-- Title and Description Inputs -->
        <div class="mb-4">
          <.input
            type="text"
            field={@form[:title]}
            placeholder="Title"
            class="w-full p-2 rounded-md shadow-sm focus:outline-none"
          />
        </div>
        <div class="mb-6">
          <.input
            type="textarea"
            field={@form[:description]}
            placeholder="Description"
            class="w-full p-2 rounded-md shadow-sm focus:outline-none "
          />
        </div>
        <!-- Options Section -->
        <div id="options" class="space-y-4">
          <%= for {option, idx} <- Enum.with_index(@options) do %>
            <div class="flex items-center space-x-2">
              <input
                type="text"
                name={"options[#{idx}][text]"}
                value={option[:text]}
                field={input_name(idx)}
                placeholder={"Option #{idx + 1}"}
                required
                class="w-full text-sm p-2 border border-gray-300 rounded-md shadow-sm focus:border-gray-400 focus:ring-1 focus:ring-gray-200"
              />
              <%= if idx > 1 do %>
                <button
                  type="button"
                  phx-click="remove_option"
                  phx-value-index={idx}
                  class="p-1 text-white rounded-md hover:scale-110 transition-transform"
                >
                  <svg
                    width="24"
                    height="24"
                    class="hover:fill-red-800 transition-transform"
                    viewBox="0 0 24 24"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="m20.015 6.506h-16v14.423c0 .591.448 1.071 1 1.071h14c.552 0 1-.48 1-1.071 0-3.905 0-14.423 0-14.423zm-5.75 2.494c.414 0 .75.336.75.75v8.5c0 .414-.336.75-.75.75s-.75-.336-.75-.75v-8.5c0-.414.336-.75.75-.75zm-4.5 0c.414 0 .75.336.75.75v8.5c0 .414-.336.75-.75.75s-.75-.336-.75-.75v-8.5c0-.414.336-.75.75-.75zm-.75-5v-1c0-.535.474-1 1-1h4c.526 0 1 .465 1 1v1h5.254c.412 0 .746.335.746.747s-.334.747-.746.747h-16.507c-.413 0-.747-.335-.747-.747s.334-.747.747-.747zm4.5 0v-.5h-3v.5z"
                      fill-rule="nonzero"
                    />
                  </svg>
                </button>
              <% end %>
            </div>
          <% end %>
        </div>
        <!-- Add Option Button -->
        <%= if length(@options) < 10 do %>
          <button
            type="button"
            phx-click="add_option"
            class="flex items-center gap-2 mt-4 px-4 py-2 mx-auto  shadow-lg rounded-lg bg-neutral-100 hover:shadow-xl hover:scale-110 transition-transform"
          >
            <span>Add Option</span>
            <svg width="20" height="20" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path
                d="m17.5 11c2.484 0 4.5 2.016 4.5 4.5s-2.016 4.5-4.5 4.5-4.5-2.016-4.5-4.5 2.016-4.5 4.5-4.5zm.5 4v-1.5c0-.265-.235-.5-.5-.5s-.5.235-.5.5v1.5h-1.5c-.265 0-.5.235-.5.5s.235.5.5.5h1.5v1.5c0 .265.235.5.5.5s.5-.235.5-.5c0-.592 0-1.5 0-1.5h1.5c.265 0 .5-.235.5-.5s-.235-.5-.5-.5c-.592 0-1.5 0-1.5 0zm-6.479 1c.043.522.153 1.025.321 1.5h-9.092c-.414 0-.75-.336-.75-.75s.336-.75.75-.75zm1.106-4c-.328.456-.594.96-.785 1.5h-9.092c-.414 0-.75-.336-.75-.75s.336-.75.75-.75zm7.373-3.25c0-.414-.336-.75-.75-.75h-16.5c-.414 0-.75.336-.75.75s.336.75.75.75h16.5c.414 0 .75-.336.75-.75zm0-4c0-.414-.336-.75-.75-.75h-16.5c-.414 0-.75.336-.75.75s.336.75.75.75h16.5c.414 0 .75-.336.75-.75z"
                fill-rule="nonzero"
              />
            </svg>
          </button>
        <% end %>
        <!-- Save Button -->
        <div class="mt-6">
          <button
            type="submit"
            class="flex items-center gap-4 mx-auto px-6 py-3 bg-indigo-500 text-white rounded-lg hover:scale-110 transition-transform"
          >
            <span class="text-lg">Publish new poll</span>
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
        </div>
      </.form>
    </div>
    """
  end
end
