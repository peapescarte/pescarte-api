defmodule PescarteWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use PescarteWeb, :controller
      use PescarteWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths do
    ~w(assets fonts images favicon.ico apple-touch-icon.png favicon-32x32.png favicon-16x16.png safari-pinned-tab.svg browserconfig.xml service_worker.js cache_manifest.json manifest.json android-chrome-192x192.png android-chrome-384x384.png icons)
  end

  @spec controller :: Macro.t()
  def controller do
    quote do
      use Phoenix.Controller, namespace: PescarteWeb

      import Plug.Conn
      alias PescarteWeb.Router.Helpers, as: Routes

      unquote(verified_routes())
    end
  end

  @spec view :: Macro.t()
  def view do
    quote do
      use Phoenix.View,
        root: "lib/pescarte_web/templates",
        namespace: PescarteWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  @spec component :: Macro.t()
  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  @spec router :: Macro.t()
  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  @spec channel :: Macro.t()
  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  defp view_helpers do
    quote do
      use Phoenix.HTML

      import Phoenix.Component
      import Phoenix.View
      import Pescarte.Common.Common
      alias PescarteWeb.Components.Pesquisador
      alias PescarteWeb.Components.Button
      import PescarteWeb.Components
      alias PescarteWeb.Components.Perfil
      alias PescarteWeb.Components.Icon
      import PescarteWeb.ErrorHelpers
      import PescarteWeb.FormHelpers

      alias PescarteWeb.Router.Helpers, as: Routes
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: PescarteWeb.Endpoint,
        router: PescarteWeb.Router,
        statics: PescarteWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
