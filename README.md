# Omnom

Omnom is a gem for concurrent data ingestion from different sources (like Google PubSub, RabbitMQ, and others).
Currently it ships with an adapter for Google Cloud PubSub, but new adapters are [very easy to implement](#adapter).

It is named after the sound produced by the [Cookie Monster](https://en.wikipedia.org/wiki/Cookie_Monster) while ingesting cookies: "Om nom nom nom".

## Built-in features

  * Concurrent data ingestion.
  * Back-pressure: It only gets the amount of messages needed to keep all consumers busy, never flooding the service.
  * Automatic message acknowledgements.
  * Graceful shutdown: All fetched messages are consumed before stopping.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omnom', git: "https://github.com/jcabotc/omnom"
```

And then execute:

    $ bundle install

## Hello world

```ruby
# We will consume messages from Google Cloud PubSub
adapter = Omnom::Adapter::GooglePubsub.new(
  project_id: "my_project_id",
  subscription: "my_subscription",
  token: "my_google_pubsub_auth_token_asfia093worejaw"
)

# We will print the contents of the message
class Handler
  def self.handle(message)
    puts message
    true # It must return a truthy value for the message to be acknowledged
  end
end

config = Omnom::Config.new(adapter: adapter, handler: Handler)
consumer = Omnom.new(config)

sleep(1) # messages are being consumed...
consumer.stop
```

## Config

Example with all configuration options:
```ruby
config = Omnom::Config.new(
  adapter: adapter,
  handler: handler,
  buffer_size: 100,
  poll_interval_ms: 250,
  concurrency: 20
)
```

  - `adapter`: [Required] An object that responds to `fetch(amount)`. [More details below](#adapter).
  - `handler`: [Required] An object that responds to `handle(message)`. [More details below](#handler).
  - `buffer_size`: [Optional, defaults to `100`] The amount of messages that will be kept in memory ready to be consumed.
  - `poll_interval_ms`: [Optional, defaults to `250`] The execution interval of a recurrent task that refills consumed messages in the buffer.
  - `concurrency`: [Optional, defaults to `20`] Amount of consumers that will process messages concurrently.

## Adapter

An adapter is an object that responds to `adapter.fetch(number_of_messages)` and returns at most `number_of_messages` objects called receiveds.

Each received must responds to:
  - `message`: Returns the message itself
  - `ack`: Acknowledges the message
  - `no_ack`: Marks the message as not acknowledged

### Google Cloud PubSub adapter

Currently Omnom ships with a Google Cloud Pubsub adapter (`Omnom::Adapter::GooglePubsub`), which receives the following configuration options:
  - `host`: [Optional, defaults to `"https://pubsub.googleapis.com"`] Google PubSub server host.
  - `port`: [Optional, defaults to `80`] Google PubSub server port.
  - `project_id`: [Required] The project id of the subscription.
  - `subscription`: [Required] The subscription to consume data from.
  - `token`: [Required] A valid oauth2 token.

You can test your service locally by using the [Google Pubsub emulator provided by google](https://cloud.google.com/pubsub/docs/emulator) by setting the host to `localhost` and the port to `8085`.

## Handler

A handler is an object that responds to `handler.handle(message)`.

If the `handle` method returns a truthy value the message will be acknowledged. If it returns a falsey value or raises an expection the message will be marked as not acknowledged.

## Next steps

### Observability

Before using this library in production it should implement some observability mechanism, so that the user can have metrics about:

  - Adapter `fetch`, `ack`, and `no_ack` response times.
  - Adapter errors.
  - Handler `handle` processing times.
  - Handler errors.
  - Consumption rate.
  - Message `ack` rate.
  - Message `no_ack` rate.

### Batching

After a message is handled, it is automatically acked. This approach is the one that has the higher probability of successful acknowledge per message, but it is also wastes a lot of resources by performing a HTTP request per message.

It would be great to optionally support batching, not only for acks, but also for message handling.

### Refilling the buffer

While the current refilling strategy of polling for missing messages every `poll_interval_ms` milliseconds works fine for many use cases, it is highly dependent on the correct configuration for every use case.

For example, if occasionally many messages in a row take a very short time to be processed the buffer may be empty for a while, wasting time and resources.

This can be improved by implementing a strategy that accepts a `min_buffer_size` and a `max_buffer_size`. Once the buffer size is `min_buffer_size` it would be refilled to `max_buffer_size`. This strategy doesn't depend on a poll interval estimated by a human, but on the actual consumption rate of messages in the queue.

### Thread supervision

Omnom starts one producer thread to pull messages and keep the buffer filled, and as many consumer threads as specified in the `concurrency` configuration option to consume those messages.

These threads rescue any exception raised from the adapter and the handler to make sure those threads are alive.

While this should work fine, for highly available environments it may not be a strong enough guarantee. A unspotted bug, or a bug introduced when updating the library may crash some threads on some specific circumstances.

To make this library truly resilient there should be some thread supervision logic in place to make sure any thread crash is detected and the thread is properly restarted.
