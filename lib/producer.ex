defmodule Dekaf.Producer do
  defmacro __using__(opts) do
    quote do
      import :erlkaf
      import Logger
      use GenServer
      @behaviour :erlkaf_producer_callbacks

      def init(opts = %{producer_id: producer_id, topic: topic, config: config}) do
        :erlkaf.start()
        :ok = :erlkaf.create_producer(producer_id, config)
        Logger.info("#{producer_id}: Starting producer")
        {:ok, opts}
      end

      def produce(pid, message={k, v}) when is_binary(k) and is_binary(v) do
        GenServer.call(pid, {:produce, message})
      end

      def handle_call(
            {:produce, {k, v}},
            _from,
            state = %{producer_id: producer_id, topic: topic}
          ) do
        status = :erlkaf.produce(producer_id, topic, k, v)
        {:reply, status, state}
      end

      def delivery_report(status, message) do
        case {status, Application.get_env(:dekaf, :delivery_report)} do
          {:ok, nil} ->
              :ok
          {_, nil} ->
            Logger.warn("received delivery report: #{status} for message #{inspect(message)}")
          {_, {module, function_name}} ->
            apply(module, function_name, [{status, message}])
        end
      end

      def stats_callback(client_id, kafka_status_message) do
        Dekaf.ClusterStatus.update_status(client_id, kafka_status_message)
        :ok
      end
    end
  end

  def start_link(module, opts = %{producer_id: producer_id}) do
    GenServer.start_link(module, opts, name: producer_id)
  end
end
