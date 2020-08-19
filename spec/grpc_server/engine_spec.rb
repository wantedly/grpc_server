require "support/mocked_logger"
require "support/user_server"

RSpec.describe GrpcServer::Engine do
  describe "#run" do
    let(:mocked_rpc_server) {
      double("GRPC::RpcServer")
    }

    before do
      allow(GRPC::RpcServer).to receive(:new).and_return(mocked_rpc_server)
    end

    it "executes various methods of mocked_rpc_server and print logs" do
      expect(mocked_rpc_server).to receive(:add_http2_port).with("0.0.0.0:50051", :this_port_is_insecure)
      expect(mocked_rpc_server).to receive(:handle).with(instance_of(Grpc::Health::Checker))
      expect(mocked_rpc_server).to receive(:run_till_terminated_or_interrupted).with(["TERM", "INT"])

      mocked_logger = Support::MockedLogger.new
      server = GrpcServer::Engine.new(
        env:    "test",
        logger: mocked_logger
      )
      server.run

      expect(mocked_logger.logged_messages).to eq [
        "gRPC server starting...",
        "* Max threads: 30",
        "* Environment: test",
        "* Listening on tcp://0.0.0.0:50051",
        "Use Ctrl-C to stop",
        "Exiting",
      ]
    end
  end

  describe "#run e2e" do
    let(:server) {
      server = GrpcServer::Engine.new(
        env:    "test",
        logger: mocked_logger,
      )
    }
    let(:mocked_logger) {
      Support::MockedLogger.new
    }

    context "when run in a thread" do
      let(:health_client) {
        Grpc::Health::V1::Health::Stub.new(
          "0.0.0.0:50051",
          :this_channel_is_insecure,
        )
      }
      let(:user_client) {
        Support::UserService::Stub.new(
          "0.0.0.0:50051",
          :this_channel_is_insecure,
        )
      }

      around do |example|
        server.set_handler(Support::UserServer)  # Set handler

        th = Thread.new { server.run }
        sleep(0.1)  # Wait for the server to start up

        example.run

        server.stop
        th.join  # Wait for the server to go down
      end

      it "support health checker and handles requests" do
        no_service_req = Grpc::Health::V1::HealthCheckRequest.new
        expect(health_client.check(no_service_req))
          .to eq Grpc::Health::V1::HealthCheckResponse.new(status: :SERVING)

        service_req = Grpc::Health::V1::HealthCheckRequest.new(service: "support.UserService")
        expect(health_client.check(service_req))
          .to eq Grpc::Health::V1::HealthCheckResponse.new(status: :SERVING)

        unknown_service_req = Grpc::Health::V1::HealthCheckRequest.new(service: "unknown")
        expect { health_client.check(unknown_service_req) }
          .to raise_error(GRPC::NotFound)

        expect(user_client.get_user(Google::Protobuf::Empty.new))
          .to eq Google::Protobuf::Empty.new
      end
    end

    context "when run in another process" do
      it "terminates gracefully" do
        pipe = IO.popen(["bundle", "exec", "ruby", "examples/server.rb"], "r")
        child_pid = pipe.pid

        sleep(1)  # Wait for the process to start

        # Send TERM for gracefully shutdown
        Process.kill("TERM", child_pid)
        Process.waitpid(child_pid)

        # Check the log
        a = 6.times.map { pipe.gets }
          .map { |msg| msg.gsub(/^.*(INFO)/, '\1') }  # Skip timestamp
        expect(a).to eq [
          "INFO -- : gRPC server starting...\n",
          "INFO -- : * Max threads: 30\n",
          "INFO -- : * Environment: unknown\n",
          "INFO -- : * Listening on tcp://0.0.0.0:50051\n",
          "INFO -- : Use Ctrl-C to stop\n",
          "INFO -- : Exiting\n",
        ]
      end
    end
  end
end
