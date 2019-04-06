defmodule Martins.Test.ErrorView do
  @moduledoc false

  @behaviour Martins.Views

  def present(:bad_request, _assigns),
    do: %{errors: %{detail: "Bad Request"}}

  def present(:conflict, _assigns),
    do: %{errors: %{detail: "Conflict"}}

  def present(:forbidden, _assigns),
    do: %{errors: %{detail: "Forbidden"}}

  def present(:internal_server_error, _assigns),
    do: %{errors: %{detail: "Internal Server Error"}}

  def present(:not_found, _assigns),
    do: %{errors: %{detail: "Not Found"}}

  def present(:unauthorized, _assigns),
    do: %{errors: %{detail: "Unauthorized"}}

  def present(_template, assigns),
    do: present(:internal_server_error, assigns)
end
