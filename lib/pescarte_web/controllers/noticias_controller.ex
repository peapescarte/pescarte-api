defmodule PescarteWeb.NoticiasController do
  use PescarteWeb, :controller
  alias Pescarte.Blog

  def show(conn, _params) do
    current_path = conn.request_path

    [main_new | news] = Blog.list_posts_with_filter()

    render(conn, :show,
      current_path: current_path,
      error_message: nil,
      news: news,
      main_new: main_new
    )
  end
end
