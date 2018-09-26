defmodule Martins.Views do
  @callback present(atom(), map() | list()) :: map()
end
