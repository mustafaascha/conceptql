require_relative 'standard_vocabulary_operator'

module ConceptQL
  module Operators
    class Loinc < StandardVocabularyOperator
      register __FILE__, :omopv4

      preferred_name 'LOINC'
      desc 'Searches the observation table for all observations with matching LOINC codes'
      argument :loincs, type: :codelist, vocab: 'LOINC'
      predominant_types :observation

      def table
        :observation
      end

      def vocabulary_id
        6
      end

      def concept_column
        :observation_concept_id
      end
    end
  end
end

