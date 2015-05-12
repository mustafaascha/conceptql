require_relative 'source_vocabulary_node'

module ConceptQL
  module Operators
    class Ndc < SourceVocabularyNode
      preferred_name 'NDC'
      desc 'Searches the drug_exposure table for all procedures with matching NDC codes'
      argument :ndcs, type: :codelist, vocab: 'NDC'
      predominant_types :drug_exposure

      def table
        :drug_exposure
      end

      def vocabulary_id
        9
      end

      def source_column
        :drug_source_value
      end

      def concept_column
        :drug_concept_id
      end
    end
  end
end

