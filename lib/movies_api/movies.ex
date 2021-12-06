defmodule MoviesApi.Movies do
  @moduledoc """
  The Movies context.
  """

  import Ecto.Query, warn: false
  alias MoviesApi.Repo

  alias MoviesApi.Movies.Movie

  @doc """
  Returns the list of movies.

  ## Examples

      iex> list_movies()
      [%Movie{}, ...]

  """
  def list_movies do
    Repo.all(Movie)
  end

  @doc """
  Gets a single movie.

  Raises `Ecto.NoResultsError` if the Movie does not exist.

  ## Examples

      iex> get_movie!(123)
      %Movie{}

      iex> get_movie!(456)
      ** (Ecto.NoResultsError)

  """
  def get_movie!(id), do: Repo.get!(Movie, id)

  @doc """
  Creates a movie.

  ## Examples

      iex> create_movie(%{field: value})
      {:ok, %Movie{}}

      iex> create_movie(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_movie(attrs \\ %{}) do
    %Movie{}
    |> Movie.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a movie.

  ## Examples

      iex> update_movie(movie, %{field: new_value})
      {:ok, %Movie{}}

      iex> update_movie(movie, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_movie(%Movie{} = movie, attrs) do
    movie
    |> Movie.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a movie.

  ## Examples

      iex> delete_movie(movie)
      {:ok, %Movie{}}

      iex> delete_movie(movie)
      {:error, %Ecto.Changeset{}}

  """
  def delete_movie(%Movie{} = movie) do
    Repo.delete(movie)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking movie changes.

  ## Examples

      iex> change_movie(movie)
      %Ecto.Changeset{data: %Movie{}}

  """
  def change_movie(%Movie{} = movie, attrs \\ %{}) do
    Movie.changeset(movie, attrs)
  end

  def insert_movie(attrs \\ %{}) do
    %Movie{}
    |> Movie.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  def get_movies_with_pagination(page_index, page_size, director, country) do
    with {page_index, _} <- Integer.parse(page_index),
         {page_size, _} <- Integer.parse(page_size) do
      director = "%#{director}%"
      country = "%#{country}%"

      from(m in Movie,
        where: like(m.country, ^country) and like(m.director_name, ^director)
      )
      |> paginate(page_index, page_size)
      |> Repo.all()
    else
      :error -> []
    end
  end

  def paginate(query, page_index, page_size) do
    offset_by = page_size * (page_index - 1)

    query
    |> limit(^page_size)
    |> offset(^offset_by)
  end

  def count_movies(director, country) do
    director = "%#{director}%"
    country = "%#{country}%"

    from(m in Movie,
      where: like(m.country, ^country) and like(m.director_name, ^director),
      select: count(m.id)
    )
    |> Repo.one()
  end
end
