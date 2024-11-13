defmodule PollWeb.UserRegistrationLive do
  use PollWeb, :live_view

  alias Poll.Accounts
  alias Poll.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="pt-8  mx-auto max-w-sm">
      <h2 class="text-center text-xl">
        Register for an account
        <p class="mt-4 text-sm">
          Already registered?
          <.link navigate={~p"/users/log_in"}
          class="inline-block font-bold font-montserrat text-red-900 shadow-sm underline decoration-dotted hover:decoration-solid"
>
            Log in
          </.link>
          to your account now.
        </p>
      </h2>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <button
          phx-disable-with="Creating account..."
            type="submit"
            class="flex items-center gap-4 mx-auto px-6 py-2 bg-indigo-500 text-white rounded-lg hover:scale-110 transition-transform"
          >
            <span class="text-lg">Create an account</span>
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
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok,
     socket
     |> assign(page_title: "Register")
     |> assign(temporary_assigns: [form: nil])}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
