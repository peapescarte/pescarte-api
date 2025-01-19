defmodule Pescarte.Blog do
  @moduledoc """
  O contexto Blog é responsável por gerenciar as operações relacionadas a postagens e tags.
  """
  import Ecto.Query
  alias Pescarte.Blog.Entity.Tag
  alias Pescarte.Blog.Post
  alias Pescarte.Database.Repo

  @type filters :: %{
          optional(:title) => String.t(),
          optional(:start_date) => NaiveDateTime.t(),
          optional(:end_date) => NaiveDateTime.t(),
          optional(:tags) => list(Tag.t()),
          optional(:page) => non_neg_integer(),
          optional(:page_size) => pos_integer()
        }

  @spec list_posts_with_filter(filters()) ::  list(Post.t()) | {:error, term()}
  def list_posts_with_filter(filters \\ %{}) do
    Post
    |> apply_post_search_filter(filters)
    |> apply_post_date_filter(filters)
    |> apply_post_tag_filter(filters)
    |> apply_order_by()
    |> apply_pagination(filters)
    |> Repo.replica().all()
  end

  defp apply_post_search_filter(query, %{title: search_term}) do
    from(p in query, where: ilike(p.titulo, ^"%#{search_term}%"))
  end

  defp apply_post_search_filter(query, _), do: query

  defp apply_post_date_filter(query, %{start_date: start_date, end_date: end_date}) do
    from p in query, where: p.published_at >= ^start_date and p.published_at <= ^end_date
  end

  defp apply_post_date_filter(query, _), do: query

  defp apply_post_tag_filter(query, %{tags: tags}) when is_list(tags) do
    from p in query,
      join: t in assoc(p, :blog_tags),
      where: t.nome in ^tags,
      group_by: p.id,
      having: count(t.id) == ^length(tags)
  end

  defp apply_post_tag_filter(query, _), do: query

  defp apply_order_by(query) do
    from p in query, order_by: [desc: p.published_at]
  end

  defp apply_pagination(query, %{page: page, page_size: page_size}) do
    offset = (page - 1) * page_size
    from p in query, limit: ^page_size, offset: ^offset
  end

  defp apply_pagination(query, _), do: from(p in query, limit: 7, offset: 0)
end
