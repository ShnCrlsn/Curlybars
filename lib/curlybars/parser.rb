require 'rltk/parser'

require 'curlybars/node/root'
require 'curlybars/node/template'
require 'curlybars/node/item'
require 'curlybars/node/text'
require 'curlybars/node/if_else'
require 'curlybars/node/unless_else'
require 'curlybars/node/each_else'
require 'curlybars/node/path'
require 'curlybars/node/literal'
require 'curlybars/node/variable'
require 'curlybars/node/with_else'
require 'curlybars/node/block_helper_else'
require 'curlybars/node/option'
require 'curlybars/node/partial'
require 'curlybars/node/output'

module Curlybars
  class Parser < RLTK::Parser
    start :root

    production(:root, 'template?') { |template| Node::Root.new(template || EMPTY, pos(0)) }
    production(:template, 'items') { |items| Node::Template.new(items || [], pos(0)) }

    production(:items) do
      clause('items item') { |items, item| items << Node::Item.new(item) }
      clause('item') { |item| [Node::Item.new(item)] }
    end

    production(:item) do
      clause('TEXT') { |text| Node::Text.new(text) }

      clause(
        'START HASH .path .expressions? .options? END
          .template?
        START SLASH .path END') do |helper, arguments, options, template, helperclose|
        Node::BlockHelperElse.new(
          helper,
          arguments || [],
          options || [],
          template || EMPTY,
          EMPTY,
          helperclose,
          pos(0)
        )
      end

      clause(
        'START HASH .path .expressions? .options? END
          .template?
        START ELSE END
          .template?
        START SLASH .path END') do |helper, arguments, options, helper_template, else_template, helperclose|
        Node::BlockHelperElse.new(
          helper,
          arguments || [],
          options || [],
          helper_template || EMPTY,
          else_template || EMPTY,
          helperclose,
          pos(0)
        )
      end

      clause('START .path .expressions? .options? END') do |helper, arguments, options|
        Node::BlockHelperElse.new(
          helper,
          arguments || [],
          options || [],
          EMPTY,
          EMPTY,
          helper,
          pos(0)
        )
      end

      clause('START .value END') do |value|
        Node::Output.new(value)
      end

      clause(
        'START HASH IF .expression END
          .template?
        START SLASH IF END') do |expression, if_template|
        Node::IfElse.new(expression, if_template || EMPTY, EMPTY)
      end

      clause(
        'START HASH IF .expression END
          .template?
        START ELSE END
          .template?
        START SLASH IF END') do |expression, if_template, else_template|
        Node::IfElse.new(expression, if_template || EMPTY, else_template || EMPTY)
      end

      clause(
        'START HASH UNLESS .expression END
          .template?
        START SLASH UNLESS END') do |expression, unless_template|
        Node::UnlessElse.new(expression, unless_template || EMPTY, EMPTY)
      end

      clause(
        'START HASH UNLESS .expression END
          .template?
        START ELSE END
          .template?
        START SLASH UNLESS END') do |expression, unless_template, else_template|
        Node::UnlessElse.new(expression, unless_template || EMPTY, else_template || EMPTY)
      end

      clause(
        'START HASH EACH .path END
          .template?
        START SLASH EACH END') do |path, each_template|
        Node::EachElse.new(path, each_template || EMPTY, EMPTY, pos(0))
      end

      clause(
        'START HASH EACH .path END
          .template?
        START ELSE END
          .template?
        START SLASH EACH END') do |path, each_template, else_template|
        Node::EachElse.new(path, each_template || EMPTY, else_template || EMPTY, pos(0))
      end

      clause(
        'START HASH WITH .path END
          .template?
        START SLASH WITH END') do |path, with_template|
        Node::WithElse.new(path, with_template || EMPTY, EMPTY, pos(0))
      end

      clause(
        'START HASH WITH .path END
          .template?
        START ELSE END
          .template?
        START SLASH WITH END') do |path, with_template, else_template|
        Node::WithElse.new(path, with_template || EMPTY, else_template || EMPTY, pos(0))
      end

      clause('START GT .path END') do |path|
        Node::Partial.new(path)
      end
    end

    production(:options) do
      clause('options option') { |options, option| options << option }
      clause('option') { |option| [option] }
    end

    production(:option, '.KEY .expression') do |key, expression|
      Node::Option.new(key, expression)
    end

    production(:expressions) do
      clause('expressions expression') { |expressions, expression| expressions << expression }
      clause('expression') { |expression| [expression] }
    end

    production(:expression) do
      clause('value') { |value| value }
      clause('path') { |path| path }
    end

    production(:value) do
      clause('LITERAL') { |literal| Node::Literal.new(literal) }
      clause('VARIABLE') { |variable| Node::Variable.new(variable, pos(0)) }
    end

    production(:path, 'PATH') { |path| Node::Path.new(path, pos(0)) }

    finalize

    VOID = Class.new do
      def compile
        "->{}"
      end

      def validate(branches)
        # Nothing to validate here.
      end
    end.new

    EMPTY = Class.new do
      def compile
        ''.inspect
      end

      def validate(branches)
        # Nothing to validate here.
      end
    end.new
  end
end
