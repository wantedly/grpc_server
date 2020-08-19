require "grpc"
require "grpc/health/checker"
require "logger"

class GrpcServer
  class Engine
    DEFAULT_HOST                      = "0.0.0.0"
    DEFAULT_PORT                      = 50051
    DEFAULT_THREADS                   = 30
    DEFAULT_ENV                       = "unknown"
    DEFAULT_GRACEFUL_SHUTDOWN_SIGNALS = [
      "TERM",
      "INT",
    ].freeze

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
    def initialize(host:         DEFAULT_HOST,
                   port:         DEFAULT_PORT,
                   threads:      DEFAULT_THREADS,
                   env:          DEFAULT_ENV,
                   interceptors: [],
                   signals:      DEFAULT_GRACEFUL_SHUTDOWN_SIGNALS,
                   logger:       nil)
      @host    = host
      @port    = port
      @threads = threads
      @env     = env
      @logger  = logger || Logger.new($stdout)
      @signals = signals

      @server = GRPC::RpcServer.new(
        pool_size:    @threads,
        interceptors: interceptors,
      )
      @server.add_http2_port("#{@host}:#{@port}", :this_port_is_insecure)

      # Setup Health Cheker.
      # cf. https://github.com/grpc/grpc/blob/master/doc/health-checking.md
      @server.handle(health_checker)
      register_service_to_health_checker!(service: "")
    end

    # @param [GRPC::GenericService] service
    def set_handler(service)
      @server.handle(service)
      register_service_to_health_checker!(service: service.service_name)
    end

    def run
      @logger.info("gRPC server starting...")
      @logger.info("* Max threads: #{@threads}")
      @logger.info("* Environment: #{@env}")
      @logger.info("* Listening on tcp://#{@host}:#{@port}")
      @logger.info("Use Ctrl-C to stop")
      @server.run_till_terminated_or_interrupted(@signals)
      @logger.info("Exiting")
    end

    def stop
      @server.stop
    end

  private

    # @param [String] service
    def register_service_to_health_checker!(service:)
      health_checker.add_status(
        service,
        Grpc::Health::V1::HealthCheckResponse::ServingStatus::SERVING,
      )
    end

    # @return [Grpc::Health::Checker]
    def health_checker
      @health_checker ||= Grpc::Health::Checker.new
    end
  end
end
