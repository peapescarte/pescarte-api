defmodule PescarteWeb.DesignSystem do
  @moduledoc """
  Define componentes base e configurações específicas
  do sistema de design desenvolvido para a plataforma
  Pescarte.

  O projeto do sistema de design pode ser encontrado nesse
  link: https://www.figma.com/file/PhkO37jz3ofCHwc1pHtPyz
  """

  use PescarteWeb, :verified_routes
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, values: ~w(button reset submit)
  attr :rounded?, :boolean, default: false
  attr :class, :string, default: nil
  attr :style, :string, values: ~w(primary secondary link)
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button type={@type} class={[@class, btn_class(@style, @rounded?)]} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp btn_class("primary", rounded) do
    """
    bg-blue-80 hover:bg-white text-base
    font-semibold leading-4 text-white
    #{if rounded, do: "rounded-full", else: "rounded"}
    """
  end

  defp btn_class("secondary", rounded) do
    """
    bg-white hover:border-blue-60 py-2
    px-3 border-1 text-base font-semibold leading-4
    text-blue-80 border-blue-80 hover:text-blue-60
    #{if rounded, do: "rounded-full", else: "rounded"}
    """

  end

  @doc """

  """
  def footer(assigns) do
    ~H"""
    <footer class="footer footer-center p-4 bg-white">
      <img src={~p"/images/footer_logos.svg"} alt={footer_alt_text()} class="w-3/5" />
    </footer>
    """
  end

  defp footer_alt_text do
    """
    Bloco de logos das instiuições relacionadas
    ao projeto Pescarte: IPEAD; UENF; Petrobras;
    e Ibama.
    """
  end

  @doc """
  """
  attr :conn, :any
  attr :path, :string
  attr :hidden?, :boolean, default: true

  def navbar(assigns) do
    ~H"""
    <nav class="navbar w-full">
      <div class="navbar-start flex justify-between">
        <div class="dropdown">
          <label tabindex="0" class="btn btn-ghost lg:hidden">
            <Lucideicons.menu stroke="#FF6E00" />
          </label>
          <ul
            tabindex="0"
            class="menu menu-compact dropdown-content dropdown-left mt-3 p-2 shadow bg-white rounded-box w-52"
          >
            <.menu_links current_user={@conn.assigns.current_user} path={@conn.path_info} />
          </ul>
        </div>
        <li class="btn btn-ghost"><.menu_logo hidden?={@hidden?} /></li>
      </div>
      <div class="navbar-center container hidden lg:flex lg:justify-center">
        <ul class="menu menu-horizontal p-0">
          <li class="menu-item"><.menu_logo hidden?={false} /></li>
          <.menu_links current_user={@conn.assigns.current_user} path={@conn.path_info} />
        </ul>
      </div>
    </nav>
    """
  end

  defp menu_logo(assigns) do
    ~H"""
    <figure>
      <img
        class={["mt-3", get_hidden_style(@hidden?)]}
        src={~p"/images/pescarte_logo.svg"}
        alt="Logo completo do projeto com os dez peixinhos e nome"
        width="150"
      />
    </figure>
    """
  end

  defp get_hidden_style(true), do: "lg:hidden"
  defp get_hidden_style(false), do: ""

  attr :path, :string
  attr :method, :string, default: "get"
  attr :current?, :boolean, default: false

  slot :inner_block, required: true

  defp menu_item(assigns) do
    ~H"""
    <li class="menu-item">
      <.link navigate={@path} method={@method} class={menu_item_class(@current?)}>
        <%= render_slot(@inner_block) %>
      </.link>
    </li>
    """
  end

  defp menu_item_class(current?) do
    """
    hover:text-white hover:bg-blue-60 btn btn-primary
    #{current? && "bg-blue-100 text-white" || "text-blue-100"}
    """
  end

  attr :path, :string
  attr :current_user, Pescarte.Accounts.Models.User, default: nil

  # Utiliza a função `Phoenix.LivewView.HTMLEngine.component/1`
  # manualmente para renderizar componentes dinâmicamente
  # dentro do `for/1`
  defp menu_links(assigns) do
    ~H"""
    <.authenticated_menu :if={@current_user} path={@path} />
    <.guest_menu :if={!@current_user} path={@path} />
    """
  end

  attr :path, :string

  defp authenticated_menu(assigns) do
    ~H"""
    <%= for item <- authenticated_menu_items() do %>
      <.menu_item
        path={item.path}
        method={item.method}
        current?={is_current_path?(@conn, item.path)}
      >
        <.icon name={item.icon} />
        <%= item.label %>
      </.menu_item>
    <% end %>
    """
  end

  attr :path, :string

  defp guest_menu(assigns) do
    ~H"""
    <%= for item <- guest_menu_items() do %>
      <.menu_item
        path={item.path}
        method={item.method}
        current?={is_current_path?(@path, item.path)}
      >
        <.icon name={item.icon} />
        <%= item.label %>
      </.menu_item>
    <% end %>
    <.button type="button" style="primary">
      <Lucideicons.log_in />
      Acessar
    </.button>
    """
  end

  attr :name, :atom, required: true

  defp icon(assigns) do
    apply(Lucideicons, assigns.name, [assigns])
  end

  defp is_current_path?([], "/"), do: true

  defp is_current_path?([], _to), do: false

  defp is_current_path?(path_info, to) do
    # get from %Plug.Conn{}
    path = Enum.join(path_info, "/")

    to =~ path
  end

  defp guest_menu_items do
    [
      %{path: "/", label: "Home", method: :get, icon: :home},
      %{path: "/pesquisa", label: "Pesquisa", method: :get, icon: :file},
      %{path: "/biblioteca", label: "Biblioteca", method: :get, icon: :book},
      %{
        path: "/agenda_socioambiental",
        label: "Agenda Socioambiental",
        method: :get,
        icon: :calendar
      }
    ]
  end

  defp authenticated_menu_items do
    [
      %{path: "/app/dashboard", label: "Home", method: :get, icon: :home},
      %{
        path: "/app/pesquisadores",
        label: "Pesquisadores",
        method: :get,
        icon: :users
      },
      %{path: "/app/relatorios", label: "Relatórios", method: :get, icon: :file},
      %{path: "/app/agenda", label: "Agenda", method: :get, icon: :calendar},
      %{path: "/app/mensagens", label: "Mensagens", method: :get, icon: :mail}
    ]
  end

  attr :level, :string, values: ["h1", "h2", "h3", "h4", "h5", "btn", "btn-lg", "btn-md", "btn-sm"]

  slot :inner_block, required: true

  def text(assigns) do
    ~H"""
    <h1 :if={@level == "h1"} class="font-bold text-3xl leading-10">
      <%= render_slot @inner_block %>
    </h1>
    <h2 :if={@level == "h2"} class="font-bold text-2xl leading-9">
      <%= render_slot @inner_block %>
    </h2>
    <h3 :if={@level == "h3"} class="font-bold text-xl leading-8">
      <%= render_slot @inner_block %>
    </h3>
    <h4 :if={@level == "h4"} class="font-medium text-lg leading-7">
      <%= render_slot @inner_block %>
    </h4>
    <h5 :if={@level == "h5"} class="font-bold text-base leading-4">
      <%= render_slot @inner_block %>
    </h5>
    <span :if={@level =~ "btn"} class={build_text_class(@level)}>
      <%= render_slot @inner_block %>
    </span>
    """
  end

  defp build_text_class(level) do
    case level do
      "btn" -> ["font-medium", "text-base", "leading-4"]
      "btn-lg" -> ["font-regular", "text-base", "leading-6"]
      "btn-md" -> ["font-regular", "text-sm", "leading-5"]
      "btn-sm" -> ["font-regular", "text-xs", "leading-4"]
    end
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}

  slot :inner_block, required: true
  slot :title
  slot :subtitle
  slot :confirm
  slot :cancel

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-zinc-50/90 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="hidden relative rounded-2xl bg-white p-14 shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={hide_modal(@on_cancel, @id)}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label="close"
                >
                  <Lucideicons.x_circle class="h-5 w-5 stroke-current" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <header :if={@title != []}>
                  <h1 id={"#{@id}-title"} class="text-lg font-semibold leading-8 text-zinc-800">
                    <%= render_slot(@title) %>
                  </h1>
                  <p
                    :if={@subtitle != []}
                    id={"#{@id}-description"}
                    class="mt-2 text-sm leading-6 text-zinc-600"
                  >
                    <%= render_slot(@subtitle) %>
                  </p>
                </header>
                <%= render_slot(@inner_block) %>
                <div :if={@confirm != [] or @cancel != []} class="ml-6 mb-4 flex items-center gap-5">
                  <.button
                    :for={confirm <- @confirm}
                    id={"#{@id}-confirm"}
                    phx-click={@on_confirm}
                    phx-disable-with
                    class="py-2 px-3"
                  >
                    <%= render_slot(confirm) %>
                  </.button>
                  <.link
                    :for={cancel <- @cancel}
                    phx-click={hide_modal(@on_cancel, @id)}
                    class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                  >
                    <%= render_slot(cancel) %>
                  </.link>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
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
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount"
  attr :close, :boolean, default: true, doc: "whether the flash can be closed"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && show("##{@id}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed hidden top-2 right-2 w-80 sm:w-96 z-50 rounded-lg p-3 shadow-md shadow-zinc-900/5 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 p-3 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-[0.8125rem] font-semibold leading-6">
        <Lucideicons.info :if={@kind == :info} class="h-4 w-4" />
        <Lucideicons.slash :if={@kind == :error} class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-[0.8125rem] leading-5"><%= msg %></p>
      <button :if={@close} type="button" class="group absolute top-2 right-1 p-2" aria-label="close">
        <Lucideicons.x_circle class="h-5 w-5 stroke-current opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form :let={f} for={:user} phx-change="validate" phx-submit="save">
        <.input field={{f, :email}} label="Email"/>
        <.input field={{f, :username}} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, default: nil, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="space-y-8 bg-white mt-10">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={{f, :email}} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any
  attr :name, :any
  attr :label, :string, default: nil

  attr :type, :string,
    default: "text",
    values: ~w(checkbox date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :value, :any
  attr :field, :any, doc: "a %Phoenix.HTML.Form{}/field name tuple, for example: {f, :email}"
  attr :errors, :list
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :rest, :global, include: ~w(autocomplete cols disabled form max maxlength min minlength
                                   pattern placeholder readonly required rows size step)
  slot :inner_block

  def input(%{field: {f, field}} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:name, fn ->
      name = Phoenix.HTML.Form.input_name(f, field)
      if assigns.multiple, do: name <> "[]", else: name
    end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> assign_new(:errors, fn -> f.errors || [] end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns = assign_new(assigns, :checked, fn -> input_equals?(assigns.value, "true") end)

    ~H"""
    <label phx-feedback-for={@name} class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
      <input type="hidden" name={@name} value="false" />
      <input
        type="checkbox"
        id={@id || @name}
        name={@name}
        value="true"
        checked={@checked}
        class="rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900"
        {@rest}
      />
      <%= @label %>
    </label>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id || @name}
        name={@name}
        class={[
          input_border(@errors),
          "mt-2 block min-h-[6rem] w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:border-zinc-400 focus:outline-none focus:ring-4 focus:ring-zinc-800/5 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
        ]}
        {@rest}
      >
    <%= @value %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={[
          input_border(@errors),
          "mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  defp input_border([] = _errors),
    do: "border-zinc-300 focus:border-zinc-400 focus:ring-zinc-800/5"

  defp input_border([_ | _] = _errors),
    do: "border-rose-400 focus:border-rose-400 focus:ring-rose-400/10"

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="phx-no-feedback:hidden mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <Lucideicons.slash class="mt-0.5 h-5 w-5 flex-none fill-rose-500" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :row_click, :any, default: nil
  attr :rows, :list, required: true

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    ~H"""
    <div id={@id} class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="mt-11 w-[40rem] sm:w-full">
        <thead class="text-left text-[0.8125rem] leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal"><%= col[:label] %></th>
            <th class="relative p-0 pb-4"><span class="sr-only">"Actions"</span></th>
          </tr>
        </thead>
        <tbody class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700">
          <tr
            :for={row <- @rows}
            id={"#{@id}-#{Phoenix.Param.to_param(row)}"}
            class="relative group hover:bg-zinc-50"
          >
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div :if={i == 0}>
                <span class="absolute h-full w-4 top-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class="absolute h-full w-4 top-0 -right-4 group-hover:bg-zinc-50 sm:rounded-r-xl" />
              </div>
              <div class="block py-4 pr-6">
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, row) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="p-0 w-14">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, row) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500"><%= item.title %></dt>
          <dd class="text-sm leading-6 text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <Lucideicons.arrow_left class="w-3 h-3 stroke-current" />
        <%= render_slot(@inner_block) %>
      </.link>
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

  defp input_equals?(val1, val2) do
    Phoenix.HTML.html_escape(val1) == Phoenix.HTML.html_escape(val2)
  end
end
