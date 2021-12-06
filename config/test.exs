import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :movies_api, MoviesApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "movies_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :movies_api, MoviesApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "GqPI24TvsMbtd9fQUhkFG/mTK1NpVB2Q2wwI8thWMsdqXVfWH55o6tERxPeQzyhS",
  server: false

# In test we don't send emails.
config :movies_api, MoviesApi.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
