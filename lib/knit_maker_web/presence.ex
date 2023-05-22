defmodule KnitMakerWeb.Presence do
  use Phoenix.Presence,
    otp_app: :knit_maker,
    pubsub_server: KnitMaker.PubSub
end
