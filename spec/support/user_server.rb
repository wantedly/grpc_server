require "support/user_service"

module Support
  class UserServer < Support::UserService::Service
    def get_user(req, call)
      Google::Protobuf::Empty.new
    end
  end
end
