defmodule PescarteWeb.Router do
  use PescarteWeb, :router

  import PescarteWeb.Auth

  alias PescarteWeb.Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PescarteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :graphql do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PescarteWeb.GraphQL.Context
  end

  scope "/api" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: PescarteWeb.GraphQL.Schema
  end

  scope "/", PescarteWeb do
    pipe_through :browser

    get "/", LandingController, :show
    get "/equipes", EquipesController, :show
    get "/cooperativas", CooperativasController, :show
    get "/sobre", AboutUsController, :show
    get "/publicacoes", JournalController, :show
    get "/censo", CensoController, :show
    get "/confirmar", TokenController, :confirm
    get "/pgtrs", PGTRSController, :show
    get "/pgtr", PGTRController, :show
    get "/naipa", NaipaController, :show
    get "/sedes", SedesController, :show
    get "/aplicativos", AplicativosController, :show
    live "/noticias", Blog.NoticiasLive.Show


    delete "/acessar", LoginController, :delete

    get "/agenda", AgendaController, :show

    scope "/noticias" do
      get "/noti1", Noti1Controller, :show
      get "/noti2", Noti2Controller, :show
      get "/noti3", Noti3Controller, :show
      get "/noti4", Noti4Controller, :show
      get "/noti5", Noti5Controller, :show
      get "/noti6", Noti6Controller, :show
      get "/noti7", Noti7Controller, :show
      get "/noti8", Noti8Controller, :show
      get "/noti9", Noti9Controller, :show
      live "/:id", Blog.PostLive.Show
    end

    scope "/publicacoes" do
      get "/artigos", ArticleController, :show
      get "/livros", LivrosController, :show
      get "/boletins", BoletinsController, :show
      get "/relato_publico", RelatoPublicoController, :show
    end

    scope "/contato" do
      get "/", ContactController, :show
      get "/success", ContactController, :success
      get "/failed", ContactController, :failed
      post "/", ContactController, :send_email
    end
  end

  scope "/", PescarteWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live "/acessar", LoginLive, :show
    post "/acessar", LoginController, :create
  end

  scope "/app/pesquisa", PescarteWeb.Pesquisa do
    pipe_through :browser

    live_session :require_authenticated_user,
      on_mount: [
        PescarteWeb.NavbarLive,
        {PescarteWeb.SessionContext, :mount_session_from_conn},
        {Auth, :ensure_authenticated},
        {PescarteWeb.Flash, :flash}
      ] do
      live "/perfil", PesquisadorLive.Show, :show

      scope "/pesquisadores" do
        live "/", PesquisadorLive.Index, :index
        live "/cadastro", PesquisadorLive.Index, :new
        live "/:id", PesquisadorLive.Show, :show
      end

      scope "/relatorios" do
        live "/", RelatorioLive.Index, :index
        live "/:id/editar/:tipo", RelatorioLive.Index, :edit
        get "/:id/download-pdf", RelatorioController, :download_pdf
        post "/compilar-relatorios", RelatorioController, :compilar_relatorios
        live "/novo/:tipo", RelatorioLive.Index, :new
      end
    end
  end
end
