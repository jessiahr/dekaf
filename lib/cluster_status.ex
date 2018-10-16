defmodule Dekaf.ClusterStatus do
  use GenServer
  require Logger
  alias Dekaf.StatusFormatter
  @table_name :dekaf_cluster_status
  def start_link(_) do
    Logger.info("Starting ClusterStatus")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get_client_status(client_id) do
    try do
      resp =
        :ets.lookup(@table_name, client_id)
        |> List.last()
        |> elem(1)

      {:ok, resp}
    rescue
      e in ArgumentError -> {:error, e}
    end
  end

  def get_offsets_for_topic(client_id, topic) do
    case get_client_status(client_id) do
      {:ok, %{"topics" => topics}} ->
        topics

      # |> Enum.into(%{})
      other ->
        other
    end
  end

  def update_status(client_id, status) do
    GenServer.cast(__MODULE__, {:update_status, client_id, StatusFormatter.format(status)})
  end

  def init(_) do
    :ets.new(@table_name, [:named_table, read_concurrency: true])
    {:ok, nil}
  end

  def handle_cast({:update_status, client_id, status}, cache) do
    :ets.insert(@table_name, {client_id, status})
    {:noreply, cache}
  end
end
