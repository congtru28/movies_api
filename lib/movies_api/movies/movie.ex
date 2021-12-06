defmodule MoviesApi.Movies.Movie do
  use Ecto.Schema
  import Ecto.Changeset

  schema "movies" do
    field :country, :string
    field :director_name, :string
    field :full_series, :boolean, default: false
    field :movie_url, :string
    field :number_of_episode, :integer
    field :thumnail_url, :string
    field :title, :string
    field :year, :integer

    timestamps()
  end

  @doc false
  def changeset(movie, attrs) do
    movie
    |> cast(attrs, [
      :title,
      :movie_url,
      :thumnail_url,
      :year,
      :number_of_episode,
      :full_series,
      :director_name,
      :country
    ])
    |> validate_required([:title])

    # |> check_constraint(:title, name: :price_must_be_positive)
  end
end
