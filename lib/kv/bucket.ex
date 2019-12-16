defmodule KV.Bucket do
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets the value/s of the `key/s` from the `bucket`.
  """
  def get(bucket, keys) when is_list(keys) do
    keys_to_values = fn items ->
      Enum.map(keys, &Map.get(items, &1))
    end

    # Map.take(items, keys) |> Map.values()

    Agent.get(bucket, &keys_to_values.(&1))
  end

  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` of the `key` in the `bucket`.
  """
  # def put(bucket, key, value) when is_binary(bucket) do
  #   case KV.Registry.lookup(bucket) do
  #     {:ok, bucket_pid} ->
  #       put(bucket_pid, key, value)

  #     _ ->
  #       IO.puts(:bucket_not_found)
  #   end
  # end

  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes the `key` and returns its value from the `bucket`.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
