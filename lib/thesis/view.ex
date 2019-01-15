defmodule Thesis.View do
  @moduledoc """
  Provides several view helper functions, including the primary `content/4`
  function. Look at individual function documentation to learn more about them.

  Typically, you'll add this to your `web/web.ex` file, under the `view`
  function:

      def view do
        quote do
          use Thesis.View
          # ...
        end
      end

  If you'd prefer, you can remove it from `web/web.ex` and add it to your views
  yourself:

      defmodule MyApp.MyView do
        use Thesis.View
        # ...
  """

  import Phoenix.HTML, only: [raw: 1, safe_to_string: 1]
  import Phoenix.HTML.Tag
  import Thesis.Config
  alias Thesis.{Page, PageContent, Render, Notifications}

  # @styles File.read!(Path.join(__DIR__, "../../priv/static/thesis.css"))
  # @external_resource Path.join(__DIR__, "../../priv/static/thesis.css")

  @doc """
  Creates an editable content area in an eex template. Returns HTML-safe
  string if type is `:html` or just a string if `:text`.

  ## Examples

      <%= content(@conn, "Title", :text, do: "Default Title") %>
      <%= content(@conn, "Description", :html) do %>
        <p>Default description</p>
        <p>Another paragraph</p>
      <% end %>
      <%= content(@conn, "Description", :html, classes: "more classes") do %>
        <p>Default description</p>
      <% end %>
  """
  @spec content(Plug.Conn.t, String.t, String.t, list) :: String.t | {:safe, String.t}
  def content(conn, name, type, opts \\ [do: ""]) do
    page = current_page(conn)
    render_content(conn, page.id, name, type, opts)
  end

  @spec content(Plug.Conn.t, String.t, String.t, list, list) :: String.t | {:safe, String.t}
  def content(conn, name, type, opts, [do: block]) do
    page = current_page(conn)
    render_content(conn, page.id, name, type, Keyword.put(opts, :do, block))
  end

  @doc """
  Creates a globally editable content area in an eex template. Returns HTML-safe
  string if type is `:html` or just a string if `:text`.

  ## Examples

      <%= global_content(@conn, "Title", :text, do: "Default Title") %>
      <%= global_content(@conn, "Description", :html) do %>
        <p>Default description</p>
        <p>Another paragraph</p>
      <% end %>
      <%= global_content(@conn, "Description", :html, classes: "more classes") do %>
        <p>Default description</p>
      <% end %>
  """
  @spec global_content(Plug.Conn.t, String.t, String.t, list) :: String.t | {:safe, String.t}
  def global_content(conn, name, type, opts \\ [do: ""]) do
    opts = Keyword.put(opts, :global, true)
    render_content(conn, nil, name, type, opts)
  end

  @spec global_content(Plug.Conn.t, String.t, String.t, list, list) :: String.t | {:safe, String.t}
  def global_content(conn, name, type, opts, [do: block]) do
    opts = Keyword.put(opts, :global, true)
    render_content(conn, nil, name, type, Keyword.put(opts, :do, block))
  end

  defp render_content(conn, page_id, name, type, opts) do
    all_content = conn.assigns[:thesis_content]
    if all_content do
      content = PageContent.find(all_content, page_id, name) ||
        make_content(page_id, name, type, stringify(opts[:do]), Keyword.delete(opts, :do))
      Render.render_editable(content, opts)
    else
      raise controller_missing_text()
    end
  end

  @doc """
  Returns the current page as a Thesis.Page{} struct.

      iex> Thesis.View.current_page(%Plug.Conn{request_path: "/test"})
      %Thesis.Page{slug: "/test"}
  """
  @spec current_page(Plug.Conn.t) :: Thesis.Page.t
  def current_page(conn) do
    conn.assigns[:thesis_page] || make_page(conn.request_path)
  end

  @doc """
  Checks with the host app to see if the current page is editable by the
  current user, and then renders the editor, style tag, and bootstrap js.

  If not editable, simply returns an empty string.

  Doctests:

      iex> {:safe, editor} = Thesis.View.thesis_editor(%Plug.Conn{assigns: %{thesis_editable: true}})
      iex> String.contains?(editor, "/thesis/thesis.css")
      true
      iex> String.contains?(editor, "thesis-container")
      true
      iex> String.contains?(editor, "<script>")
      true

      iex> Thesis.View.thesis_editor(%Plug.Conn{assigns: %{thesis_editable: false}})
      {:safe, ""}
  """
  @spec thesis_editor(Plug.Conn.t) :: {:safe, String.t}
  def thesis_editor(conn) do
    if editable?(conn) do
      page = conn.assigns[:thesis_page]
      redirect_url = page && page.redirect_url
      template = page && page.template
      templates = Enum.join(dynamic_templates(), ",")
      notifications = conn |> Notifications.all() |> Poison.encode!
      editor = content_tag(:div, "", id: "thesis-container",
        data_html_editor: html_editor(),
        data_ospry_public_key: ospry_public_key(),
        data_file_uploader: uploader(),
        data_redirect_url: redirect_url,
        data_template: template,
        data_templates: templates,
        data_notifications: notifications,
        data_dynamic_page: conn.assigns[:thesis_dynamic_page])
      safe_concat([thesis_style(), editor, thesis_js()])
    else
      raw ""
    end
  end

  @doc """
  Outputs the page title or a provided default.

  Doctests:

      iex> page = %Thesis.Page{title: "Test Title"}
      iex> conn = %Plug.Conn{assigns: %{thesis_page: page}}
      iex> Thesis.View.page_title(conn, "Default Title")
      "Test Title"
      iex> page = %Thesis.Page{}
      iex> conn = %Plug.Conn{assigns: %{thesis_page: page}}
      iex> Thesis.View.page_title(conn, "Default Title")
      "Default Title"
  """
  def page_title(conn, default) do
    current_page(conn).title || default
  end

  @doc """
  Outputs the page title or a provided default.

  Doctests:

      iex> page = %Thesis.Page{description: "Test Description"}
      iex> conn = %Plug.Conn{assigns: %{thesis_page: page}}
      iex> Thesis.View.page_description(conn, "Default Description")
      "Test Description"
      iex> page = %Thesis.Page{}
      iex> conn = %Plug.Conn{assigns: %{thesis_page: page}}
      iex> Thesis.View.page_description(conn, "Default Description")
      "Default Description"
  """
  def page_description(conn, default) do
    current_page(conn).description || default
  end

  defp make_page(request_path) do
    %Page{slug: request_path}
  end

  defp make_content(:global, name, type, content, meta) do
    make_content(nil, name, type, content, meta)
  end

  defp make_content(%Page{id: page_id}, name, type, content, meta) do
    make_content(page_id, name, type, content, meta)
  end

  defp make_content(page_id, name, type, content, meta) do
    %PageContent{
      page_id: page_id,
      name: name,
      content_type: Atom.to_string(type),
      content: content,
      meta: PageContent.meta_serialize(meta)
    }
  end

  defp thesis_style do
    raw """
    <link href='/thesis/thesis.css' rel='stylesheet' />
    """
  end

  defp thesis_js do
    raw """
    <script>
      ;(function () {
        var loadThesis = function (callback) {
          var script = document.createElement('script')
          script.src = '/thesis/thesis.js'
          script.onload = callback

          document.head.appendChild(script)
        }

        document.addEventListener('DOMContentLoaded', function (event) {
          var container = document.querySelector('#thesis-container')
          if (container) {
            loadThesis(function () {
              // Init Thesis
              console.log(window.thesis(container))
            })
          }
        })
      })()
    </script>
    """
  end

  defp editable?(conn) do
    !!conn.assigns[:thesis_editable]
  end

  defp safe_concat(list) do
    list
    |> Enum.map(&stringify/1)
    |> Enum.join
    |> raw
  end

  defp stringify(str) when is_binary(str), do: str
  defp stringify(str), do: safe_to_string(str)

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end
end
