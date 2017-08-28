module Curlybars
  module Node
    Text = Struct.new(:text) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          buffer.concat(#{text.inspect}.html_safe)
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end
    end
  end
end
