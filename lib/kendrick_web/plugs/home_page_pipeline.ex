defmodule KendrickWeb.Plugs.HomePagePipeline do
  use Guardian.Plug.Pipeline, otp_app: :kendrick

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
