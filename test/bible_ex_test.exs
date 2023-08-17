defmodule BibleExTest do
  use ExUnit.Case
  doctest BibleEx

  test "greets the world" do
    assert BibleEx.hello() == :world
  end
end
