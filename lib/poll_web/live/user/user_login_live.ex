defmodule PollWeb.UserLoginLive do
  use PollWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="pt-8 mx-auto max-w-sm">
      <h2 class="text-center text-xl">
        Log in to account
        <p class="mt-4 text-sm">
          Don't have an account?
          <.link navigate={~p"/users/register"}           class="inline-block font-bold font-montserrat text-red-900 shadow-sm underline decoration-dotted hover:decoration-solid"
>
            Sign up
          </.link>
          for an account now.
        </p>
      </h2>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <button
          phx-disable-with="Logging in..."
            type="submit"
            class="flex items-center gap-4 mx-auto px-6 py-2 bg-indigo-500 text-white rounded-lg hover:scale-110 transition-transform"
          >
            <span class="text-lg">Log in </span>
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
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     socket
     |> assign(form: form, page_title: "Login")
     |> assign(temporary_assigns: [form: form])}
  end
end
