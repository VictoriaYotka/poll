# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :poll,
  ecto_repos: [Poll.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :poll, PollWeb.Endpoint,
  url: [host: "localhost"],
  static_url: [path: "/"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PollWeb.ErrorHTML, json: PollWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Poll.PubSub,
  live_view: [signing_salt: "KCklR3ws"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
# config :poll, Poll.Mailer, adapter: Swoosh.Adapters.Noop

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.15.18",
  poll: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --minify),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.14",
  poll: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css --minify
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_heroicons, type: "outline"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
