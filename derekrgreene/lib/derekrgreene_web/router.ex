defmodule DerekrgreeneWeb.Router do
  use DerekrgreeneWeb, :router
  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth

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
    plug :basic_auth, username: @admin_username, password: @admin_password
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
end
