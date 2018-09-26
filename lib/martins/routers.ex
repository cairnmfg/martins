defmodule Martins.Routers do
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      authenticated = Keyword.get(opts, :authenticated)
      auth_error_handler = Keyword.get(opts, :auth_error_handler)
      auth_provider = Keyword.get(opts, :auth_provider)
      error_view = Keyword.get(opts, :error_view)
      views_namespace = Keyword.get(opts, :views_namespace)

      use Plug.Router

      plug(:match)

      plug(
        Plug.Parsers,
        parsers: [:json],
        pass: ["text/*"],
        json_decoder: Jason
      )

      if authenticated do
        plug(
          Guardian.Plug.VerifyHeader,
          module: auth_provider,
          error_handler: auth_error_handler
        )

        plug(
          Guardian.Plug.EnsureAuthenticated,
          module: auth_provider,
          error_handler: auth_error_handler
        )
      end

      plug(Plug.Logger)

      plug(:dispatch)

      def present(template, data),
        do: Martins.Routers.present(template, data, __MODULE__, unquote(views_namespace))

      def respond(conn, result),
        do: Martins.Routers.respond(conn, error_view: unquote(error_view), result: result)

      def respond(conn, :unprocessable_entity, changeset),
        do:
          Martins.Routers.respond(conn,
            changeset: changeset,
            error_view: unquote(error_view),
            result: :unprocessable_entity
          )

      def respond(conn, code, body),
        do: Martins.Routers.respond(conn, body: body, code: code)

      def request(conn, func) do
        try do
          case func.(conn) do
            %Plug.Conn{} = conn ->
              conn

            {:error, :bad_request} ->
              respond(conn, :bad_request)

            {:error, %{__struct__: Ecto.Changeset} = changeset} ->
              respond(conn, :unprocessable_entity, changeset)

            {:error, :not_found} ->
              respond(conn, :not_found)

            {:error, :unauthorized} ->
              respond(conn, :forbidden)

            {:error, _} ->
              respond(conn, :forbidden)

            :error ->
              respond(conn, :forbidden)
          end
        rescue
          FunctionClauseError ->
            respond(conn, :bad_request)
        end
      end
    end
  end

  def present(template, data, router, namespace),
    do: apply(view(router, namespace), :present, [template, data])

  def respond(conn, error_view: error_view, result: :bad_request) do
    body = error_view.present(:bad_request, %{})

    conn
    |> respond(body: body, code: 400)
    |> Plug.Conn.halt()
  end

  def respond(conn, error_view: error_view, result: :forbidden) do
    body = error_view.present(:forbidden, %{})

    conn
    |> respond(body: body, code: 403)
    |> Plug.Conn.halt()
  end

  def respond(conn, changeset: changeset, error_view: error_view, result: _unprocessable_entity) do
    body =
      :unprocessable_entity
      |> error_view.present(changeset)
      |> Jason.encode!()

    conn
    |> respond(body: body, code: 422)
    |> Plug.Conn.halt()
  end

  def respond(conn, error_view: _error_view, result: :no_content) do
    respond(conn, body: "", code: 204)
  end

  def respond(conn, error_view: error_view, result: :not_found) do
    body = error_view.present(:not_found, %{})

    conn
    |> respond(body: body, code: 404)
    |> Plug.Conn.halt()
  end

  def respond(conn, error_view: error_view, result: :unauthorized) do
    body = error_view.present(:unauthorized, %{})

    conn
    |> respond(body: body, code: 401)
    |> Plug.Conn.halt()
  end

  def respond(conn, error_view: error_view, result: error_result) when is_atom(error_result) do
    body = error_view.present(:internal_server_error, %{})

    conn
    |> respond(body: body, code: 500)
    |> Plug.Conn.halt()
  end

  def respond(conn, error_view: _error_view, result: body)
      when is_map(body),
      do: respond(conn, body: body, code: :ok)

  def respond(conn, body: body, code: code)
      when is_map(body),
      do: respond(conn, body: Jason.encode!(body), code: code)

  def respond(conn, body: body, code: code) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.send_resp(code, body)
  end

  defp view(router, namespace) do
    router
    |> to_string()
    |> Module.split()
    |> List.last()
    |> unsuffix("Router")
    |> Kernel.<>("View")
    |> view_name(namespace)
    |> String.to_existing_atom()
  end

  defp unsuffix(string, suffix) do
    suffix_size = byte_size(suffix)
    prefix_size = byte_size(string) - suffix_size

    case string do
      <<prefix::binary-size(prefix_size), ^suffix::binary>> -> prefix
      _ -> string
    end
  end

  defp view_name(value, namespace), do: "#{namespace}.#{value}"
end
