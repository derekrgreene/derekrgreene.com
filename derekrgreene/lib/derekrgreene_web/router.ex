defmodule DerekrgreeneWeb.Router do
  use DerekrgreeneWeb, :router
  import Phoenix.LiveDashboard.Router

  # Admin credentials - read at compile time
  @admin_username Application.compile_env(:derekrgreene, :admin_username)
  @admin_password Application.compile_env(:derekrgreene, :admin_password)

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DerekrgreeneWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DerekrgreeneWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :admin_auth
  end

  scope "/", DerekrgreeneWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # LiveDashboard
  if Application.compile_env(:derekrgreene, :dev_routes) do
    # Development: no auth needed
    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DerekrgreeneWeb.Telemetry
    end
  else
    # Production: admin auth required
    scope "/admin" do
      pipe_through :admin

      live_dashboard "/dashboard", metrics: DerekrgreeneWeb.Telemetry
    end
  end

  # Admin authentication plug
  defp admin_auth(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> auth] ->
        case Base.decode64(auth) do
          {:ok, auth_string} ->
            expected = "#{@admin_username}:#{@admin_password}"
            if auth_string == expected do
              conn
            else
              conn |> put_status(401) |> put_resp_header("www-authenticate", "Basic realm=\"Admin\"") |> halt()
            end
          _ ->
            conn |> put_status(401) |> put_resp_header("www-authenticate", "Basic realm=\"Admin\"") |> halt()
        end
      _ ->
        conn |> put_status(401) |> put_resp_header("www-authenticate", "Basic realm=\"Admin\"") |> halt()
    end
  end
end
