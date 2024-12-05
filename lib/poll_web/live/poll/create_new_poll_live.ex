defmodule PollWeb.CreateNewPollLive do
  use PollWeb, :live_view

  alias Poll.{Polls, Accounts}
  alias Poll.Polls.Poll
  alias PollWeb.IconComponent

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
      socket = put_flash(socket, :info, "You created poll '#{poll.title}' successfully!")

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
            required
          />
        </div>
        <div class="mb-6">
          <.input
            type="textarea"
            field={@form[:description]}
            placeholder="Description"
            class="w-full p-2 rounded-md shadow-sm focus:outline-none"
            required
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
                  <IconComponent.render
                    id={"delete_option_icon_#{idx + 1}"}
                    name="delete"
                    fill="black"
                    aria_label="delete option"
                  />
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
            class="flex items-center gap-2 mt-4 px-4 py-2 mx-auto font-montserrat shadow-lg rounded-lg bg-neutral-100 hover:shadow-xl hover:scale-110 transition-transform"
          >
            <span>Add Option</span>
            <IconComponent.render
              id="add_option_icon"
              name="plus"
              width="12"
              height="12"
              stroke="none"
              viewBox="0 0 122.875 122.648"
              aria_label="add option"
            />
          </button>
        <% end %>
        <!-- Save Button -->
        <div class="mt-6">
          <button
            type="submit"
            class="flex items-center gap-4 mx-auto px-6 py-3 bg-main_accent-500 text-white font-montserrat rounded-lg hover:scale-110 transition-transform"
          >
            <span class="text-lg">Publish new poll</span>
            <IconComponent.render
              id="create_double_arrow_icon"
              name="double_arrow"
              stroke="white"
              fill="white"
              aria_label="create new poll"
            />
          </button>
        </div>
      </.form>
    </div>
    """
  end
end
