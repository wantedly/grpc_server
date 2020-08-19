RSpec.describe GrpcServer do
  it "has a version number" do
    expect(GrpcServer::VERSION).not_to be nil
  end

  describe "#iniialize" do
    it "returns a GrpcServer object" do
      server = GrpcServer.new
      expect(server).is_a?(GrpcServer)
      expect(server).to respond_to(:set_handler)
      expect(server).to respond_to(:run)
      expect(server).to respond_to(:stop)
    end
  end
end
