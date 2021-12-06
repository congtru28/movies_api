defmodule MoviesApiWeb.MovieControllerTest do
  use MoviesApiWeb.ConnCase

  import MoviesApi.MoviesFixtures

  alias MoviesApi.Movies.Movie

  @create_attrs %{
    country: "some country",
    director_name: "some director_name",
    full_series: true,
    movie_url: "some movie_url",
    number_of_episode: 42,
    thumnail_url: "some thumnail_url",
    title: "some title",
    year: 42
  }
  @update_attrs %{
    country: "some updated country",
    director_name: "some updated director_name",
    full_series: false,
    movie_url: "some updated movie_url",
    number_of_episode: 43,
    thumnail_url: "some updated thumnail_url",
    title: "some updated title",
    year: 43
  }
  @invalid_attrs %{country: nil, director_name: nil, full_series: nil, movie_url: nil, number_of_episode: nil, thumnail_url: nil, title: nil, year: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all movies", %{conn: conn} do
      conn = get(conn, Routes.movie_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create movie" do
    test "renders movie when data is valid", %{conn: conn} do
      conn = post(conn, Routes.movie_path(conn, :create), movie: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.movie_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "country" => "some country",
               "director_name" => "some director_name",
               "full_series" => true,
               "movie_url" => "some movie_url",
               "number_of_episode" => 42,
               "thumnail_url" => "some thumnail_url",
               "title" => "some title",
               "year" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.movie_path(conn, :create), movie: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update movie" do
    setup [:create_movie]

    test "renders movie when data is valid", %{conn: conn, movie: %Movie{id: id} = movie} do
      conn = put(conn, Routes.movie_path(conn, :update, movie), movie: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.movie_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "country" => "some updated country",
               "director_name" => "some updated director_name",
               "full_series" => false,
               "movie_url" => "some updated movie_url",
               "number_of_episode" => 43,
               "thumnail_url" => "some updated thumnail_url",
               "title" => "some updated title",
               "year" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, movie: movie} do
      conn = put(conn, Routes.movie_path(conn, :update, movie), movie: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete movie" do
    setup [:create_movie]

    test "deletes chosen movie", %{conn: conn, movie: movie} do
      conn = delete(conn, Routes.movie_path(conn, :delete, movie))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.movie_path(conn, :show, movie))
      end
    end
  end

  defp create_movie(_) do
    movie = movie_fixture()
    %{movie: movie}
  end
end
