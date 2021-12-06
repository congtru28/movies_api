defmodule MoviesApi.MoviesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MoviesApi.Movies` context.
  """

  @doc """
  Generate a movie.
  """
  def movie_fixture(attrs \\ %{}) do
    {:ok, movie} =
      attrs
      |> Enum.into(%{
        country: "some country",
        director_name: "some director_name",
        full_series: true,
        movie_url: "some movie_url",
        number_of_episode: 42,
        thumnail_url: "some thumnail_url",
        title: "some title",
        year: 42
      })
      |> MoviesApi.Movies.create_movie()

    movie
  end
end
