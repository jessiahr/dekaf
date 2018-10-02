defmodule DekafTest do
  use ExUnit.Case
  doctest Dekaf

  test "greets the world" do
    assert Dekaf.hello() == :world
  end
end
