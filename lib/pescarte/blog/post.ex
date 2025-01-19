defmodule Pescarte.Blog.Post do
  @moduledoc """
  Módulo que define o schema e o changeset para os posts.
  """
  use Pescarte, :model

  alias Ecto.Multi
  alias Pescarte.Blog.Entity.Tag
  alias Pescarte.Database
  alias Pescarte.Database.Repo
  alias Pescarte.Database.Types.PublicId
  alias Pescarte.Identidades.Models.Usuario

  @type t :: %Post{
          id: String.t(),
          titulo: String.t(),
          conteudo: String.t(),
          link_imagem_capa: String.t(),
          published_at: NaiveDateTime.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          usuario: Usuario.t()
        }

  @required_params [:titulo, :conteudo, :link_imagem_capa, :published_at, :usuario_id]

  @primary_key {:id, PublicId, autogenerate: true}
  schema "blog_posts" do
    field :titulo, :string
    field :conteudo, :binary
    field :link_imagem_capa, :string
    field :published_at, :naive_datetime

    belongs_to :usuario, Usuario, type: :string
    many_to_many :blog_tags, Tag, join_through: "posts_tags"

    timestamps()
  end

  @spec changeset(Post.t(), map) :: changeset
  def changeset(post \\ %Post{}, params) do
    post
    |> Map.put(:published_at, NaiveDateTime.utc_now(:second))
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> unique_constraint(:titulo)
    |> foreign_key_constraint(:usuario_id)
  end

  @spec get_post(String.t()) :: {:ok, Post.t()} | {:error, :not_found}
  def get_post(id) do
    Database.fetch(Post, id)
  end

  @spec create_post(Map) :: {:ok, Post.t()} | {:error, Ecto.Changeset.t()}
  def create_post(%{blog_tags: tags} = params) do
    Multi.new()
    |> Multi.insert_all(:update_tags, Tag, tags,
      on_conflict: :replace_all,
      conflict_target: :nome
    )
    |> Multi.insert(:blog_posts, changeset(%Post{}, params))
    |> Repo.transaction()
  end

  @spec delete_post(String.t()) :: {:ok, Post.t()} | {:error, :not_found}
  def delete_post(id) do
    query = from(p in Post, where: p.id == ^id, select: p)

    query
    |> Repo.delete_all()
    |> case do
      {1, [deleted_post]} -> {:ok, deleted_post}
      {0, nil} -> {:error, :not_found}
    end
  end

  @spec update_post(String.t(), Post.t()) :: {:ok, Post.t()} | {:error, :not_found}
  def update_post(id, params) do
    query = from(p in Post, where: p.id == ^id, select: p)

    params_with_updated_at =
      params
      |> Map.put(:updated_at, NaiveDateTime.utc_now())
      |> Map.to_list()

    query
    |> Repo.update_all(set: params_with_updated_at)
    |> case do
      {1, [updated_post]} -> {:ok, updated_post}
      {0, _} -> {:error, :not_found}
    end
  end
end
