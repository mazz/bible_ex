defmodule BibleEx do
  @moduledoc """
  An Elixir package that parses strings for Bible references. Parse single references or multiple references from a string into a variety of data structures.
  """

  @doc """
  Used internally by BibleEx.
  """

  def typeof(a) do
    cond do
      is_float(a) -> "float"
      is_number(a) -> "number"
      is_atom(a) -> "atom"
      is_boolean(a) -> "boolean"
      is_binary(a) -> "binary"
      is_function(a) -> "function"
      is_list(a) -> "list"
      is_tuple(a) -> "tuple"
      is_nil(a) -> "nil"
      true -> "nil"
    end
  end
end
