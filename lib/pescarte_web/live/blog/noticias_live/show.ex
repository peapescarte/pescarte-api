defmodule PescarteWeb.Blog.NoticiasLive.Show do
  use PescarteWeb, :live_view

  alias Pescarte.Blog

  @notice_title_max_length Application.compile_env!(:pescarte, [
                             PescarteWeb,
                             :notice_title_max_length
                           ])

  @notice_desc_max_length Application.compile_env!(:pescarte, [
                            PescarteWeb,
                            :notice_desc_max_length
                          ])
  @impl true
  def mount(_params, _session, socket) do

    [main_new | news] = Blog.list_posts_with_filter()

    socket =
      socket
      |> assign(%{error_message: nil, news: news, main_new: main_new})

    {:ok, socket}
  end

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

  @impl true
  def handle_event("more_news", _params, socket) do
    current_news_length = socket.assigns.news.length
    loaded_news = Blog.list_posts_with_filter(%{page: current_news_length + 1, page_size: 6})

    IO.inspect("funcionou")

    socket = socket |> assign(news: socket.assigns.news ++ loaded_news)

    {:noreply, socket}
  end

  @impl true
  def handle_event("dialog", _value, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="noticias-grid">
      <.flash :if={@error_message} id="login-error" kind={:error}>
        <%= @error_message %>
      </.flash>
      <!--<div class="land-carousel">
      <.text size="h2" color="text-blue-100">Galeria de Notícias Pescarte</.text>
    <div class="glide1">
      <div class="glide__track" data-glide-el="track">
        <ul class="glide__slides">
          <li class="glide__slide">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/seminario%20pesca/interna1.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL3NlbWluYXJpbyBwZXNjYS9pbnRlcm5hMS5KUEciLCJpYXQiOjE3MjQ0MjEzNzAsImV4cCI6MjAzOTc4MTM3MH0.cuu5MTJuVaRDsBHa3_JbzLhO-QjnbdkbZUNkmP5xGJo&t=2024-08-23T13%3A56%3A10.362Z" />
          </li>
          <li class="glide__slide">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/grupos%20focais/interna.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL2dydXBvcyBmb2NhaXMvaW50ZXJuYS5KUEciLCJpYXQiOjE3MjQ0MjExMTEsImV4cCI6MjAzOTc4MTExMX0.vXUzVUkScTiPy9sv84a4YLFzrUAlP55SwU73AvRatZE&t=2024-08-23T13%3A51%3A51.153Z" />
          </li>
          <li class="glide__slide">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/realinhamento%20pesquisa/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL3JlYWxpbmhhbWVudG8gcGVzcXVpc2EvY2FwYS5KUEciLCJpYXQiOjE3MjQ0MTk4ODQsImV4cCI6MjAzOTc3OTg4NH0.Wbh5_ZGtPO6xO4VMnxAI5admEo6XdU1FUacdPMwlJSA&t=2024-08-23T13%3A31%3A24.302Z" />
          </li>
          <li class="glide__slide">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/mapeamento%20mercado/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL21hcGVhbWVudG8gbWVyY2Fkby9jYXBhLkpQRyIsImlhdCI6MTcyNDQxOTgyOCwiZXhwIjoyMDM5Nzc5ODI4fQ.TxJyAKUE4gvGwGDBOMd4bCupVFCyCO1OLDfbfa0Z_oE&t=2024-08-23T13%3A30%3A29.142Z" />
          </li>
          <li class="glide__slide">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/mulheres%20e%20direitos/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL211bGhlcmVzIGUgZGlyZWl0b3MvY2FwYS5KUEciLCJpYXQiOjE3MjQ0MjA0NzIsImV4cCI6MjAzOTc4MDQ3Mn0.sewu3JT9ZCyFomQkKeuf6HMGnA3dtEmnIupv0Y7AWyY&t=2024-08-23T13%3A41%3A12.698Z" />
          </li>
          <li class="glide__slide">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/tecnologia%20social/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL3RlY25vbG9naWEgc29jaWFsL2NhcGEuSlBHIiwiaWF0IjoxNzI0NDE4NDQzLCJleHAiOjIwMzk3Nzg0NDN9.i6DpnsFFdRpOuEy5Kqyu0h_S7ziJt1p1qtmD94YkB6k&t=2024-08-23T13%3A07%3A23.299Z" />
          </li>
        </ul>
      </div>

      <div class="glide__bullets" data-glide-el="controls[nav]">
        <button class="glide__bullet" data-glide-dir="=0"></button>
        <button class="glide__bullet" data-glide-dir="=1"></button>
        <button class="glide__bullet" data-glide-dir="=2"></button>
      </div>
            <div class="glide__progress">
        <div class="glide__progress-bar"></div>
      </div>
    </div>
    </div>-->
      <div class="phases">
        <div class="noticia-text">
          <.text size="h2" color="text-blue-100">
            Notícias
          </.text>
        </div>
      </div>

      <div class="search-container">
        <input type="text" name="search" id="search" placeholder="Faça uma pesquisa..." />
        <ul class="tags-container">
          <li phx-click={JS.toggle_class("active")}>Tag</li>
          <li phx-click={JS.toggle_class("active")}>Tag</li>
          <li class="active" phx-click={JS.toggle_class("active")}>Tag</li>
          <li phx-click={JS.toggle_class("active")}>Tag</li>
          <li phx-click={JS.toggle_class("active")}>Tag</li>
          <li phx-click={JS.toggle_class("active")}>Tag</li>
          <li phx-click={JS.toggle_class("active")}>Tag</li>
        </ul>
      </div>

      <div class="main-new">
        <a href={"noticias/#{@main_new.id}"}>
          <img
            src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/grupos%20focais/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL2dydXBvcyBmb2NhaXMvY2FwYS5KUEciLCJpYXQiOjE3MjQ0MjEwOTcsImV4cCI6MjAzOTc4MTA5N30.0BiAS0ILyBpEIigMQ7fxQ07zkiV5h_EsUCRQ4FpWYJE&t=2024-08-23T13%3A51%3A37.851Z"
            alt=""
          />
        </a>
        <div class="main-new-text-container">
          <p class="news-date"><%= date_to_string(@main_new.inserted_at) %></p>
          <a href={"noticias/#{@main_new.id}"}>
            <h3 class="news-title">
              <%= @main_new.titulo %>
            </h3>
          </a>
          <p class="news-description">
            <%= handle_notice_desc_length(@main_new.conteudo) %>
          </p>
        </div>
      </div>

      <div class="landing-grid">
        <div class="news-container">
          <div class="news-cards">
            <%= for new <- @news do %>
              <div class="news-item">
                <a href={"/noticias/#{new.id}"}>
                  <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/grupos%20focais/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL2dydXBvcyBmb2NhaXMvY2FwYS5KUEciLCJpYXQiOjE3MjQ0MjEwOTcsImV4cCI6MjAzOTc4MTA5N30.0BiAS0ILyBpEIigMQ7fxQ07zkiV5h_EsUCRQ4FpWYJE&t=2024-08-23T13%3A51%3A37.851Z" />
                </a>
                <div class="text-container">
                  <p class="news-date"><%= date_to_string(new.inserted_at) %></p>
                  <a href={"/noticias/#{new.id}"}>
                    <.text size="h4" color="text-blue-100">
                      <%= handle_notice_title_length(new.titulo) %>
                    </.text>
                  </a>
                  <.text size="base" color="text-black-60">
                    <%= handle_notice_desc_length(new.conteudo) %>
                  </.text>
                </div>
              </div>
            <% end %>
            <!-- criando noticias 23/10/2024 - atualizando noticias
        <div class="news-item">
          <a href="/noticias/noti9">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/grupos%20focais/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL2dydXBvcyBmb2NhaXMvY2FwYS5KUEciLCJpYXQiOjE3MjQ0MjEwOTcsImV4cCI6MjAzOTc4MTA5N30.0BiAS0ILyBpEIigMQ7fxQ07zkiV5h_EsUCRQ4FpWYJE&t=2024-08-23T13%3A51%3A37.851Z" />
          </a>
          <div class="text-container">
            <p class="news-date">00/00/0000</p>
            <a href="/noticias/noti9">
              <.text size="h4" color="text-blue-100">
                <%= handle_notice_title_length(
                  "Pescarte participa de plenária sudeste para a construção do Plano Nacional da Pesca Artesanal"
                ) %>
              </.text>
            </a>
            <.text size="base" color="text-black-60">
              <%= handle_notice_desc_length(
                "O evento aconteceu entre 9 e 11 de outubro, no Espírito Santo. Duas integrantes do PEA foram selecionadas para representar o Sudeste"
              ) %>
            </.text>
          </div>
        </div>
        <div class="news-item">
          <a href="/noticias/noti8">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/simposio%20linguagem/simposio_uenf.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL3NpbXBvc2lvIGxpbmd1YWdlbS9zaW1wb3Npb191ZW5mLnBuZyIsImlhdCI6MTcyNzI4NDQwMiwiZXhwIjoyMDQyNjQ0NDAyfQ.4RUC5wRB-R36FbQLghcjeLOpzC_z5nmf19Qv1ZlBgh8&t=2024-09-25T17%3A13%3A22.288Z" />
          </a>
          <div class="p-5">
            <a href="/noticias/noti8">
              <.text size="h4" color="text-blue-100">
                <%= handle_notice_title_length(
                  "PEA Pescarte realiza II Simpósio de Linguagens e Letramentos na UENF"
                ) %>
              </.text>
            </a>
            <.text size="sm" color="text-black-60">
              <%= handle_notice_desc_length(
                "Evento acontece no Centro de Convenções da UENF e será transmitido pelo canal do PEA Pescarte no YouTube"
              ) %>
            </.text>
            <DesignSystem.link href="/noticias/noti8" class="text-sm font-semibold">
              <.button style="primary">
                <.text size="base" color="text-white-100">Ler mais</.text>
              </.button>
            </DesignSystem.link>
          </div>
        </div>
        <div class="news-item">
          <a href="/noticias/noti7">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/naipa/naipa.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL25haXBhL25haXBhLnBuZyIsImlhdCI6MTcyNzI4NDQzMywiZXhwIjoyMDQyNjQ0NDMzfQ.7ly4B7p4P7AwmOLM8LrqSiQ3hclYJcacIhFAbsa_0sk&t=2024-09-25T17%3A13%3A53.944Z" />
          </a>
          <div class="p-5">
            <a href="/noticias/noti7">
              <.text size="h4" color="text-blue-100">
                <%= handle_notice_title_length(
                  "Núcleo de Autonomia e Incidência da Pesca Artesanal (NAIPA) atua com instituições ligadas à pesca"
                ) %>
              </.text>
            </a>
            <.text size="sm" color="text-black-60">
              <%= handle_notice_desc_length(
                "Atividades auxiliam que os pescadores e pescadoras participem da gestão sustentável e no
              desenvolvimento de políticas públicas e privadas no país"
              ) %>
            </.text>
            <DesignSystem.link href="/noticias/noti7" class="text-sm font-semibold">
              <.button style="primary">
                <.text size="base" color="text-white-100">Ler mais</.text>
              </.button>
            </DesignSystem.link>
          </div>
        </div>
        <div class="news-item">
          <a href="/noticias/noti5">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/seminario%20pesca/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL3NlbWluYXJpbyBwZXNjYS9jYXBhLkpQRyIsImlhdCI6MTcyNDQyMTM1MywiZXhwIjoyMDM5NzgxMzUzfQ.381ZTDzngM9obMbYg8lS0xIl9oMnWSgTf8m_G8uXRRQ&t=2024-08-23T13%3A55%3A53.068Z" />
          </a>
          <div class="p-5">
            <a href="/noticias/noti5">
              <.text size="h4" color="text-blue-100">
                <%= handle_notice_title_length(
                  "1ª edição do Seminário Internacional da Pesca Artesanal marca os 10 anos do PEA Pescarte e reúne mais de 500 pessoas"
                ) %>
              </.text>
            </a>
            <.text size="sm" color="text-black-60">
              <%= handle_notice_desc_length(
                "Evento reuniu representantes do Ministério da Pesca, Food and Agriculture Organization, Governo Moçambique e Universidade Autônoma de Barcelona"
              ) %>
            </.text>
            <DesignSystem.link href="/noticias/noti5" class="text-sm font-semibold">
              <.button style="primary">
                <.text size="base" color="text-white-100">Ler mais</.text>
              </.button>
            </DesignSystem.link>
          </div>
        </div>
        <div class="news-item">
          <a href="/noticias/noti6">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/grupos%20focais/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL2dydXBvcyBmb2NhaXMvY2FwYS5KUEciLCJpYXQiOjE3MjQ0MjEwOTcsImV4cCI6MjAzOTc4MTA5N30.0BiAS0ILyBpEIigMQ7fxQ07zkiV5h_EsUCRQ4FpWYJE&t=2024-08-23T13%3A51%3A37.851Z" />
          </a>
          <div class="p-5">
            <a href="/noticias/noti6">
              <.text size="h4" color="text-blue-100">
                <%= handle_notice_title_length(
                  "Núcleo de Pesquisa organiza grupos focais para levantamento de seis temáticas nas
                comunidades de pesca da região"
                ) %>
              </.text>
            </a>
            <.text size="sm" color="text-black-60">
              <%= handle_notice_desc_length(
                "Realizado nos 10 municípios no primeiro semestre de 2024, levantamento visa criar elementos
              para as pesquisas desenvolvidas no Pescarte"
              ) %>
            </.text>
            <DesignSystem.link href="/noticias/noti6" class="text-sm font-semibold">
              <.button style="primary">
                <.text size="base" color="text-white-100">Ler mais</.text>
              </.button>
            </DesignSystem.link>
          </div>
        </div>
        <div class="news-item">
          <a href="/noticias/noti4">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/mulheres%20e%20direitos/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL211bGhlcmVzIGUgZGlyZWl0b3MvY2FwYS5KUEciLCJpYXQiOjE3MjQ0MjA0NzIsImV4cCI6MjAzOTc4MDQ3Mn0.sewu3JT9ZCyFomQkKeuf6HMGnA3dtEmnIupv0Y7AWyY&t=2024-08-23T13%3A41%3A12.698Z" />
          </a>
          <div class="p-5">
            <a href="/noticias/noti4">
              <.text size="h4" color="text-blue-100">
                <%= handle_notice_title_length(
                  "Sessão de Encontro: Mulheres e Direitos promove o protagonismo feminino e o fortalecimento da pesca artesanal"
                ) %>
              </.text>
            </a>
            <.text size="sm" color="text-black-60">
              <%= handle_notice_desc_length(
                "Pesquisa tem o objetivo de compreender o comportamento do consumidor e dos fornecedores para levar aos PGTR como funciona o mercado de pescados"
              ) %>
            </.text>
            <DesignSystem.link href="/noticias/noti4" class="text-sm font-semibold">
              <.button style="primary">
                <.text size="base" color="text-white-100">Ler mais</.text>
              </.button>
            </DesignSystem.link>
          </div>
        </div>
        <div class="news-item">
          <a href="/noticias/noti1">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/tecnologia%20social/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL3RlY25vbG9naWEgc29jaWFsL2NhcGEuSlBHIiwiaWF0IjoxNzI0NDE4NDQzLCJleHAiOjIwMzk3Nzg0NDN9.i6DpnsFFdRpOuEy5Kqyu0h_S7ziJt1p1qtmD94YkB6k&t=2024-08-23T13%3A07%3A23.299Z" />
          </a>
          <div class="p-5">
            <a href="/noticias/noti1">
              <.text size="h4" color="text-blue-100">
                <%= handle_notice_title_length(
                  "Tecnologia social nos empreendimentos de geração de renda na cadeia da pesca artesanal é abordado em pesquisa"
                ) %>
              </.text>
            </a>
            <.text size="sm" color="text-black-60">
              <%= handle_notice_desc_length(
                "Estudo aponta tecnologias utilizadas na pesca e maricultura que auxiliem nas soluções
              de infraestrutura dos Projetos de Geração de Trabalho e Renda"
              ) %>
            </.text>
            <DesignSystem.link href="/noticias/noti1" class="text-sm font-semibold">
              <.button style="primary">
                <.text size="base" color="text-white-100">Ler mais</.text>
              </.button>
            </DesignSystem.link>
          </div>
        </div>
        <div class="news-item">
          <a href="/noticias/noti2">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/realinhamento%20pesquisa/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL3JlYWxpbmhhbWVudG8gcGVzcXVpc2EvY2FwYS5KUEciLCJpYXQiOjE3MjQ0MTk4ODQsImV4cCI6MjAzOTc3OTg4NH0.Wbh5_ZGtPO6xO4VMnxAI5admEo6XdU1FUacdPMwlJSA&t=2024-08-23T13%3A31%3A24.302Z" />
          </a>
          <div class="p-5">
            <a href="/noticias/noti2">
              <.text size="h4" color="text-blue-100">
                <%= handle_notice_title_length(
                  "Reunião de Avaliação e Realinhamento do Núcleo de Pesquisa promove ecologia de saberes no PEA Pescarte"
                ) %>
              </.text>
            </a>
            <.text size="sm" color="text-black-60">
              <%= handle_notice_desc_length(
                "Pesquisas desenvolvidas cumprem com o desafio de mitigar os impactos das atividades de extração e produção de petróleo e gás na Bacia de Campos"
              ) %>
            </.text>
            <DesignSystem.link href="/noticias/noti2" class="text-sm font-semibold">
              <.button style="primary">
                <.text size="base" color="text-white-100">Ler mais</.text>
              </.button>
            </DesignSystem.link>
          </div>
        </div>
        <div class="news-item">
          <a href="/noticias/noti3">
            <img src="https://rrosgcmviafnxjshljoq.supabase.co/storage/v1/object/sign/static/images/noticias/mapeamento%20mercado/capa.JPG?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJzdGF0aWMvaW1hZ2VzL25vdGljaWFzL21hcGVhbWVudG8gbWVyY2Fkby9jYXBhLkpQRyIsImlhdCI6MTcyNDQxOTgyOCwiZXhwIjoyMDM5Nzc5ODI4fQ.TxJyAKUE4gvGwGDBOMd4bCupVFCyCO1OLDfbfa0Z_oE&t=2024-08-23T13%3A30%3A29.142Z" />
          </a>
          <div class="p-5">
            <a href="/noticias/noti3">
              <.text size="h4" color="text-blue-100">
                <%= handle_notice_title_length(
                  " Levantamento do PEA Pescarte realiza o mapeamento do mercado do pescado em cidades do Rio de Janeiro"
                ) %>
              </.text>
            </a>
            <.text size="sm" color="text-black-60">
              <%= handle_notice_desc_length(
                "Pesquisa tem o objetivo de compreender o comportamento do consumidor e dos fornecedores para levar aos PGTR como funciona o mercado de pescados"
              ) %>
            </.text>
            <DesignSystem.link href="/noticias/noti3" class="text-sm font-semibold">
              <.button style="primary">
                <.text size="base" color="text-white-100">Ler mais</.text>
              </.button>
            </DesignSystem.link>
            <.button style="primary">
              <.text size="base" color="text-white-100">Ler mais</.text>
            </.button>
          </div>
        </div>-->
          </div>
        </div>
      </div>

      <div phx-click="more_news">
        <.button style="primary" >
          <.text size="base" color="text-wite-100">Ver mais...</.text>
        </.button>
      </div>
      <!-- ONDE NOS ENCONTRAR -->
      <PescarteWeb.DesignSystem.GetInTouch.render />
    </div>
    """
  end
end
