defmodule Pescarte.Identidades.Models.Usuario do
  use Pescarte, :model

  import Brcpfcnpj.Changeset, only: [validate_cpf: 3]

  alias Pescarte.Blog.Post
  alias Pescarte.Database.Types.PublicId
  alias Pescarte.Identidades.Models.Contato
  alias Pescarte.ModuloPesquisa.Models.Pesquisador

  @type t :: %Usuario{
          cpf: binary,
          rg: binary,
          data_nascimento: Date.t(),
          papel: atom,
          primeiro_nome: binary,
          sobrenome: binary,
          id: binary,
          pesquisador: Pesquisador.t(),
          contato: Contato.t(),
          external_customer_id: String.t()
        }

  @valid_roles ~w(celetista pesquisador pescador admin)a

  @required_fields ~w(primeiro_nome sobrenome cpf data_nascimento papel)a
  @optional_fields ~w(rg link_avatar contato_id external_customer_id)a

  @lower_pass_format ~r/[a-z]/
  @upper_pass_format ~r/[A-Z]/
  @special_pass_format ~r/[!?@#$%^&*_0-9]/

  @primary_key {:id, PublicId, autogenerate: true}
  schema "usuario" do
    field :cpf, :string
    field :rg, :string
    field :data_nascimento, :date
    field :papel, Ecto.Enum, values: @valid_roles
    field :primeiro_nome, :string
    field :sobrenome, :string
    field :link_avatar, :string
    field :external_customer_id, :string

    has_one :pesquisador, Pesquisador

    belongs_to :contato, Contato, type: :string

    has_many :blog_posts, Post

    timestamps()
  end

  @spec changeset(Usuario.t(), map) :: changeset
  def changeset(%Usuario{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_cpf(:cpf, message: "CPF inválido")
    |> unique_constraint(:cpf)
    |> cast_assoc(:contato, required: false)
    |> foreign_key_constraint(:contato_id)
  end

  @spec password_changeset(Usuario.t() | changeset, map) :: changeset
  def password_changeset(source, attrs \\ %{}) do
    source
    |> cast(attrs, [:senha])
    |> validate_required([:senha])
    |> validate_confirmation(:senha, required: true)
    |> validate_length(:senha, min: 12, max: 72)
    |> validate_format(:senha, @lower_pass_format, message: "pelo menos uma letra minúscula")
    |> validate_format(:senha, @upper_pass_format, message: "pelo menos uma letra maiúscula")
    |> validate_format(:senha, @special_pass_format,
      message: "pelo menos um digito ou caractere digital"
    )
  end

  def user_roles, do: @valid_roles

  def get_external_id(%__MODULE__{} = user) do
    "supabase|" <> external_id = user.external_customer_id
    external_id
  end

  def fetch_by(cpf: cpf) do
    Database.fetch_one(
      from u in __MODULE__,
        where: u.cpf == ^String.replace(cpf, ~r/\D/, ""),
        preload: [:contato, pesquisador: [:usuario]]
    )
  end

  def fetch_by(id: id) do
    Database.fetch_one(
      from u in __MODULE__,
        where: u.id == ^id,
        preload: [:contato, pesquisador: [:usuario]]
    )
  end

  def fetch_by(external_customer_id: external_customer_id) do
    id = "supabase|#{external_customer_id}"

    Database.fetch_one(
      from u in __MODULE__,
        where: u.external_customer_id == ^id,
        preload: [:contato, pesquisador: [:usuario]]
    )
  end

  def all do
    alias Pescarte.Database.Repo
    query = from u in __MODULE__, preload: [:pesquisador, :contato]
    Repo.Replica.all(query)
  end

  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  def email_query(email) do
    from(u in Usuario,
      left_join: c in assoc(u, :contato),
      where: c.email_principal == ^email or ^email in c.emails_adicionais,
      order_by: [desc: u.inserted_at],
      limit: 1
    )
  end

  def link_to_external(user \\ %__MODULE__{}, external_id) do
    id = "supabase|" <> external_id

    user
    |> changeset(%{external_customer_id: id})
    |> Repo.update()
  end

  def build_usuario_name(nil), do: ""

  def build_usuario_name(usuario) do
    if usuario.sobrenome do
      usuario.primeiro_nome <> " " <> usuario.sobrenome
    else
      usuario.primeiro_nome
    end
  end
end
