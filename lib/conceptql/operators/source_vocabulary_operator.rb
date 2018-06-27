require_relative 'vocabulary_operator'
require_relative 'vocabulary'

module ConceptQL
  module Operators
    # A SourceVocabularyOperator is a superclass for a operator that represents a criterion whose column stores information associated with a source vocabulary.
    #
    # If that seems confusing, then think of ICD-9 or NDC criteria.  That type of criterion takes a set of values that are mapped via the source_to_concept_map table into a standard vocabulary.
    #
    # This kind of criterion can have some interesting issues when we are searching for rows that match.  Let's take ICD-9 286.53 for example. That code maps to concept_id 0, so if we try to pull all conditions that match just the concept_id of 0 we'll pull all condtions that have no match in the SNOMED standard vocabulary.  That's not what we want!  So we need to search the condition_source_value field for matches on this code instead.
    #
    # But there's another, more complicated problem.  Say we're looking for ICD-9 289.81.  OMOP maps this to concept_id 432585.  OMOP also maps 20 other conditions, 6 of which are other ICD-9 codes, to this same concept_id.  So if we look for ICD-9s that have a non-zero condition_condept_id, we might pull up conditions that match on concept_id, but aren't the same exact code as the one we're looking for.
    #
    # My coworker came up with a nice, gneralized query that checks for matching concept_ids and matching source_code values.  This class encapsulates that query.
    #
    # Subclasses must provide the following methods:
    # * table
    #   * The CDM table name where the criterion will fetch its rows
    #   * e.g. for ICD-9, this would be condition_occurrence
    # * concept_column
    #   * Name of the column in the table that stores a concept_id related to the criterion
    #   * e.g. for ICD-9, this would be condition_concept_id
    # * source_column
    #   * Name of the column in the table that stores the "raw" value related to the criterion
    #   * e.g. for ICD-9, this would be condition_source_value
    # * vocabulary_id
    #   * The vocabulary ID of the source vocabulary for the criterion
    #   * e.g. for ICD-9, a value of 2 (for ICD-9-CM)
    class SourceVocabularyOperator < VocabularyOperator

      def query(db)
        return vocab_op.query(db) if gdm?
        ds = db.from(table_name).where(conditions(db))
        if omopv4?
          ds = ds.join(Sequel[:source_to_concept_map].as(:scm), [[Sequel[:scm][:target_concept_id], table_concept_column], [Sequel[:scm][:source_code], table_source_column]])
        end
        ds
      end

      def query_cols
        if omopv4?
          table_columns(table_name, :source_to_concept_map)
        elsif gdm?
          vocab_op.query_cols
        else
          table_columns(table_name)
        end
      end

      def unionable?(other)
        other.is_a?(self.class)
      end

      def union(other)
        dup_values(values + other.values)
      end

      def conditions(db)
        if omopv4?
          conds = [[Sequel[:scm][:source_vocabulary_id], vocabulary_id]]
          conds << [Sequel[:scm][:source_code], arguments_fix(db)] unless select_all?
          conds
        else
          conditions = {}
          conditions[code_column] = arguments_fix(db) unless select_all?
          conditions[vocabulary_id_column] = vocabulary_id if vocabulary_id_column
          conditions
        end
      end

      def describe_codes(db, codes)
        vocab_op.describe_codes(db, codes)
      end

      private

      def validate(db, opts = {})
        super
        if add_warnings?(db, opts) && !select_all?
          if gdm?
            vocab_op.validate(db, opts)
            @warnings += vocab_op.warnings
          else
            args = arguments.dup
            args -= bad_arguments
            missing_args = []

            if no_db?(db, opts)
              if lexicon
                missing_args = args - lexicon.known_codes(vocabulary_id, args)
              end
            else
              missing_args = args - db[:source_to_concept_map].where(:source_vocabulary_id=>vocabulary_id, :source_code=>arguments_fix(db, args)).select_map(:source_code)
            end

            unless missing_args.empty?
              add_warning("unknown source code", *missing_args)
            end
          end
        end
      end

      def table_source_column
        Sequel.qualify(:tab, source_column)
      end

      def table_is_missing?(db)
        dm.table_is_missing?(db)
      end
    end
  end
end

