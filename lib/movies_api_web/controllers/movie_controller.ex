defmodule MoviesApiWeb.MovieController do
  use MoviesApiWeb, :controller

  alias MoviesApi.Movies
  alias MoviesApi.Movies.Movie
  alias MoviesApiWeb.Crawler.CrawlerData
  action_fallback(MoviesApiWeb.FallbackController)

  def index(conn, _params) do
    movies = Movies.list_movies()
    render(conn, "index.json", movies: movies)
  end

  def create(conn, %{"movie" => movie_params}) do
    with {:ok, %Movie{} = movie} <- Movies.create_movie(movie_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.movie_path(conn, :show, movie))
      |> render("show.json", movie: movie)
    end
  end

  def show(conn, %{"id" => id}) do
    movie = Movies.get_movie!(id)
    render(conn, "show.json", movie: movie)
  end

  def update(conn, %{"id" => id, "movie" => movie_params}) do
    movie = Movies.get_movie!(id)

    with {:ok, %Movie{} = movie} <- Movies.update_movie(movie, movie_params) do
      render(conn, "show.json", movie: movie)
    end
  end

  def delete(conn, %{"id" => id}) do
    movie = Movies.get_movie!(id)

    with {:ok, %Movie{}} <- Movies.delete_movie(movie) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc """
  Người dùng nhập vào một "Thể loại", sau đó lấy danh sách có phân trang phim tương ứng với thể loại đó.
  """
  def crawler_url(conn, %{"page_index" => page_index, "page_size" => page_size, "url" => url}) do
    {from, to} =
      calulate_page_size(page_index, page_size)
      |> calulate_source_page_index()

    movies =
      CrawlerData.get_movie_urls({from, to}, url)
      # Tính số trang tương ứng cần lấy trên iphimmoi, do iphimmoi phân trang 32 item/page, nên cần tính lại cho phù hợp.
      |> Enum.slice(page_index * page_size - page_size + 1 - (from * 32 - 32 + 1), page_size)
      |> CrawlerData.parse_data()

    # render(conn, "index.json", movies: movies)
    conn |> json(%{status: 1, data: movies})
  end

  # Tính số lượng phần tử bắt đầu và kết thúc tương ứng với page_index và page_size.
  defp calulate_page_size(page_index, page_size) do
    {
      page_size * (page_index - 1) + 1,
      page_index * page_size
    }
  end

  # Tính số trang tương ứng cần lấy trên iphimmoi, do iphimmoi phân trang 32 item/page, nên cần tính lại cho phù hợp.
  defp calulate_source_page_index({from, to}) do
    {
      floor(from / 32) + 1,
      floor(to / 32) + 1
    }
  end

  @doc """
  Người dùng nhập vào một "Thể loại", sau đó lấy tất cả danh sách phim tương ứng với thể loại đó.
  """
  def export_url(conn, %{"urls" => urls}) do
    if(length(urls) == 0) do
      conn |> json(%{status: 0, message: "url is empty", data: []})
    else
      movies =
        urls
        |> Enum.map(fn url ->
          CrawlerData.get_all_movie(url)
        end)

      if length(movies) > 0 do
        insert_movie(movies)
      end

      conn |> json(%{status: 1, data: movies})
    end
  end

  def get_all_movie(conn, %{
        "page_index" => page_index,
        "page_size" => page_size,
        "director" => director,
        "country" => country
      }) do
    movies =
      Movies.get_movies_with_pagination(page_index, page_size, director, country)
      |> Enum.map(fn movie ->
        %{
          title: movie.title,
          movie_url: movie.movie_url,
          thumnail_url: movie.thumnail_url,
          year: movie.year,
          number_of_episode: movie.number_of_episode,
          full_series: movie.full_series,
          director_name: movie.director_name,
          country: movie.country
        }
      end)

    conn |> json(%{status: 1, data: movies, total_movies: Movies.count_movies(director, country)})
  end

  def insert_movie(movies) do
    movies
    |> List.flatten()
    |> Enum.map(fn movie ->
      Task.async(fn ->
        Movies.insert_movie(movie)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end
end
