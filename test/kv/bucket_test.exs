defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  alias KV.Bucket

  describe "with filled bucket" do
    setup :filled_bucket

    test "reads values by key", %{filled: pid} do
      assert Bucket.get(pid, "foo") == 0
    end

    test "reads values by multiple keys", %{filled: pid} do
      assert Bucket.get(pid, ["foo", "bar"]) == [0, 1]
    end

    test "reads nothing by absent keys", %{filled: pid} do
      assert Bucket.get(pid, ["qux"]) == [nil]
    end

    test "reads what is present", %{filled: pid} do
      assert Bucket.get(pid, ["qux", "foo"]) == [nil, 0]
    end

    test "stores new values by key", %{filled: pid} do
      assert Bucket.put(pid, "baz", 2) == :ok
      assert Bucket.get(pid, "baz") == 2
    end

    test "deletes values by key", %{filled: pid} do
      assert Bucket.delete(pid, "foo") == 0
      assert Bucket.get(pid, "foo") == nil
    end
  end

  describe "with empty bucket" do
    setup :empty_bucket

    test "returns nothing", %{empty: pid} do
      assert Bucket.delete(pid, "foo") == nil
    end
  end

  # # # #
  # SETUPS

  defp filled_bucket(_ctxt) do
    pid = start_supervised!(Bucket)
    Bucket.put(pid, "foo", 0)
    Bucket.put(pid, "bar", 1)

    %{filled: pid}
  end

  defp empty_bucket(_ctxt) do
    pid = start_supervised!(Bucket)

    %{empty: pid}
  end
end
