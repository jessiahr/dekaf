defmodule Dekaf.Consumer do
  import Logger

  defmacro __using__(opts) do
    quote do
      import :erlkaf
      import Logger
      @behaviour :erlkaf_consumer_callbacks
      @behaviour GenServer
      @behaviour Dekaf.Consumer

      def init(
            state = %{
              topics: topics,
              client_id: client_id,
              consumer_group_id: consumer_group_id,
              client_config: client_config,
              topic_config: topic_config
            }
          ) do
        :ok =
          :erlkaf.create_consumer_group(
            client_id,
            consumer_group_id,
            topics,
            client_config,
            topic_config,
            __MODULE__,
            state
          )

        Logger.info("#{client_id}: Starting consumer group (waiting for partition assignment)")
        {:ok, state}
      end

      def init(topic, partition, offset, state = %{client_id: client_id}) do
        Logger.info(
          "#{client_id}: Starting consumer worker for (partition[#{partition}] offset[#{offset}])"
        )

        {:ok, state}
      end

      def stats_callback(client_id, kafka_status_message) do
        Dekaf.ClusterStatus.update_status(client_id, kafka_status_message)
        :ok
      end
    end
  end

  def start_link(module, opts = %{client_id: client_id}) do
    GenServer.start_link(module, opts, name: client_id)
  end
end
