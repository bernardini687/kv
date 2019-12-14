defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  alias KV.Bucket

  describe "with filled bucket" do
    setup :filled_bucket

    test "reads values by key", %{filled: pid} do
      assert Bucket.get(pid, :milk) == 3
    end

    test "stores new values by key", %{filled: pid} do
      assert Bucket.put(pid, :mango, 1) == :ok
      assert Bucket.get(pid, :mango) == 1
    end

    test "deletes values by key", %{filled: pid} do
      assert Bucket.delete(pid, :milk) == 3
      assert Bucket.get(pid, :milk) == nil
    end
  end

  describe "with empty bucket" do
    setup :empty_bucket

    test "returns nothing", %{empty: pid} do
      assert Bucket.delete(pid, :milk) == -1
    end
  end

  # # # #
  # SETUPS

  defp filled_bucket(_ctxt) do
    {:ok, pid} = KV.Bucket.start_link([])
    Bucket.put(pid, :milk, 3)

    %{filled: pid}
  end

  defp empty_bucket(_ctxt) do
    {:ok, pid} = KV.Bucket.start_link([])

    %{empty: pid}
  end
end
