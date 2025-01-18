defmodule Pescarte.Database.Repo.Migrations.CreateCeletista do
  use Ecto.Migration

  def change do
    create table(:celetista, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:minibio, :text)
      add(:bolsa, :string)
      add(:link_linkedin, :string)
      add(:link_lattes, :string)
      add(:formacao, :string)
      add(:anotacoes, :string)
      add(:data_inicio_bolsa, :date)
      add(:data_fim_bolsa, :date)
      add(:data_contratacao, :date)
      add(:data_termino, :date)
      add(:link_banner_perfil, :string)
      add(:usuario_id, references(:usuario, type: :string), null: false)
      add(:campus_id, references(:campus, type: :string), null: false)
      add(:orientador_id, references(:pesquisador, type: :string))

      timestamps()
    end

    create(index(:celetista, [:usuario_id]))
    create(index(:celetista, [:campus_id]))
    create(index(:celetista, [:orientador_id]))
  end
end
