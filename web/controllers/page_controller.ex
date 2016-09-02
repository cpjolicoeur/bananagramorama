defmodule BananaGrams.PageController do
  use BananaGrams.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
