defmodule Thesis.Controller do
  @moduledoc """
  Provides a plug that preloads any Thesis content for a page.
  Typically, you'll add this to your `web/web.ex` file, under the `controller`
  function:

      def controller do
        quote do
          use Phoenix.Controller
          use Thesis.Controller
          # ...
        end
      end

  If you'd prefer to only use Thesis in certain controllers, remove it from
  `web/web.ex` and add it to the specific controllers by doing this:

      defmodule MyApp.MyController do
        use Thesis.Controller
        # ...
  """

  defmacro __using__(_) do
    quote do
      plug Thesis.Controller.Plug

      @doc """
      Renders a page that exists only in the database, as opposed to a page that
      is defined in the router.

      This function will also redirect to the page's `redirect_url` if it is set.
      However, if the user is in edit mode, we will render the default template and
      display an alert telling them about the redirect. This gives the user a chance
      to edit where this page redirects to.
      """
      def render_dynamic(conn, opts \\ []) do
        page = conn.assigns[:thesis_page]
        if page && page.id do
          conn
          |> assign(:thesis_dynamic_page, "true")
          |> do_render_dynamic(page, opts)
        else
          render_not_found(conn)
        end
      end

      defp do_render_dynamic(conn, page, opts) do
        if Thesis.Page.redirected?(page) && !conn.assigns[:thesis_editable] do
          conn
          |> put_status(301)
          |> redirect(external: page.redirect_url)
        else
          conn
          |> put_status(200)
          |> put_view(Thesis.Config.dynamic_view || conn.private.phoenix_view)
          |> render(page_template(page, opts), opts)
        end
      end

      defp page_template(page, opts) do
        if page.template in Thesis.Config.dynamic_templates do
          page.template
        else
          opts[:template] || Enum.at(Thesis.Config.dynamic_templates, 0)
        end
      end

      defp render_not_found(conn) do
        conn
        |> put_status(:not_found)
        |> put_view(Thesis.Config.dynamic_not_found_view)
        |> render(Thesis.Config.dynamic_not_found_template)
      end

    end
  end

end

defmodule Thesis.Controller.Plug do
  @moduledoc """
  Pre-populates the conn with a Thesis page (if it exists) and its contents.
  Also checks with the host app if the current page is editable.
  """

  import Plug.Conn, only: [assign: 3]
  import Thesis.Config

  def init(_) do
  end

  def call(conn, _opts) do
    path = Thesis.Utilities.normalize_path(conn.request_path)
    current_page = store().page(path)
    page_contents = store().page_contents(current_page)

    conn
    |> assign(:thesis_dynamic_page, false) # Overridden in render_dynamic/2
    |> assign(:thesis_page, current_page)
    |> assign(:thesis_content, page_contents)
    |> assign(:thesis_editable, auth().page_is_editable?(conn))
  end

end
