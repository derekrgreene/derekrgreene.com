defmodule DerekrgreeneWeb.Router do
  use DerekrgreeneWeb, :router

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
    plug Plug.BasicAuth,
      username: Application.get_env(:derekrgreene, :admin_username),
      password: Application.get_env(:derekrgreene, :admin_password)
  end

  scope "/", DerekrgreeneWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # LiveDashboard in development (no auth needed)
  if Application.compile_env(:derekrgreene, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DerekrgreeneWeb.Telemetry
    end
  end

  # LiveDashboard in production (admin auth required)
  scope "/admin" do
    pipe_through :admin
    import Phoenix.LiveDashboard.Router

    live_dashboard "/dashboard", metrics: DerekrgreeneWeb.Telemetry
  end
end
