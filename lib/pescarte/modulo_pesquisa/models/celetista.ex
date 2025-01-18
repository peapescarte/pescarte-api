defmodule Pescarte.ModuloPesquisa.Models.Celetista do
  use Pescarte, :model

  alias Pescarte.Database.Types.PublicId
  alias Pescarte.Identidades.Models.Usuario
  alias Pescarte.ModuloPesquisa.Models.Campus
  alias Pescarte.ModuloPesquisa.Models.LinhaPesquisa
  alias Pescarte.ModuloPesquisa.Models.Midia
  alias Pescarte.ModuloPesquisa.Models.RelatorioPesquisa

  @type t :: %Celetista{
          id: binary,
          minibio: binary,
          bolsa: atom,
          link_lattes: binary,
          link_banner_perfil: binary,
          link_linkedin: binary,
          formacao: binary,
          data_inicio_bolsa: Date.t(),
          data_fim_bolsa: Date.t(),
          data_contratacao: Date.t(),
          data_termino: Date.t(),
          orientandos: list(Pesquisador.t()),
          orientador: Pesquisador.t() | nil,
          midias: list(Midia.t()),
          relatorios_pesquisa: list(RelatorioPesquisa.t()),
          campus_id: Campus.t(),
          usuario: User.t(),
          anotacoes: binary
        }

  @tipo_bolsas ~w(
    ic pesquisa consultoria
    voluntario
    celetista
    coordenador_tecnico
    doutorado mestrado
    pos_doutorado nsa
    coordenador_pedagogico
    desconhecido
  )a

  @required_fields ~w(bolsa data_inicio_bolsa data_contratacao formacao linha_pesquisa_principal_id data_fim_bolsa data_termino)a
  @optional_fields ~w(orientador_id link_banner_perfil link_linkedin link_lattes campus_id usuario_id)a

  @derive {
    Flop.Schema,
    filterable: ~w(nome cpf email bolsa)a,
    sortable: ~w(nome email bolsa)a,
    adapter_opts: [
      join_fields: [
        nome: [
          binding: :usuario,
          field: :primeiro_nome,
          ecto_type: :string
        ],
        cpf: [
          binding: :usuario,
          field: :cpf,
          ecto_type: :string
        ],
        email: [
          binding: :contato,
          field: :email_principal,
          ecto_type: :string,
          path: [:usuario, :contato]
        ]
      ]
    ]
  }

  @primary_key {:id, PublicId, autogenerate: true}
  schema "celetista" do
    field :minibio, :string
    field :bolsa, Ecto.Enum, values: @tipo_bolsas
    field :link_lattes, :string
    field :link_banner_perfil, :string
    field :link_linkedin, :string
    field :formacao, :string
    field :data_inicio_bolsa, :date
    field :data_fim_bolsa, :date
    field :data_contratacao, :date
    field :data_termino, :date
    field :anotacoes, :string

    has_many :relatorios_pesquisa, RelatorioPesquisa
    has_many :orientandos, Pesquisador
    has_many :midias, Midia, foreign_key: :autor_id

    many_to_many :linhas_pesquisa, LinhaPesquisa,
      join_through: "pesquisador_lp",
      on_replace: :delete,
      unique: true

    belongs_to :linha_pesquisa_principal, LinhaPesquisa, type: :string
    belongs_to :usuario, Usuario, type: :string
    belongs_to :campus, Campus, type: :string
    belongs_to :orientador, Pesquisador, foreign_key: :orientador_id, type: :string

    timestamps()
  end

  @spec changeset(Pesquisador.t(), map) :: changeset
  def changeset(pesquisador \\ %Celetista{}, attrs) do
    pesquisador
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:usuario, required: true)
    |> cast_assoc(:campus, required: true)
    |> cast_assoc(:linhas_pesquisa, required: false)
    |> unique_constraint(:rg)
    |> foreign_key_constraint(:usuario_id)
    |> foreign_key_constraint(:orientador_id)
    |> foreign_key_constraint(:campus_id)
  end

  def tipo_bolsas, do: @tipo_bolsas
end
