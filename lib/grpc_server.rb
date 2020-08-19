require "grpc_server/engine"
require "grpc_server/version"

class GrpcServer
  # @param [String] host
  # @param [Integer] port
  # @param [Integer] threads the size of the thread pool the server uses to
  #     run its threads. No more concurrent requests can be made than the
  #     size of the thread pool
  # @param [String] env
  # @param [Array<GRPC::ServerInterceptor>] interceptors An array of
  #     GRPC::ServerInterceptor objects that will be used for intercepting
  #     server handlers to provide extra functionality.
  # @param [Array<String>] signals List of String representing signals that
  #     the user would like to send to the server for graceful shutdown
  # @param [Logger] logger
  def initialize(**kwargs)
    @engine = Engine.new(**kwargs)
  end

  extend Forwardable

  def_delegators :@engine, :set_handler, :run, :stop
end
