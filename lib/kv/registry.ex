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
    names = refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_call({:create, name}, _from, {names, refs} = state) do
    if Map.has_key?(names, name) do
      {:reply, {name, Map.get(names, name)}, state}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)

      {:reply, {name, bucket}, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, _, bucket, _}, state) do
    IO.inspect(ref, label: "ref")
    IO.inspect(bucket, label: "bucket")
    IO.inspect(state, label: "state")
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
