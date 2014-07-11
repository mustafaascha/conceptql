require_relative 'node'

module ConceptQL
  module Nodes
    # Represents a node that will grab all person rows that match the given races
    #
    # Race parameters are passed in as a set of strings.  Each string represents
    # a single race.  The race string must match one of the values in the
    # concept_name column of the concept table.  If you misspell the race name
    # you won't get any matches
    class Race < Node
      def types
        [:person]
      end

      def query(db)
        db.from(:person_with_dates___p)
          .join(:vocabulary__concept___vc, { vc__concept_id: :p__race_concept_id })
          .where(Sequel.function(:lower, :vc__concept_name) => arguments.map(&:downcase))
      end
    end
  end
end
