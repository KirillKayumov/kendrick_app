defmodule KendrickWeb.Router do
  use KendrickWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    plug(
      Guardian.Plug.Pipeline,
      module: Kendrick.Guardian,
      error_handler: Kendrick.Auth.ErrorHandler
    )

    plug(Guardian.Plug.VerifySession)
    plug(Guardian.Plug.LoadResource, allow_blank: true)
    plug(KendrickWeb.Plugs.SetCurrentUser)
    plug(KendrickWeb.Plugs.SetCurrentWorkspace)
  end

  pipeline :slack do
    plug(:accepts, ["json"])
    plug(KendrickWeb.Plugs.Slack.DecodePayload)
    plug(KendrickWeb.Plugs.Slack.VerifyVerificationToken)
    plug(KendrickWeb.Plugs.Slack.SslCheck)
    plug(KendrickWeb.Plugs.Slack.Challenge)
  end

  scope "/", KendrickWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    scope "/users" do
      get("/", UserController, :index)

      post("/:slack_id/add_to_app", UserController, :add_to_app)
    end

    scope "/slack_users" do
      get("/", SlackUserController, :index)

      post("/:slack_id/add_to_app", SlackUserController, :add_to_app)
    end

    resources("/projects", ProjectController) do
      resources("/teams", TeamController)
    end

    resources("/rewards", RewardsController, singleton: true)
  end

  scope "/auth", KendrickWeb do
    get("/:provider", AuthController, :request)
    get("/slack/callback", AuthController, :slack_callback)
    delete("/sign_out", AuthController, :sign_out)
  end

  scope "/slack", KendrickWeb.Slack do
    pipe_through(:slack)

    post("/action", ActionController, :index)
    post("/command", CommandController, :index)
    post("/event", EventController, :index)
  end

  scope "/health_check", KendrickWeb do
    get("/", HealthCheckController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", KendrickWeb do
  #   pipe_through :api
  # end
end
