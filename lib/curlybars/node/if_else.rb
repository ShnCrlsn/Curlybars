module Curlybars
  module Node
    IfElse = Struct.new(:expression, :if_template, :else_template) do
      def compile
        <<-RUBY
          if rendering.to_bool(#{expression.compile}.call)
            buffer.safe_concat(#{if_template.compile})
          else
            buffer.safe_concat(#{else_template.compile})
          end
        RUBY
      end

      def validate(branches)
        [
          expression.validate(branches),
          if_template.validate(branches),
          else_template.validate(branches)
        ]
      end
    end
  end
end
