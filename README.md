# GrpcServer
Simple utility class for using gRPC server.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grpc_server'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install grpc_server

## Usage
By using `GrpcServer` class, you can run a gRPC server in the specified configuration.

```ruby
require "grpc_server"

server = GrpcServer.new(
  port:         3000,      # Listen port
  threads:      30,        # The size of the thread pool
  interceptors: [...],     # An array of GRPC::ServerInterceptor objects
  signals:      ["TERM"],  # Signals for graceful shutdown
)
server.set_handler(XXX)  # Set handler here
server.run  # Start to run
```

## Example
By using [examples/server.rb](https://github.com/south37/grpc_server/blob/master/examples/server.rb), gRPC server start to listen on `0.0.0.0:50051`.

```console
$ bundle exec ruby examples/server.rb
I, [2020-08-20T20:31:16.470412 #26572]  INFO -- : gRPC server starting...
I, [2020-08-20T20:31:16.470594 #26572]  INFO -- : * Max threads: 30
I, [2020-08-20T20:31:16.470632 #26572]  INFO -- : * Environment: unknown
I, [2020-08-20T20:31:16.470646 #26572]  INFO -- : * Listening on tcp://0.0.0.0:50051
I, [2020-08-20T20:31:16.470654 #26572]  INFO -- : Use Ctrl-C to stop
```

The server supports [GRPC Health Checking Protocol](https://github.com/grpc/grpc/blob/master/doc/health-checking.md), we can check it by using [grpc-health-probe](https://github.com/grpc-ecosystem/grpc-health-probe).

```console
$ grpc-health-probe -addr=:50051
status: SERVING
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/south37/grpc_server. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/south37/grpc_server/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GrpcServer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/south37/grpc_server/blob/master/CODE_OF_CONDUCT.md).
