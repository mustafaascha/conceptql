require_relative 'temporal_operator'

module ConceptQL
  module Operators
    class During < TemporalOperator
      register __FILE__

      desc <<-EOF
Compares all results on a person-by-person basis between the left hand results (LHR) and the right hand results (RHR).
Any result in the LHR with a start_date and end_date that occur within the start_date and end_date of a result in the RHR is passed through.
All other results are discarded, including all results in the RHR.
      EOF

      def apply_where_clause(ds)
        clause = (within_start <= l_start_date) & (l_end_date <= within_end)
        ds.where(clause)
      end
    end
  end
end
