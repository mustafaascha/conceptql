require_relative 'operator'

module ConceptQL
  module Operators
    # Filters the incoming stream of events to only those that have a
    # an associated visit_occurrence with the matching place_of_service
    #
    # Provenance related concepts are the ones found in the xxx_type_concept_id
    # field.
    #
    # If the event has NULL for the provenance-related field, they are filtered
    # out.
    #
    # Multiple provenances can be specified at once
    class PlaceOfServiceFilter < Operator
      register __FILE__

      desc "Filters incoming events to only those that match the provenances."
      argument :places_of_service, type: :codelist, vocab: 'Place of Service'
      category "Filter Single Stream"
      basic_type :temporal
      allows_one_upstream
      validate_one_upstream
      validate_at_least_one_argument
      require_column :place_of_service_concept_id
      default_query_columns

      def query(db)
        db.from(stream.evaluate(db))
          .where(place_of_service_concept_id: place_of_service_concept_ids(db))
      end

    private

      def place_of_service_concept_ids(db)
        db.from(:concept)
          .where(concept_code: arguments.map(&:to_s))
          .where(vocabulary_id: 14)
          .select(:concept_id)
      end
    end
  end
end
