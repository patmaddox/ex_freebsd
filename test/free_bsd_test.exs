defmodule FreeBSDTest do
  use ExUnit.Case
  doctest FreeBSD

  test "greets the world" do
    assert FreeBSD.hello() == :world
  end
end
