defmodule Martins.Test.ProductRouter do
  @moduledoc false

  use Martins.Routers, error_view: Martins.Test.ErrorView, views_namespace: Martins.Test

  get("/", do: respond(conn, present(:resource, %{id: 42, name: "Cairn"})))
  get("/bad_request", do: respond(conn, :bad_request))
  get("/conflict", do: respond(conn, :conflict))
  get("/forbidden", do: respond(conn, :forbidden))
  get("/boom", do: respond(conn, :boom))
  get("/unauthorized", do: respond(conn, :unauthorized))
  match(_, do: respond(conn, :not_found))
end
