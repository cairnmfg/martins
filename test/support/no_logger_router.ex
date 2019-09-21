defmodule Martins.Test.NoLoggerRouter do
  @moduledoc false

  use Martins.Routers,
    error_view: Martins.Test.ErrorView,
    logger_disabled: true,
    views_namespace: Martins.Test

  get("/", do: respond(conn, present(:resource, %{id: 42, name: "Cairn"})))
  match(_, do: respond(conn, :not_found))
end
