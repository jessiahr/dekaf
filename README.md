# Dekaf
A set of tools for working with Kafka in elixir. 

## Installation

```elixir
def deps do
  [
    {:dekaf, "~> 0.1.0"}
  ]
end
```

## Write a consumer
```elixir
defmodule ThingConsumer do
  use Dekaf.Consumer

  def start_link(opts=%{context: %{consumer_id: consumer_id}}) do
    config = %{
      topics: opts.source, 
      client_id: consumer_id, 
      consumer_group_id: opts.name, 
      client_config: [
        {:bootstrap_servers, Application.get_env(:your_app, :bootstrap_servers)},
        {:statistics_interval_ms, 1000}, 
        {:stats_callback, __MODULE__}
      ], 
      topic_config: [
        {:auto_offset_reset, :smallest}
      ]
    }
    Dekaf.Consumer.start_link(__MODULE__, config)
  end

  def handle_message({:erlkaf_msg, topic, partition, offset, id, msg}, state) do
    ...
  end
end

```

Note: `{:stats_callback, __MODULE__}` is optional but if it is set the cluster status will be polled and written to ETS. This will make it easy to know when a rebalance event happens or which broker is the leader for a given partition. 

### Write a producer

```elixir
defmodule Producer do
  use Dekaf.Producer

  def start_link(opts=%{context: %{producer_id: producer_id}}) do
    config = %{
      producer_id: producer_id, 
      topic: opts.mailbox,
      config: [
        {:bootstrap_servers, Application.get_env(:your_app, :bootstrap_servers)},
        {:statistics_interval_ms, 1000}, 
        {:stats_callback, __MODULE__}
      ],
    }
    Dekaf.Producer.start_link(__MODULE__, config)
  end
end

```

TODO:
- [ ] Move the nif from :erlkaf into this project as an elixir nif. 
- [ ] Add seek and other methods provided by the kafka lib
