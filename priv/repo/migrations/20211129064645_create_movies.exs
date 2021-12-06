defmodule MoviesApi.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :title, :string
      add :movie_url, :string, null: true
      add :thumnail_url, :string, null: true
      add :year, :integer, null: true
      add :number_of_episode, :integer, null: true
      add :full_series, :boolean, default: false, null: true
      add :director_name, :string, null: true
      add :country, :string, null: true

      timestamps()
    end

    create unique_index(:movies, [:title])

  end
end
