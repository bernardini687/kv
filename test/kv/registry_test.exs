defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  alias KV.{Bucket, Registry}

  setup do
    pid = start_supervised!(Registry)
    %{registry: pid}
  end

  test "starts without buckets", %{registry: pid} do
    assert Registry.lookup(pid, "food") == :error
  end

  test "spawns buckets", %{registry: pid} do
    assert {"food", bucket} = Registry.create(pid, "food")
    assert Bucket.put(bucket, :milk, 3) == :ok
  end
end
