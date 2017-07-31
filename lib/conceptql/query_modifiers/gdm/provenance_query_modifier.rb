require_relative '../query_modifier'

module ConceptQL
  module QueryModifiers
    module Gdm
      class ProvenanceQueryModifier < QueryModifier
        RELATED_COLUMNS = %w(
          provenance_concept_id
        ).sort.map(&:to_sym)

        attr :db

        def self.provided_columns
          [
            :provenance_type
          ]
        end

        def self.has_required_columns?(cols)
          !(RELATED_COLUMNS & cols).empty?
        end

        def initialize(*args)
          super
          @db = query.db
        end

        def modified_query
          return query unless self.class.has_required_columns?(dm.table_cols(source_table))
          query.select_append(Sequel[dm.provenance_type_column(query, source_table)].as(:provenance_type)).from_self
        end
      end
    end
  end
end



