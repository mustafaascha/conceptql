require_relative 'operator'

module ConceptQL
  module Operators
    class DrugTypeConcept < Operator
      register __FILE__, :omopv4

      desc 'Given a set of concept IDs in RxNorm, returns that set of drug exposures'
      argument :concept_ids, type: :codelist, vocab: 'RxNorm'

      def type
        :drug_exposure
      end

      def query(db)
        db.from(:drug_exposure)
          .where(drug_type_concept_id: arguments)
      end
    end
  end
end


