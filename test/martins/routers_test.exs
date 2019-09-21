defmodule Martins.RoutersTest do
  alias Martins.Routers
  alias Martins.Test.{NoLoggerRouter, ProductRouter}

  import ExUnit.CaptureLog

  use Martins.Test.DataCase

  @opts ProductRouter.init([])

  describe "present/4" do
    test "calls the associated view's present/2 function" do
      data = %{id: 42, name: "Cairn", something: "else"}
      presented = Routers.present(:resource, data, ProductRouter, Martins.Test)
      assert presented == %{id: 42, name: "Cairn"}
    end
  end

  describe "respond/2" do
    test "renders template from associated view" do
      conn =
        :get
        |> conn("/", "")
        |> call_router()

      assert json_response(conn, 200)["name"] == "Cairn"
    end

    test "renders bad request error from error view" do
      conn =
        :get
        |> conn("/bad_request", "")
        |> call_router()

      assert json_response(conn, 400)["errors"]["detail"] == "Bad Request"
    end

    test "renders conflict error from error view" do
      conn =
        :get
        |> conn("/conflict", "")
        |> call_router()

      assert json_response(conn, 409)["errors"]["detail"] == "Conflict"
    end

    test "renders forbidden error from error view" do
      conn =
        :get
        |> conn("/forbidden", "")
        |> call_router()

      assert json_response(conn, 403)["errors"]["detail"] == "Forbidden"
    end

    test "renders internal server error for unmatched template" do
      conn =
        :get
        |> conn("/boom", "")
        |> call_router()

      assert json_response(conn, 500)["errors"]["detail"] == "Internal Server Error"
    end

    test "renders unauthorized error from error view" do
      conn =
        :get
        |> conn("/unauthorized", "")
        |> call_router()

      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    test "renders not found error from error view" do
      conn =
        :get
        |> conn("/bogus", "")
        |> call_router()

      assert json_response(conn, 404)["errors"]["detail"] == "Not Found"
    end

    test "permits logger to be disabled for a router" do
      assert capture_log(fn ->
               :get
               |> conn("/", "")
               |> call_router(ProductRouter)
             end) =~ "[info]  GET"

      assert capture_log(fn ->
               :get
               |> conn("/", "")
               |> call_router(NoLoggerRouter)
             end) == ""
    end
  end

  defp call_router(conn, router \\ ProductRouter), do: router.call(conn, @opts)
end
