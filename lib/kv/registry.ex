defmodule KV.Registry do
  use GenServer

  # # # #
  # CLIENT

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Search the bucket pid for `name` stored in `registry`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(registry, name) do
    GenServer.call(registry, {:lookup, name})
  end

  @doc """
  Creates a bucket associated with the given `name` in `registry`.
  """
  def create(registry, name) do
    GenServer.call(registry, {:create, name})
  end

  # # # #
  # SERVER

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  def handle_call({:create, name}, _from, names) do
    if Map.has_key?(names, name) do
      {:reply, {name, Map.get(names, name)}, names}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      {:reply, {name, bucket}, Map.put(names, name, bucket)}
    end
  end
end
