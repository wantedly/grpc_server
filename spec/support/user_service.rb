require "google/protobuf/empty_pb"

module Support
  module UserService
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'support.UserService'

      rpc :GetUser, Google::Protobuf::Empty, Google::Protobuf::Empty
    end

    Stub = Service.rpc_stub_class
  end
end
