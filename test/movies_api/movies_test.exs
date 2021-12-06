defmodule MoviesApi.MoviesTest do
  use MoviesApi.DataCase

  alias MoviesApi.Movies

  describe "movies" do
    alias MoviesApi.Movies.Movie

    import MoviesApi.MoviesFixtures

    @invalid_attrs %{country: nil, director_name: nil, full_series: nil, movie_url: nil, number_of_episode: nil, thumnail_url: nil, title: nil, year: nil}

    test "list_movies/0 returns all movies" do
      movie = movie_fixture()
      assert Movies.list_movies() == [movie]
    end

    test "get_movie!/1 returns the movie with given id" do
      movie = movie_fixture()
      assert Movies.get_movie!(movie.id) == movie
    end

    test "create_movie/1 with valid data creates a movie" do
      valid_attrs = %{country: "some country", director_name: "some director_name", full_series: true, movie_url: "some movie_url", number_of_episode: 42, thumnail_url: "some thumnail_url", title: "some title", year: 42}

      assert {:ok, %Movie{} = movie} = Movies.create_movie(valid_attrs)
      assert movie.country == "some country"
      assert movie.director_name == "some director_name"
      assert movie.full_series == true
      assert movie.movie_url == "some movie_url"
      assert movie.number_of_episode == 42
      assert movie.thumnail_url == "some thumnail_url"
      assert movie.title == "some title"
      assert movie.year == 42
    end

    test "create_movie/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Movies.create_movie(@invalid_attrs)
    end

    test "update_movie/2 with valid data updates the movie" do
      movie = movie_fixture()
      update_attrs = %{country: "some updated country", director_name: "some updated director_name", full_series: false, movie_url: "some updated movie_url", number_of_episode: 43, thumnail_url: "some updated thumnail_url", title: "some updated title", year: 43}

      assert {:ok, %Movie{} = movie} = Movies.update_movie(movie, update_attrs)
      assert movie.country == "some updated country"
      assert movie.director_name == "some updated director_name"
      assert movie.full_series == false
      assert movie.movie_url == "some updated movie_url"
      assert movie.number_of_episode == 43
      assert movie.thumnail_url == "some updated thumnail_url"
      assert movie.title == "some updated title"
      assert movie.year == 43
    end

    test "update_movie/2 with invalid data returns error changeset" do
      movie = movie_fixture()
      assert {:error, %Ecto.Changeset{}} = Movies.update_movie(movie, @invalid_attrs)
      assert movie == Movies.get_movie!(movie.id)
    end

    test "delete_movie/1 deletes the movie" do
      movie = movie_fixture()
      assert {:ok, %Movie{}} = Movies.delete_movie(movie)
      assert_raise Ecto.NoResultsError, fn -> Movies.get_movie!(movie.id) end
    end

    test "change_movie/1 returns a movie changeset" do
      movie = movie_fixture()
      assert %Ecto.Changeset{} = Movies.change_movie(movie)
    end
  end
end
