defmodule KV.Registry do
  use GenServer

  @me __MODULE__

  # # # #
  # CLIENT

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(@me, :ok, opts)
  end

  @doc """
  Search the bucket pid for `name` stored in `registry`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(name) do
    GenServer.call(@me, {:lookup, name})
  end

  def lookup do
    GenServer.call(@me, {:lookup, :all})
  end

  @doc """
  Creates a bucket associated with the given `name` in `registry`.
  """
  def create(name) do
    GenServer.call(@me, {:create, name})
  end

  # # # #
  # SERVER

  @impl true
  def init(:ok) do
    names = refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, :all}, _from, {names, _} = state) do
    {:reply, Map.to_list(names), state}
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
      {:ok, bucket_pid} = KV.Bucket.start_link([])
      ref = Process.monitor(bucket_pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket_pid)

      {:reply, {name, bucket_pid}, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _, _}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)

    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
