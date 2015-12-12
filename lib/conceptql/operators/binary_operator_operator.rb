require_relative 'operator'
require 'facets/string/titlecase'

module ConceptQL
  module Operators
    # Base class for all operators that take two streams, a left-hand and a right-hand
    class BinaryOperatorOperator < Operator
      register __FILE__

      option :left, type: :upstream
      option :right, type: :upstream

      def upstreams
        [left]
      end

      def graph_it(g, db)
        left.graph_it(g, db)
        right.graph_it(g, db)
        cluster_name = "cluster_#{operator_name}"
        me = g.send(cluster_name) do |sub|
          sub[rank: 'same', label: display_name, color: 'black']
          sub.send("#{cluster_name}_left").send('[]', shape: 'point', color: type_color(types))
          sub.send("#{cluster_name}_right").send('[]', shape: 'point')
        end
        left.link_to(g, me.send("#{cluster_name}_left"), db)
        right.link_to(g, me.send("#{cluster_name}_right"), db)
        @__graph_operator = me.send("#{cluster_name}_left")
      end

      def display_name
        self.class.name.split('::').last.snakecase.titlecase
      end

      private
      def left
        @left ||= options[:left]
      end

      def right
        @right ||= options[:right]
      end
    end
  end
end

