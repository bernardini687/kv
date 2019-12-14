defmodule KV.Bucket do
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets the value of the `key` from the `bucket`.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` of the `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes the `key` and its value from the `bucket`.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key, -1))
  end
end
