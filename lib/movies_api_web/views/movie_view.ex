defmodule MoviesApiWeb.MovieView do
  use MoviesApiWeb, :view
  alias MoviesApiWeb.MovieView

  def render("index.json", %{movies: movies}) do
    %{data: render_many(movies, MovieView, "movie.json")}
  end

  def render("show.json", %{movie: movie}) do
    %{data: render_one(movie, MovieView, "movie.json")}
  end

  def render("movie.json", %{movie: movie}) do
    %{
      id: movie.id,
      title: movie.title,
      movie_url: movie.movie_url,
      thumnail_url: movie.thumnail_url,
      year: movie.year,
      number_of_episode: movie.number_of_episode,
      full_series: movie.full_series,
      director_name: movie.director_name,
      country: movie.country
    }
  end
end
