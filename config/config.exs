# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bananagrams,
  namespace: BananaGrams,
  ecto_repos: [BananaGrams.Repo]

# Configures the endpoint
config :bananagrams, BananaGrams.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "abfG3ol981pDjiHwDoOrYADOeeuTkgp/H5sEdhWo/jRIeSuvfxtVi4h10Nvn+z5d",
  render_errors: [view: BananaGrams.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BananaGrams.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
