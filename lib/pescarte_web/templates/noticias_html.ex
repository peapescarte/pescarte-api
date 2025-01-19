defmodule PescarteWeb.NoticiasHTML do
  use PescarteWeb, :html

  alias Pescarte.Blog

  embed_templates("noticias_html/*")

  @notice_title_max_length Application.compile_env!(:pescarte, [
                             PescarteWeb,
                             :notice_title_max_length
                           ])

  @notice_desc_max_length Application.compile_env!(:pescarte, [
                            PescarteWeb,
                            :notice_desc_max_length
                          ])

  def handle_notice_title_length(text) do
    if String.length(text) > @notice_title_max_length do
      text
      |> truncate_text_until(@notice_title_max_length - 4)
      |> put_ellipsis()
    else
      text
    end
  end

  def handle_notice_desc_length(text) do
    if String.length(text) > @notice_desc_max_length do
      text
      |> truncate_text_until(@notice_desc_max_length - 4)
      |> put_ellipsis()
    else
      text
    end
  end

  defp truncate_text_until(text, length) do
    text
    |> String.slice(0..length)
    |> String.trim_trailing()
  end

  defp put_ellipsis(text) do
    text <> "..."
  end

  def date_to_string(date_time) do
    DateTime.to_date(date_time)
    |> Date.to_string()
    |> String.split("-")
    |> Enum.reverse()
    |> Enum.join("/")
  end

  def handle_event("get_news", _, socket) do
    current_news_length = socket.assigns.news.length
    loaded_news = Blog.list_posts_with_filter(%{page: current_news_length + 1, page_size: 6})

    socket = socket |> assign(news: socket.assigns.news ++ loaded_news)

    {:noreply, socket}
  end

  def handle_event("dialog", _value, socket) do
    {:noreply, socket}
  end
end
