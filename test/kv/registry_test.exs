defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  alias KV.Registry

  setup do
    start_supervised!({Registry, []})
    :ok
  end

  test "starts without buckets" do
    assert Registry.lookup() == []
  end

  test "spawns buckets" do
    assert {"foo", foo} = Registry.create("foo")
    assert Registry.lookup("foo") == {:ok, foo}
    Agent.stop(foo)
  end

  test "removes bucket on exit" do
    assert {"bar", bar} = Registry.create("bar")

    Agent.stop(bar)

    assert Registry.lookup("bar") == :error
  end

  test "removes bucket on crash" do
    assert {"baz", baz} = Registry.create("baz")

    Agent.stop(baz, :shutdown)

    assert Registry.lookup("baz") == :error
  end
end
