defmodule MoviesApiWeb.PageController do
  use MoviesApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
