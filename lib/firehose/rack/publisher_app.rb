module Firehose
  module Rack
    class PublisherApp
      def call(env)
        req     = env['parsed_request'] ||= ::Rack::Request.new(env)
        path    = req.path
        method  = req.request_method

        case method
        when 'PUT'
          body = env['rack.input'].read
          Firehose.logger.debug "HTTP published `#{body}` to `#{path}`"
          publisher.publish(path, body)

          [202, {}, []]
        else
          Firehose.logger.debug "HTTP #{method} not supported"
          [501, {'Content-Type' => 'text/plain'}, ["#{method} not supported."]]
        end
      end


      private
      def publisher
        @publisher ||= Firehose::Publisher.new
      end
    end
  end
end
