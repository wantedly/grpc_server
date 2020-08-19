#!/usr/bin/ruby

$stdout.sync = true

require "grpc_server"

server = GrpcServer.new
server.run
