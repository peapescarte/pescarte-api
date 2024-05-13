defmodule PescarteWeb.Pesquisa.ProfileLive do
  use PescarteWeb, :auth_live_view

  import Phoenix.Naming, only: [humanize: 1]

  alias Pescarte.Identidades.Models.Usuario
  alias Pescarte.Supabase

  @impl true
  def mount(_params, _session, socket) do
    %Usuario{} = current_usuario = socket.assigns.current_usuario

    {:ok,
     assign(socket,
       reset_form: to_form(%{}, as: :reset_pass),
       user_name: Usuario.build_usuario_name(current_usuario),
       bolsa: humanize(current_usuario.pesquisador.bolsa),
       minibio: current_usuario.pesquisador.minibio,
       link_lattes: current_usuario.pesquisador.link_lattes,
       link_linkedin: current_usuario.pesquisador.link_linkedin,
       link_banner: current_usuario.pesquisador.link_banner_perfil,
       link_avatar: current_usuario.link_avatar
     )}
  end

  @impl true
  def handle_params(%{"type" => "recovery"}, _uri, socket) do
    {:noreply, push_event(socket, "js-exec", %{to: "#reset-password", attr: "data-show"})}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  # Components

  attr(:href, :string, required: true)
  attr(:label, :string, required: true)

  slot(:inner_block)

  def profile_link(assigns) do
    ~H"""
    <div class="flex items-center profile-link">
      <span class="rounded-full bg-blue-80 h-12 w-12 flex-center">
        <%= render_slot(@inner_block) %>
      </span>
      <DesignSystem.link href={@href} class="w-12 text-left link">
        <.text size="base" color="text-blue-80">
          <%= @label %>
        </.text>
      </DesignSystem.link>
    </div>
    """
  end

  @impl true
  def handle_event("edit_profile", _, socket) do
    {:noreply, socket}
  end

  def handle_event("trigger_reset_pass", %{"reset_pass" => params}, socket) do
    # TODO criar função para verificar se a senha atual é correta

    case recover_pass_changeset(params) do
      {:ok, attrs} ->
        case Supabase.Auth.update_user(socket, %{password: attrs.password}) |> IO.inspect() do
          {:ok, socket} -> {:noreply, redirect(socket, to: ~p"/app/pesquisa/perfil")}
          {:error, error} -> {:noreply, assign_error(socket, error)}
        end

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Os campos foram preenchidos incorretamente")}
    end
  end

  defp recover_pass_changeset(params) do
    import Ecto.Changeset

    types = %{password: :string, password_confirmation: :string}

    {%{}, types}
    |> cast(params, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_confirmation(:password)
    |> apply_action(:parse)
  end

  defp assign_error(socket, %{"weak_password" => %{"reasons" => reasons}}) do
    for reason <- reasons, reduce: socket do
      socket -> assign_error_reason(socket, reason)
    end
  end

  defp assign_error(socket, _) do
    put_flash(socket, :error, "Não vou possível atualizar sua senha, tente novamente")
  end

  defp assign_error_reason(socket, "length") do
    put_flash(socket, :error, "A nova senha precisa de no mínimo 12 caracteres")
  end

  defp assign_error_reason(socket, "characters") do
    socket
    |> put_flash(:error, "A nova senha precisa de no mínimo um caractere alfabético")
    |> put_flash(:error, "A nova senha precisa de no mínimo um caractere numérico")
    |> put_flash(:error, "A nova senha precisa de no mínimo um caractere especial")
  end
end
