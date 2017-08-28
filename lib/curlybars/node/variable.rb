module Curlybars
  module Node
    Variable = Struct.new(:variable, :position) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          -> {
            position = rendering.position(
              #{position.line_number},
              #{position.line_offset}
            )
            rendering.variable(#{variable.inspect}, position)
          }
        RUBY
      end

      def validate(branches)
        # Nothing to validate here.
      end

      def validate_as_value(branches)
        # It is always a value.
      end
    end
  end
end
