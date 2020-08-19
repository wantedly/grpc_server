module Support
  class MockedLogger
    def initialize
      @logged_messages = []
    end

    attr_reader :logged_messages

    # @param [String] msg
    def info(msg)
      @logged_messages << msg
    end
  end
end
