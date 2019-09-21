defmodule Martins.Test.NoLoggerView do
  @moduledoc false

  @behaviour Martins.Views

  def present(:resource, resource) do
    %{
      id: resource.id,
      name: resource.name
    }
  end

  def present(_template, _data), do: {:error, :bad_request}
end
