defmodule MitTest do
  use ExUnit.Case
  doctest Mit

  test "greets the world" do
    assert Mit.hello() == :world
  end
end
