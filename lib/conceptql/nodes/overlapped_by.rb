require_relative 'temporal_node'

module ConceptQL
  module Nodes
    class OverlappedBy < TemporalNode
      def where_clause
        clauses = []
        clauses << [Proc.new { r__start_date <= l__start_date}, Proc.new { l__start_date <= r__end_date }, Proc.new { r__end_date <= l__end_date }]
        if inclusive?
          clauses << [Proc.new { r__start_date <= l__start_date}, Proc.new { l__end_date <= r__end_date }]
        end
        clauses.map { |clause| clause.map { |pr| Sequel.expr(pr) }.inject(&:&) }.inject(&:|)
      end
    end
  end
end
