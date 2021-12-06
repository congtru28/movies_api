defmodule MoviesApiWeb.Crawler.CrawlerData do
  alias MoviesApiWeb.Crawler.HttpClient
  alias MoviesApi.Movies
  # @base_url "https://iphimmoi.net/category/hoat-hinh/"

  def get_all_movie(category_url) do
    get_all_movie_url(1, category_url)
    |> List.flatten()
    |> Enum.slice(0, 200)
    |> get_movie_html_body()
    |> Enum.map(fn body ->
      Task.async(fn ->
        {:ok, document} = Floki.parse_document(body)
        movie_name = get_movie_title(document)

        %{
          id: nil,
          title: movie_name,
          movie_url: get_movie_link(document),
          thumnail_url: get_movie_thumnail(document),
          year: get_movie_year(document),
          number_of_episode: get_number_of_episode(document),
          full_series: get_full_series_status(document),
          director_name: get_movie_director_name(document),
          country: get_movie_country(document)
        }
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

  @doc """
  Get movie url list in a page
  ## Parameters
    - page_index: Interger that represents the page of website.
  """
  def get_all_movie_url(page_index \\ 1, category_url) do
    raw_data = get_url_by_page(page_index, category_url) |> HttpClient.get()

    with {:ok, document} <- Floki.parse_document(raw_data) do
      urls =
        document
        |> Floki.find(".movie-list-index.home-v2 ul.last-film-box>li>.movie-item")
        |> Floki.attribute("href")

      if length(urls) > 0 && page_index < 7 do
        urls ++ get_all_movie_url(page_index + 1, category_url)
      else
        urls
      end
    else
      error ->
        IO.inspect("Error when parsing document #{inspect(error)}")
        []
    end
  end

  @doc """
  Get url by page index
  ## Parameters
    - page_index: Interger that represents the page of website.
  """
  def get_url_by_page(1 = _page_index, base_url), do: base_url

  def get_url_by_page(page_index, base_url), do: base_url <> "page/#{page_index}/"

  @doc """
  Get movie detail by url
  ## Parameters
    - urls: Array of movie url
  """
  def get_movie_html_body(urls) do
    Enum.map(urls, fn product_id ->
      Task.async(fn -> HttpClient.get(product_id) end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

  @doc """
  Get movie title
  """
  def get_movie_title(body) do
    body
    |> Floki.find(".movie-info .movie-title .title-1")
    |> Floki.text()
  end

  @doc """
  Get movie link
  """
  def get_movie_link(body) do
    data =
      body
      |> Floki.find("#film-content-wrapper>#film-content")
      |> Floki.attribute("data-href")

    case data do
      [head | _] -> head
      _ -> []
    end
  end

  @doc """
  Get movie thumnail
  """
  def get_movie_thumnail(body) do
    body
    |> Floki.find(".movie-info .movie-l-img img")
    |> Floki.attribute("src")
    |> List.last()
  end

  @doc """
  Get movie year
  """
  def get_movie_year(body) do
    body
    |> Floki.find("[rel=tag]")
    |> Floki.text()
  end

  @doc """
  Get number of episode
  """
  def get_number_of_episode(body) do
    episode_list =
      body
      |> get_episode_list()

    if(length(episode_list) > 0) do
      List.first(episode_list)
    else
      nil
    end
  end

  @doc """
  Get full series status
  """
  def get_full_series_status(body) do
    episode_list =
      body
      |> get_episode_list()

    if length(episode_list) > 1 do
      current_episode = List.first(episode_list)
      total_episode = Enum.at(episode_list, 1)
      current_episode == total_episode
    else
      false
    end
  end

  @doc """
  Get episode list
  """
  def get_episode_list(body) do
    body
    |> Floki.find(".movie-info .movie-meta-info .status")
    |> Floki.text()
    |> String.split([" ", ",", "/"])
    |> Enum.map(fn text ->
      case Integer.parse(text) do
        {value, _} -> value
        :error -> nil
      end
    end)
    |> Enum.filter(fn number -> number != nil end)
  end

  @doc """
  Lấy thông tin tên đạo diễn
  """
  def get_movie_director_name(body) do
    body
    |> Floki.find("dd.movie-dd.dd-cat > .director")
    |> Floki.attribute("title")
    |> Enum.join(", ")
    |> Floki.text()
  end

  @doc """
  Lấy tên quốc gia của phim
  """
  def get_movie_country(body) do
    body
    |> Floki.find("dd.movie-dd.dd-cat >a")
    |> Floki.attribute("title")
    |> List.last()
  end

  @doc """
  Lấy danh sách các url của phim từ trang đến trang
  """
  def get_movie_urls({from, to}, url) do
    if from == to do
      get_movie_urls_by_page(from, url)
      |> List.flatten()
    else
      get_movie_urls_by_page(from, url)
      |> List.flatten()
      |> Enum.concat(
        get_movie_urls_by_page(to, url)
        |> List.flatten()
      )
    end
  end

  @doc """
  Lấy danh sách các url của phim trên 1 trang
  ## Parameters
    - page_index: Interger that represents the page of website.
    - base_url: String that represents the base url of website.
  """
  def get_movie_urls_by_page(page_index, url) do
    raw_data = get_url_by_page(page_index, url) |> HttpClient.get()

    with {:ok, document} <- Floki.parse_document(raw_data) do
      document
      |> Floki.find(".movie-list-index.home-v2 ul.last-film-box>li>.movie-item")
      |> Floki.attribute("href")
    else
      error ->
        IO.inspect("Error when parsing document #{inspect(error)}")
        []
    end
  end

  def parse_data(urls) do
    urls
    |> get_movie_html_body()
    |> Enum.map(fn body ->
      Task.async(fn ->
        {:ok, document} = Floki.parse_document(body)
        movie_name = get_movie_title(document)

        %{
          id: nil,
          title: movie_name,
          movie_url: get_movie_link(document),
          thumnail_url: get_movie_thumnail(document),
          year: get_movie_year(document),
          number_of_episode: get_number_of_episode(document),
          full_series: get_full_series_status(document),
          director_name: get_movie_director_name(document),
          country: get_movie_country(document)
        }
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

  def insert_movie(movies) do
    movies
    |> Enum.map(fn movie ->
      Task.async(fn ->
        movie_id = Movies.insert_movie(movie)
        movie_id
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end
end
