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
    <.form for={@form} phx-change="validate" phx-submit="save">
      <.input type="text" field={@form[:title]} placeholder="Title" />
      <.input type="textarea" field={@form[:description]} placeholder="Description" />

      <div id="options">
        <%= for {option, idx} <- Enum.with_index(@options) do %>
          <.input
            type="text"
            name={"options[#{idx}][text]"}
            value={option[:text]}
            field={input_name(idx)}
            placeholder={"Option #{idx + 1}"}
            required
          />
          <%= if idx > 1 do %>
            <button type="button" phx-click="remove_option" phx-value-index={idx}>Remove</button>
          <% end %>
        <% end %>
      </div>

      <%= if length(@options) < 10 do %>
        <button type="button" phx-click="add_option">Add Option</button>
      <% end %>
      <button>Save</button>
    </.form>
    """
  end
end
