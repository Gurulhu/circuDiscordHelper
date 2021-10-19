defmodule LobotomistTest do
  use ExUnit.Case
  doctest Lobotomist

  test "greets the world" do
    assert Lobotomist.hello() == :world
  end
end
