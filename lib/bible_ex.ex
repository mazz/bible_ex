defmodule BibleEx do
  @moduledoc """
  Documentation for `BibleEx`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> BibleEx.hello()
      :world

  """
  def hello do
    :world
  end

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
