defmodule Absinthe.ConnTest.Test.Endpoint do
  use Phoenix.Endpoint, otp_app: :absinthe_conn_test

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(Absinthe.Plug, schema: Absinthe.ConnTest.Test.Schema)

  def init(_, config) do
    {:ok, Keyword.put(config, :secret_key_base, "blah blah blah blah blah")}
  end
end
