defmodule PescarteWeb.DesignSystem do
  @moduledoc """
  Este módulo implementa os componentes que
  respeitam o design system, que pode ser encontrado no link
  a seguir: https://www.figma.com/file/PhkO37jz3ofCHwc1pHtPyz/PESCARTE?node-id=0%3A1&t=Glx6Q8JbPkPX9gZx-1
  """

  use Phoenix.Component
  use PescarteWeb, :verified_routes

  import PhoenixHTMLHelpers.Tag, only: [content_tag: 3]

  alias PescarteWeb.DesignSystem.SearchInput
  alias Phoenix.LiveView.JS

  @text_sizes ~w(h1 h2 h3 h4 h5 base lg sm)

  @doc """
  Este componente renderiza um texto, porém com os estilos
  do espaçamento de linha e tamanho de fonte já pré-configurados.

  Também recebe um atributo chamado `color`, que é uma classe do TailwindCSS
  que representa uma cor específica da paleta que o Design System define.

  Caso o atributo `color` não seja fornecido, a cor padrão - `black-80` -
  será utilizada.

  Para ver as cores disponívels, execute o comando `mix tailwind.view`.

  Você pode prover classes adicionais para estilização, com o atributo
  opcional `class`, que recebe uma string.

  ## Exemplo

      <.text size="h1"> Lorem ipsum dolor sit amet </.text>
  """

  attr :size, :string, values: @text_sizes, required: true
  attr :color, :string, default: "text-black-80"
  attr :class, :string, required: false, default: ""
  attr :style, :string, default: ""

  slot :inner_block

  def text(%{size: "h" <> _} = assigns) do
    ~H"""
    <%= content_tag @size, class: get_text_style(@size, @color, @class), style: @style do %>
      {render_slot(@inner_block)}
    <% end %>
    """
  end

  def text(assigns) do
    ~H"""
    <p class={get_text_style(@size, @color, @class)} style={@style}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  defp get_text_style("h1", color, custom_class),
    do: get_text_style("text-4xl leading-10 font-bold" <> " " <> color, custom_class)

  defp get_text_style("h2", color, custom_class),
    do: get_text_style("text-3xl leading-8 font-bold" <> " " <> color, custom_class)

  defp get_text_style("h3", color, custom_class),
    do: get_text_style("text-2xl leading-7 font-bold" <> " " <> color, custom_class)

  defp get_text_style("h4", color, custom_class),
    do: get_text_style("text-xl leading-6 font-medium" <> " " <> color, custom_class)

  defp get_text_style("h5", color, custom_class),
    do: get_text_style("text-lg leading-3 font-medium" <> " " <> color, custom_class)

  defp get_text_style("base", color, custom_class),
    do: get_text_style("text-base leading-4 font-medium" <> " " <> color, custom_class)

  defp get_text_style("lg", color, custom_class),
    do: get_text_style("text-lg leading-5 font-regular" <> " " <> color, custom_class)

  defp get_text_style("sm", color, custom_class),
    do: get_text_style("text-sm leading-3 font-regular" <> " " <> color, custom_class)

  defp get_text_style(final_class, custom_class) do
    final_class <> " " <> custom_class
  end

  @doc """
  Componente de botão, que representa uma ação na plataforma.

  Esse componente possui 2 variantes:

  - Primário
  - Secundário

  que é controlado pelo atributo `style`.

  Esse componente també pode ter um ícone em conjunto com o texto,
  basta informar o nome do ícone da biblioteca [lucide](https://lucide.dev),
  em minúsculo (veja o exemplo abaixo).

  Caso o componente esteja dentro de um formulário, passe o atributo `submit`,
  desta forma o botão irá ser acionado assim que o formua'ário tiver seu
  preenchimento finalizado.

  ## Exemplo

      <.button style="primary"> Primário </.button>

      <.button style="secondary"> Secundário </.button>

      <.button style="primary" submit> Submissão </.button>
  """

  attr :name, :string, default: ""
  attr :value, :string, default: ""
  attr :style, :string, values: ~w(primary secondary link), required: true
  attr :submit, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :string, default: ""
  attr :click, :string, default: "", doc: ~s(the click event to handle)
  attr :rest, :global, doc: ~s(used for phoenix events like "phx-target")

  slot :inner_block

  def button(assigns) do
    ~H"""
    <button
      name={@name}
      value={@value}
      type={if @submit, do: "submit", else: "button"}
      class={["btn", "btn-#{@style}", @class]}
      phx-click={@click}
      disabled={@disabled}
      {@rest}
    >
      <.text :if={@style == "primary"} size="base" color="text-white-100">
        {render_slot(@inner_block)}
      </.text>

      <.text :if={@style != "primary"} size="base" color="text-blue-80">
        {render_slot(@inner_block)}
      </.text>
    </button>
    """
  end

  @doc """
  Um componente de rodapé para a plataforma, expondo os logos
  dos apoiadores e empresas parceiras.

  É um componente estático, sem atributos, sem estado.
  """
  def footer(assigns) do
    ~H"""
    <footer>
      <img class="hidden md:flex waves" src={~p"/images/footer/waves.svg"} />
      <div class="blocks">
        <div class="block">
          <.text size="base" color="text-white-100" class="block-tag">
            Projeto de Educação Ambiental
          </.text>
          <div class="block-image">
            <img src={~p"/images/pescarte_logo.svg"} />
          </div>
        </div>
        <div class="divider"></div>
        <div class="block">
          <.text size="base" color="text-white-100" class="block-tag">
            Execução
          </.text>
          <div class="block-image">
            <img src={~p"/images/footer/logo_ipead.svg"} />
            <img src={~p"/images/footer/logo_uenf.svg"} />
          </div>
        </div>
        <div class="divider"></div>
        <div class="block">
          <.text size="base" color="text-white-100" class="block-tag">
            Empreendedor
          </.text>
          <div class="block-image">
            <img src={~p"/images/footer/logo_petrobras.svg"} />
          </div>
        </div>
        <div class="divider"></div>
        <div class="block">
          <.text size="base" color="text-white-100" class="block-tag">
            Órgão Licenciador
          </.text>
          <div class="block-image">
            <img src={~p"/images/footer/logo_ibama.svg"} />
          </div>
        </div>
        <div class="divider"></div>
        <div class="block">
          <.text size="base" color="text-blue-100" class="block-text">
            A realização do Projeto Pescarte é uma medida de mitigação exigida pelo licenciamento ambiental federal, conduzido pelo IBAMA.
          </.text>
        </div>
      </div>
    </footer>
    """
  end

  ### COMPONENTES DE INPUT ####

  @doc """
  Componente de checkbox, usado para representar valores que podem
  ter um valor ambíguo.

  O mesmo obrigatoriamente recebe o atributos `label`, que representa a etiqueta,
  o texto nome do campo em questão que é um checkbox.

  Também é possível controlar dinamicamente se o componente será desabilitado
  ou se o valor do checkbox será "assinado" com atributos `disabled` e
  `checked` respectivamente.

  ## Exemplo

      <.checkbox id="send-emails" label="Deseja receber nossos emails?" checked />
  """

  attr :id, :string, required: false
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :label, :string, required: false, default: ""
  attr :field, Phoenix.HTML.FormField
  attr :name, :string
  attr :required, :boolean, default: false

  def checkbox(%{field: %Phoenix.HTML.FormField{}} = assigns) do
    assigns
    |> input()
    |> checkbox()
  end

  def checkbox(assigns) do
    ~H"""
    <div class="flex items-center checkbox-container">
      <input
        id={@name}
        name={@name}
        type="checkbox"
        checked={@checked}
        disabled={@disabled}
        value={@value}
        required={@required}
      />
      <label for={@name}>
        <.text size="base">{@label}</.text>
      </label>
    </div>
    """
  end

  @doc """
  Componente de radio, usado para representar valores que podem
  ter um valor ambíguo.

  O mesmo obrigatoriamente recebe o atributos `label`, que representa a etiqueta,
  o texto nome do campo em questão que é um radio.

  Também é possível controlar dinamicamente se o componente será desabilitado
  ou se o valor do radio será "assinado" com atributos `disabled` e
  `checked` respectivamente.

  ## Exemplo

      <.checkbox id="send-emails" label="Deseja receber nossos emails?" checked />
  """

  attr :id, :string, required: true
  attr :name, :string
  attr :disabled, :boolean, default: false
  attr :checked, :boolean, default: false
  attr :field, Phoenix.HTML.FormField

  slot :label, required: true

  def radio(%{field: %Phoenix.HTML.FormField{}} = assigns) do
    assigns
    |> input()
    |> radio()
  end

  def radio(assigns) do
    ~H"""
    <div class="radio-container">
      <input
        id={@id}
        name={@name}
        type="radio"
        disabled={@disabled}
        checked={@checked}
        class="radio-input"
      />
      <label for={@id} class="radio-label">
        <.text size="base">{render_slot(@label)}</.text>
      </label>
    </div>
    """
  end

  @doc """
  Um componente de input de texto, para receber entradas da pessoa
  usuária.

  O mesmo recebe obrigatoriamente os atributos `name` e `label`,
  para que seja possível o formulário que usar este componente
  direcionar corretamente o dado da entrada da pessoa usuária, e a
  etiqueta para ficar visivel sobre o que se trata o input em questão.

  Opcionalmente o componente também recebe o atributo `mask`, que controla
  o formato do texto que será escrito. Por exemplo um documento CPF tem o
  formato "111.111.111-11".

  Além disso é possível definir um texto de ajuda que será colocado "dentro"
  do componte, com o atributo `placeholder`.

  Caso queira dar um valor inicial para o componente, use o atributo `value`!

  ## Exemplo

      <.text_input name="cpf" mask="999.999.999-99" label="CPF" />

      <.text_input name="password" label="Senha" type="password" />
  """

  attr :id, :string, default: nil
  attr :type, :string, default: "text", values: ~w(date hidden text password email phone)
  attr :placeholder, :string, required: false, default: ""
  attr :value, :string, required: false
  attr :mask, :string, required: false, default: nil
  attr :valid, :boolean, required: false, default: nil
  attr :label, :string, default: nil
  attr :field, Phoenix.HTML.FormField
  attr :name, :string

  attr :rest, :global, include: ~w(autocomplete disabled pattern placeholder readonly required)

  def text_input(%{field: %Phoenix.HTML.FormField{}} = assigns) do
    assigns
    |> input()
    |> text_input()
  end

  def text_input(assigns) do
    ~H"""
    <fieldset class="text-input-container">
      <label :if={@label} for={@name}>
        <.text size="h4">{@label}</.text>
      </label>
      <div class="input-space">
        <input
          id={@id}
          name={@name}
          value={@value}
          type={@type}
          placeholder={@placeholder}
          data-inputmask={if @mask, do: "mask: #{@mask}"}
          class={[
            "input",
            if(@type == "password", do: "password-toggle", else: ""),
            text_input_state(@valid)
          ]}
          {@rest}
        />
        <button
          :if={@type == "password"}
          type="button"
          class="eye-button"
          phx-click={JS.toggle_attribute({"type", "password", "text"}, to: ".password-toggle")}
        >
          <Lucideicons.eye />
        </button>
      </div>
      <span :if={!is_nil(@valid)} class="dot">
        <Lucideicons.circle_check :if={@valid} />
        <Lucideicons.circle_x :if={!@valid} />
      </span>
    </fieldset>
    """
  end

  defp text_input_state(nil), do: "input-default"
  defp text_input_state(false), do: "input-error"
  defp text_input_state(true), do: "input-success"

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :any
  attr :field, Phoenix.HTML.FormField
  attr :label, :string, default: nil
  attr :prompt, :string, default: nil
  attr :options, :list
  attr :multiple, :boolean, default: false
  attr :rest, :global, include: ~w(autocomplete disabled pattern placeholder readonly required)

  def select(%{field: %Phoenix.HTML.FormField{}} = assigns) do
    assigns
    |> input()
    |> select()
  end

  def select(assigns) do
    ~H"""
    <fieldset class="select-input-container">
      <label :if={@label} for={@name}>
        <.text size="h4">{@label}</.text>
      </label>
      <select id={@id} name={@name} class="select-input" multiple={@multiple} {@rest}>
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
    </fieldset>
    """
  end

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :placeholder, :string, required: false, default: ""
  attr :field, Phoenix.HTML.FormField
  attr :value, :string, default: ""
  attr :valid, :boolean, required: false, default: nil
  attr :class, :string, default: ""

  slot :label, required: false

  def text_area(%{field: %Phoenix.HTML.FormField{}} = assigns) do
    assigns
    |> input()
    |> text_area()
  end

  def text_area(assigns) do
    ~H"""
    <fieldset class={@class}>
      <.text size="base">{render_slot(@label)}</.text>
      <div class="textarea-grow-wrapper">
        <textarea
          id={@id}
          name={@name}
          placeholder={@placeholder}
          disabled={@disabled}
          default=""
          class="textarea"
        ><%= @value%></textarea>
      </div>
    </fieldset>
    """
  end

  @doc """
  Um componente de date picker, para selecionar datas.

  O mesmo recebe obrigatoriamente o atributo `name`.

  Caso queira dar um valor inicial para o componente, use o atributo `value`!

  ## Exemplo

      <.date_input name="aniversario"/>

  """
  attr :name, :string, required: true
  attr :class, :string, default: ""
  attr :value, :string, default: ""

  def date_input(%{field: %Phoenix.HTML.FormField{}} = assigns) do
    assigns
    |> input()
    |> date_input()
  end

  def date_input(assigns) do
    ~H"""
    <div class={["date_input", @class]}>
      <div class="date_input__container">
        <input type="text" id="air-datepicker" class="input" placeholder="dd/mm/aaaa" value={@value} />
        <Lucideicons.calendar_days class="date_input--suffix" />
      </div>
    </div>
    """
  end

  @doc """
  Um componente de pesquisa. Esta função apenas renderiza um componente
  com estado, definido em `PescarteWeb.DesignSystem.SearchInput`.

  Além dos atributos obrigatórios: `:id` e `:name`, também recebe as seguintes
  propriedades:

  - `:content`: controla o conteúdo, a lista de itens onde será aplicada a busca;
  - `:placeholder`: controla a mensagem temporária, antes da pessoa usuária digitiar;
  - `:field`: Recebe um campos de um formuário phoenix, dessa forma é possível submetê-lo;
  - `:size`: controla o tamnho do componente, possui apenas duas variações:
    - `base`: tamanho padrão
    - `large`: tamanho grande

  ## Exemplo

      <.search_input id="teste" name="busca_cep" content=["cep1", "cep2"] />

      <.search_input id="teste" name="busca_cep" content=["cep1", "cep2"] size="large" />
  """

  attr :id, :string, required: true
  attr :meta, Flop.Meta, required: true
  attr :placeholder, :string, default: "Faça uma pesquisa..."
  attr :size, :string, values: ~w(base large), default: "base"
  attr :patch, :string, required: true
  attr :fields, :list, required: true

  def search_input(%{field: %Phoenix.HTML.FormField{}} = assigns) do
    assigns
    |> input()
    |> search_input()
  end

  def search_input(assigns) do
    assigns = assign(assigns, assigns: assigns)

    ~H"""
    <.live_component module={SearchInput} {@assigns} />
    """
  end

  # função interna para criação de inputs dinâmicos
  # cada componente de input possui sua função própria
  # para melhor semântica, como `text_input` ou `checkbox`
  defp input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(:name, fn -> if assigns[:multiple], do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
  end

  ### ACABA COMPONENTES DE INPUT ####

  attr(:name, :atom, required: true)
  attr(:class, :string, required: true)

  def icon(assigns) do
    assigns = Map.delete(assigns, :__given__)
    apply(Lucideicons, assigns.name, [assigns])
  end

  @doc """
  Componente para criar links, que direcionam o usuário para outras
  páginas internas da aplicação ou páginas externas de outras aplicações.

  Recebe os mesmos atributos do componente nativo `Phoenix.Component.link/1`:

  - `navigate`: redireciona a pessoa usuária, sem recarregar a página
  - `patch`: redireciona a pessoa usuária para a mesma página, com parâmetros diferentes
  - `href`: redireciona a pessoa usuária para outra página, interna ou externa da aplicação,
  recarregando a página atual.

  Além desses atributos esse componente precisa de uma `label`, que será o texto
  exibido ao renderizar o link e também aceita um atributo opcional que controla
  o tamanho da fonte do texto renderizado. Os possíveis valores são os mesmos que
  o componente de texto definido em `PescarteWeb.DesignSystem.text/1`.

  ## Exemplo

      <.link navigate={~p"/app/perfil"}>Ir para Perfil</.link>

      <.link href="https://google.com" text_size="lg">Google.com</.link>

      <.link patch={~p"/app/relatorios"} text_size="lg">Recarregar lista de relatórios</.link>
  """

  attr :navigate, :string, required: false, default: nil
  attr :patch, :string, required: false, default: nil
  attr :href, :string, required: false, default: nil
  attr :method, :string, default: "get", values: ~w(get put post delete patch)
  attr :styless, :boolean, default: false
  attr :class, :string, default: ""
  attr :"target-blank", :boolean, default: false
  attr :"on-click", :string, default: ""

  slot :inner_block

  def link(assigns) do
    ~H"""
    <Phoenix.Component.link
      navigate={@navigate}
      patch={@patch}
      href={@href}
      method={@method}
      class={[if(!@styless, do: "link"), @class]}
      phx-click={Map.get(assigns, :"on-click")}
      target={if Map.get(assigns, :"target-blank"), do: "_blank", else: "_self"}
    >
      {render_slot(@inner_block)}
    </Phoenix.Component.link>
    """
  end

  @doc """
  Renderiza um formulário simples.

  ## Exemplos

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "a entidade de dados que será usada no formulário"
  attr :as, :any, default: nil, doc: "o parâmetro do lado do servidor para ser coletado os dados"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "atributos HTML adicionais e opcionais a serem adicionados na tag do formulário"

  slot :inner_block, required: true
  slot :actions, doc: "slot para ações do formulário, como o botão de submissão"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      {render_slot(@inner_block, f)}
      <%= for action <- @actions do %>
        {render_slot(action, f)}
      <% end %>
    </.form>
    """
  end

  @doc """
  Renders image from Supabase
  """
  attr :src, :string, required: true, doc: "the image source"
  attr :alt, :string, required: false, default: "", doc: "the image alt"
  attr :class, :string, default: "", doc: "the image class"

  def supabase_image(assigns) do
    IO.inspect(assigns.src)
    assigns =
      with {:ok, client} <- Pescarte.Supabase.get_client(),
           {:ok, bucket} <- Supabase.Storage.BucketHandler.retrieve_info(client, "static"),
           {:ok, url} <- Supabase.Storage.create_signed_url(client, bucket, assigns.src, 3600) do
        modified_url = String.replace(url, "/object/", "/storage/v1/object/")

        Map.put(assigns, :src, modified_url)
      end

    ~H"""
    <img src={@src} alt={@alt} class={@class} />
    """
  end

  @doc """
  Renders flash notices.
  ## Examples
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"

  attr :kind, :atom,
    values: [:success, :warning, :error],
    doc: "used for styling and flash lookup"

  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={["flash-component", Atom.to_string(@kind), "show"]}
      {@rest}
    >
      <div class="flash">
        <Lucideicons.circle_check :if={@kind == :success} class="flash-icon" />
        <Lucideicons.info :if={@kind == :warning} class="flash-icon" />
        <Lucideicons.circle_x :if={@kind == :error} class="flash-icon" />
        <.text size="lg">{msg}</.text>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.
  ## Examples
      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:success} flash={@flash} />
    <.flash kind={:warning} flash={@flash} />
    <.flash kind={:error} flash={@flash} />
    """
  end

  @doc """
  Renderiza uma tabela com diferentes colunas
  """
  attr :items, :list, required: true, doc: "a lista de itens a serem exibidos na tabela"
  attr :meta, :map, required: true, doc: "metadados da tabela"

  attr :path, :string,
    required: true,
    doc: "a uri para qual a tabela deve enviar eventos de filtro e ordenação"

  slot :column, doc: "Columns with column labels" do
    attr :label, :string, required: true, doc: "O rótulo da coluna"
    attr :field, :atom, doc: "O campo da entidade de dados a ser exibido na coluna"
  end

  def table(assigns) do
    ~H"""
    <Flop.Phoenix.table items={@items} meta={@meta} path={@path}>
      <:col :let={data} :for={col <- @column} label={col.label} field={col.field}>
        {render_slot(col, data)}
      </:col>
    </Flop.Phoenix.table>
    """
  end

  @doc """
  Componente de etiqueta, pode ser usado como marcador de imagens, de palavras chave
  ou mesmo para visualização de dados diferentes dentro de um mesmo contexto.

  Recebe os atributos:
  - `message`: texto a ser exibido na label

  """

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :message, :string, default: nil

  def label(assigns) do
    ~H"""
    <div class="label_component">
      <.text size="base" color="text-white-100">{@message}</.text>
    </div>
    """
  end

  @doc """
  Renderiza um dropdown - versão 4/10/2023:
  """
  def report_menu_link(assigns) do
    ~H"""
    <div class="profile-menu-link">
      <span class="flex items-center justify-center bg-white-100">
        {render_slot(@inner_block)}
      </span>
      <.button style="link" class="whitespace-nowrap" click={@click} phx-target=".profile-menu-link">
        <.text size="base" color="text-blue-80">
          <Lucideicons.credit_card class="text-blue-100" />
          {@label}
        </.text>
      </.button>
    </div>
    """
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :title, :string, default: ""

  slot :inner_block, required: true

  slot :footer, required: false do
    attr :class, :string
    attr :style, :string
  end

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-20 hidden"
      data-show={show_modal(@id)}
    >
      <div
        id={"#{@id}-bg"}
        class="bg-blue-60 fixed inset-0 transition-opacity"
        aria-hidden="true"
        style="opacity: 0.5;"
      />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex items-center justify-center" style="min-height: 100%">
          <div class="w-full" style="width: 484px;">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="relative hidden rounded-2xl bg-white-100 transition"
              style="width: 484px; padding: 24px; min-height: 340px;"
            >
              <div
                class="w-full right-5 flex justify-between"
                style="top: 1.25rem; align-items: center; max-width: 442px;"
              >
                <.text size="h2" color="black-80">
                  {@title}
                </.text>
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="flex-none hover:opacity-40 border-black-80 rounded-full"
                  style="width: 30px; height: 30px; border-width: 1.5px;"
                  aria-label="close modal button"
                >
                  <Lucideicons.x class="text-black-80" style="margin: auto" />
                </button>
              </div>
              <div id={"#{@id}-content"} style="margin: 64px 0;">
                {render_slot(@inner_block)}
              </div>
              <div
                :for={footer <- @footer}
                id={"#{@id}-footer"}
                class={Map.get(footer, :class)}
                style={Map.get(footer, :style)}
              >
                {render_slot(footer)}
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end

## inserindo funções para determinar tamanho de texto:
## deu erro quando inseri o código desenvolvido em landing_html.ex ==> 16/08/2024
