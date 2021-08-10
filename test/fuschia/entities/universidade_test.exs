defmodule Fuschia.Entities.UniversidadeTest do
  use Fuschia.DataCase, async: true

  import Fuschia.Factory

  alias Fuschia.Entities.Universidade

  describe "changeset/2" do
    @invalid_params %{nome: nil, cidade: nil}

    test "when all params are valid, return a valid changeset" do
      cidade = params_for(:cidade)
      default_params = params_for(:universidade) |> Map.put(:cidade, cidade)

      assert %Ecto.Changeset{valid?: true} =
               Universidade.changeset(%Universidade{}, default_params)
    end

    test "when params are invalid, return an error changeset" do
      assert %Ecto.Changeset{valid?: false} =
               Universidade.changeset(%Universidade{}, @invalid_params)
    end
  end
end
