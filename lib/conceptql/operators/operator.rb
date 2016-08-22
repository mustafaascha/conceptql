require 'zlib'
require_relative '../behaviors/metadatable'
require 'facets/array/extract_options'
require 'facets/hash/deep_rekey'
require 'forwardable'

module ConceptQL
  module Operators
    OPERATORS = {:omopv4=>{}, :omopv4_plus=>{}}.freeze

    SELECTED_COLUMNS = [:person_id, :criterion_id, :criterion_domain, :start_date, :end_date, :value_as_number, :value_as_string, :value_as_concept_id, :units_source_value, :source_value].freeze

    TABLE_VOCABULARY_ID_COLUMN = {
      :condition_occurrence=> :condition_source_vocabulary_id,
      :death=> :cause_of_death_source_vocabulary_id,
      :drug_exposure=> :drug_source_vocabulary_id,
      :observation=> :observation_source_vocabulary_id,
      :procedure_occurrence=> :procedure_source_vocabulary_id,
      :provider=> :specialty_source_vocabulary_id,
      :visit_occurrence=> :place_of_service_source_vocabulary_id
    }.freeze.each_value(&:freeze)

    TABLE_SOURCE_VALUE_COLUMN = {
      :condition_occurrence=> :condition_source_value,
      :death=> :cause_of_death_source_value,
      :drug_exposure=> :drug_source_value,
      :observation=> :observation_source_value,
      :procedure_occurrence=> :procedure_source_value,
      :provider=> :provider_source_value,
      :visit_occurrence=> :place_of_service_source_value
    }.freeze.each_value(&:freeze)

    TABLE_COLUMNS = {
      :care_site=>[:care_site_id, :location_id, :organization_id, :place_of_service_concept_id, :care_site_source_value, :place_of_service_source_value],
      :cohort=>[:cohort_id, :cohort_concept_id, :cohort_start_date, :cohort_end_date, :subject_id, :stop_reason],
      :concept=>[:concept_id, :concept_name, :concept_level, :concept_class, :vocabulary_id, :concept_code, :valid_start_date, :valid_end_date, :invalid_reason],
      :concept_ancestor=>[:ancestor_concept_id, :descendant_concept_id, :min_levels_of_separation, :max_levels_of_separation],
      :concept_relationship=>[:concept_id_1, :concept_id_2, :relationship_id, :valid_start_date, :valid_end_date, :invalid_reason],
      :concept_synonym=>[:concept_synonym_id, :concept_id, :concept_synonym_name],
      :condition_era=>[:condition_era_id, :person_id, :condition_concept_id, :condition_era_start_date, :condition_era_end_date, :condition_type_concept_id, :condition_occurrence_count],
      :condition_occurrence=>[:condition_occurrence_id, :person_id, :condition_concept_id, :condition_start_date, :condition_end_date, :condition_type_concept_id, :stop_reason, :associated_provider_id, :visit_occurrence_id, :condition_source_value],
      :death=>[:person_id, :death_date, :death_type_concept_id, :cause_of_death_concept_id, :cause_of_death_source_value],
      :drug_approval=>[:ingredient_concept_id, :approval_date, :approved_by],
      :drug_cost=>[:drug_cost_id, :drug_exposure_id, :paid_copay, :paid_coinsurance, :paid_toward_deductible, :paid_by_payer, :paid_by_coordination_benefits, :total_out_of_pocket, :total_paid, :ingredient_cost, :dispensing_fee, :average_wholesale_price, :payer_plan_period_id],
      :drug_era=>[:drug_era_id, :person_id, :drug_concept_id, :drug_era_start_date, :drug_era_end_date, :drug_type_concept_id, :drug_exposure_count],
      :drug_exposure=>[:drug_exposure_id, :person_id, :drug_concept_id, :drug_exposure_start_date, :drug_exposure_end_date, :drug_type_concept_id, :stop_reason, :refills, :quantity, :days_supply, :sig, :prescribing_provider_id, :visit_occurrence_id, :relevant_condition_concept_id, :drug_source_value],
      :drug_strength=>[:drug_concept_id, :ingredient_concept_id, :amount_value, :amount_unit, :concentration_value, :concentration_enum_unit, :concentration_denom_unit, :valid_start_date, :valid_end_date, :invalid_reason],
      :location=>[:location_id, :address_1, :address_2, :city, :state, :zip, :county, :location_source_value],
      :observation=>[:observation_id, :person_id, :observation_concept_id, :observation_date, :observation_time, :value_as_number, :value_as_string, :value_as_concept_id, :unit_concept_id, :range_low, :range_high, :observation_type_concept_id, :associated_provider_id, :visit_occurrence_id, :relevant_condition_concept_id, :observation_source_value, :units_source_value],
      :observation_period=>[:observation_period_id, :person_id, :observation_period_start_date, :observation_period_end_date, :prev_ds_period_end_date],
      :organization=>[:organization_id, :place_of_service_concept_id, :location_id, :organization_source_value, :place_of_service_source_value],
      :payer_plan_period=>[:payer_plan_period_id, :person_id, :payer_plan_period_start_date, :payer_plan_period_end_date, :payer_source_value, :plan_source_value, :family_source_value, :prev_ds_period_end_date],
      :person=>[:person_id, :gender_concept_id, :year_of_birth, :month_of_birth, :day_of_birth, :race_concept_id, :ethnicity_concept_id, :location_id, :provider_id, :care_site_id, :person_source_value, :gender_source_value, :race_source_value, :ethnicity_source_value],
      :procedure_cost=>[:procedure_cost_id, :procedure_occurrence_id, :paid_copay, :paid_coinsurance, :paid_toward_deductible, :paid_by_payer, :paid_by_coordination_benefits, :total_out_of_pocket, :total_paid, :disease_class_concept_id, :revenue_code_concept_id, :payer_plan_period_id, :disease_class_source_value, :revenue_code_source_value],
      :procedure_occurrence=>[:procedure_occurrence_id, :person_id, :procedure_concept_id, :procedure_date, :procedure_type_concept_id, :associated_provider_id, :visit_occurrence_id, :relevant_condition_concept_id, :procedure_source_value],
      :provider=>[:provider_id, :npi, :dea, :specialty_concept_id, :care_site_id, :provider_source_value, :specialty_source_value],
      :relationship=>[:relationship_id, :relationship_name, :is_hierarchical, :defines_ancestry, :reverse_relationship],
      :source_to_concept_map=>[:source_code, :source_vocabulary_id, :source_code_description, :target_concept_id, :target_vocabulary_id, :mapping_type, :primary_map, :valid_start_date, :valid_end_date, :invalid_reason],
      :visit_occurrence=>[:visit_occurrence_id, :person_id, :visit_start_date, :visit_end_date, :place_of_service_concept_id, :care_site_id, :place_of_service_source_value],
      :vocabulary=>[:vocabulary_id, :vocabulary_name],
    }.freeze.each_value(&:freeze)

    def self.operators
      OPERATORS
    end

    class Operator
      extend Forwardable
      extend Metadatable
      COLUMNS = [
        :person_id,
        :criterion_id,
        :criterion_domain,
        :start_date,
        :end_date,
        :value_as_number,
        :value_as_string,
        :value_as_concept_id,
        :units_source_value,
        :source_value
      ]

      attr :nodifier, :values, :options, :arguments, :upstreams

      option :label, type: :string

      @validations = []

      class << self
        attr :validations, :codes_regexp

        def register(file, *data_models)
          data_models = OPERATORS.keys if data_models.empty?
          data_models.each do |dm|
            OPERATORS[dm][File.basename(file).sub(/\.rb\z/, '')] = self
          end
        end

        def query_columns(*tables)
          define_method(:query_cols) do
            table_columns(*tables)
          end
        end

        def default_query_columns
          define_method(:query_cols) do
            SELECTED_COLUMNS
          end
        end

        validation_meths = (<<-END).split.map(&:to_sym)
          no_upstreams
          one_upstream
          at_least_one_upstream
          at_most_one_upstream
          no_arguments
          one_argument
          at_least_one_argument
          at_most_one_argument
          option
          required_options
          codes_match
        END

        validation_meths.each do |type|
          meth = :"validate_#{type}"
          define_method(meth) do |*args|
            validations << [meth, *args]
          end
        end

        def codes_should_match(format)
          @codes_regexp = format
          validate_codes_match
        end

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@validations, validations.dup)
          subclass.instance_variable_set(:@codes_regexp, codes_regexp.dup) if codes_regexp
        end

        def new(*)
          operator = super

          # If operator has a label, replace it with a recall so all references
          # to it use the same code.
          if operator.label && !operator.errors
            operator.scope.add_operator(operator)
            operator = Operators::Recall.new(operator.nodifier, operator.label, replaced: true)
          end

          operator
        end
      end

      def initialize(nodifier, *args)
        @nodifier = nodifier
        @options = {}
        while args.last.is_a?(Hash)
          @options = @options.merge(args.extract_options!.deep_rekey)
        end
        args.reject!{|arg| arg.nil? || arg == ''}
        @upstreams, @arguments = args.partition { |arg| arg.is_a?(Array) || arg.is_a?(Operator) }
        @values = args

        scope.nest(self) do
          create_upstreams
        end
      end

      def create_upstreams
        @upstreams.map!{|stmt| to_op(stmt)}
      end

      def to_op(stmt)
        stmt.is_a?(Operator) ? stmt : nodifier.create(*stmt)
      end

      def operator_name
        self.class.just_class_name.underscore
      end

      def annotate(db)
        return @annotation if defined?(@annotation)

        scope_key = options[:id]||self.class.just_class_name.underscore
        annotation = {}
        counts = (annotation[:counts] ||= {})
        metadata = {:annotation=>annotation}
        if name = self.class.preferred_name
          metadata[:name] = name
        end
        res = [operator_name, *annotate_values(db)]

        if upstreams_valid?(db) && scope.valid? && db
          scope.with_ctes(evaluate(db), db)
            .from_self
            .select_group(:criterion_domain)
            .select_append{count{}.*.as(:rows)}
            .select_append{count(:person_id).distinct.as(:n)}
            .each do |h|
              counts[h.delete(:criterion_domain).to_sym] = h
          end
        elsif !errors.empty?
          annotation[:errors] = errors
          scope.add_errors(scope_key, errors)
        end
        scope.add_operators(self)
        domains.each do |domain|
          cur_counts = counts[domain] ||= {:rows=>0, :n=>0}
          scope.add_counts(scope_key, domain, cur_counts)
        end

        if defined?(@warnings) && !warnings.empty?
          annotation[:warnings] = warnings
          scope.add_warnings(scope_key, warnings)
        end

        if res.last.is_a?(Hash)
          res.last.merge!(metadata)
        else
          res << metadata
        end

        @annotation = res
      end

      def code_list(db)
        code_lists = @upstreams.map do | upstream_op |
          upstream_op.code_list(db)
        end
        code_lists.flatten(1)
      end

      def dup_values(args)
        self.class.new(nodifier, *args)
      end

      def inspect
        "<##{self.class} upstreams=[#{upstreams.map(&:inspect).join(', ')}] arguments=[#{arguments.map(&:inspect).join(', ')}]>"
      end

      def evaluate(db)
        select_it(query(db))
      end

      def sql(db)
        evaluate(db).sql
      end

      def optimized
        dup_values(values.map{|x| x.is_a?(Operator) ? x.optimized : x})
      end

      def unionable?(other)
        false
      end

      def select_it(query, specific_domain = nil)
        if specific_domain.nil? && respond_to?(:domain) && TABLE_COLUMNS.keys.include?(domain)
          specific_domain = domain
        end
        q = query.select(*columns(query, specific_domain))
        if scope && scope.person_ids && upstreams.empty?
          q = q.where(person_id: scope.person_ids).from_self
        end
        q
      end

      def domains
        @domains ||= determine_domains
      end

      def stream
        @stream ||= upstreams.first
      end

      def columns(query, local_domain = nil)
        criterion_domain = :criterion_domain
        if local_domain
          criterion_domain = Sequel.cast_string(local_domain.to_s).as(:criterion_domain)
        end
        columns = [:person_id,
                    domain_id(local_domain),
                    criterion_domain]
        columns += date_columns(query, local_domain)
        columns += value_columns(query, local_domain)
      end

      def label
        @label ||= begin
          options.delete(:label) if options[:label] && options[:label].to_s.strip.empty?
          options[:label].respond_to?(:strip) ? options[:label].strip : options[:label]
        end
      end

      attr :errors, :warnings

      def valid?(db)
        return @errors.empty? if defined?(@errors)
        @errors = []
        @warnings = []
        validate(db)
        errors.empty?
      end

      def upstreams_valid?(db)
        valid?(db) && upstreams.all?{|u| u.upstreams_valid?(db)}
      end

      def scope
        nodifier.scope
      end

      def data_model
        nodifier.data_model
      end

      def database_type
        nodifier.database_type
      end

      private

      def annotate_values(db)
        (upstreams.map { |op| op.annotate(db) } + arguments).push(options)
      end

      def criterion_id
        :criterion_id
      end

      def domain_id(domain = nil)
        return :criterion_id if domain.nil?
        domain = :person if domain == :death
        Sequel.expr(make_domain_id(domain)).as(:criterion_id)
      end

      def make_domain_id(domain)
        (domain.to_s + '_id').to_sym
      end

      def make_table_name(table)
        "#{table}___tab".to_sym
      end

      def query_cols
        raise NotImplementedError, self
      end

      def query_columns(query)
        unless cols = query.opts[:force_columns]
          cols = query_cols
        end

        if ENV['CONCEPTQL_CHECK_COLUMNS']
          if cols.sort != query.columns.sort
            raise "columns don't match:\nclass: #{self.class}\nexpected: #{cols}\nactual: #{query.columns}\nvalues: #{values}\nSQL: #{query.sql}"
          end
        end

        cols
      end

      def omopv4_plus?
        data_model == :omopv4_plus
      end

      def omopv4?
        data_model == :omopv4
      end

      def impala?
        database_type.to_sym == :impala
      end

      def table_to_sym(table)
        case table
        when Symbol
          table = Sequel.split_symbol(table)[1].to_sym
        end
        table
      end

      def table_cols(table)
        table = table_to_sym(table)
        cols = TABLE_COLUMNS.fetch(table)
        if omopv4_plus?
          cols += Array(table_vocabulary_id(table))
        end
        cols
      end

      def table_columns(*tables)
        tables.map{|t| table_cols(t)}.flatten
      end

      def table_source_value(table)
        TABLE_SOURCE_VALUE_COLUMN.fetch(table_to_sym(table))
      end

      def table_vocabulary_id(table)
        TABLE_VOCABULARY_ID_COLUMN[table_to_sym(table)]
      end

      def value_columns(query, domain)
        [
          numeric_value(query),
          string_value(query),
          concept_id_value(query),
          units_source_value(query),
          source_value(query, domain)
        ]
      end

      def numeric_value(query)
        return :value_as_number if query_columns(query).include?(:value_as_number)
        Sequel.cast_numeric(nil, Float).as(:value_as_number)
      end

      def string_value(query)
        return :value_as_string if query_columns(query).include?(:value_as_string)
        Sequel.cast_string(nil).as(:value_as_string)
      end

      def concept_id_value(query)
        return :value_as_concept_id if query_columns(query).include?(:value_as_concept_id)
        Sequel.cast_numeric(nil).as(:value_as_concept_id)
      end

      def units_source_value(query)
        return :units_source_value if query_columns(query).include?(:units_source_value)
        Sequel.cast_string(nil).as(:units_source_value)
      end

      def source_value(query, domain)
        return :source_value if query_columns(query).include?(:source_value)
        Sequel.cast_string(source_value_column(query, domain)).as(:source_value)
      end

      def date_columns(query, domain = nil)
        return [:start_date, :end_date] if (query_columns(query).include?(:start_date) && query_columns(query).include?(:end_date))
        return [:start_date, :end_date] unless domain

        date_klass = Date
        if query.db.database_type == :impala
          date_klass = DateTime
        end

        sd = start_date_column(query, domain)
        sd = Sequel.cast(Sequel.expr(sd), date_klass).as(:start_date) unless sd == :start_date
        ed = end_date_column(query, domain)
        ed = Sequel.cast(Sequel.function(:coalesce, Sequel.expr(ed), start_date_column(query, domain)), date_klass).as(:end_date) unless ed == :end_date
        [sd, ed]
      end

      def start_date_column(query, domain)
        {
          condition_occurrence: :condition_start_date,
          death: :death_date,
          drug_exposure: :drug_exposure_start_date,
          drug_cost: nil,
          payer_plan_period: :payer_plan_period_start_date,
          person: person_date_of_birth(query),
          procedure_occurrence: :procedure_date,
          procedure_cost: nil,
          observation: :observation_date,
          observation_period: :observation_period_start_date,
          visit_occurrence: :visit_start_date
        }[domain]
      end

      def end_date_column(query, domain)
        {
          condition_occurrence: :condition_end_date,
          death: :death_date,
          drug_exposure: :drug_exposure_end_date,
          drug_cost: nil,
          payer_plan_period: :payer_plan_period_end_date,
          person: person_date_of_birth(query),
          procedure_occurrence: :procedure_date,
          procedure_cost: nil,
          observation: :observation_date,
          observation_period: :observation_period_end_date,
          visit_occurrence: :visit_end_date
        }[domain]
      end

      def source_value_column(query, domain)
        {
          condition_occurrence: :condition_source_value,
          death: :cause_of_death_source_value,
          drug_exposure: :drug_source_value,
          drug_cost: nil,
          payer_plan_period: :payer_plan_period_source_value,
          person: :person_source_value,
          procedure_occurrence: :procedure_source_value,
          procedure_cost: nil,
          observation: :observation_source_value,
          observation_period: nil,
          visit_occurrence: :place_of_service_source_value
        }[domain]
      end

      def person_date_of_birth(query)
        assemble_date(query, :year_of_birth, :month_of_birth, :day_of_birth)
      end

      def assemble_date(query, *symbols)
        strings = symbols.map do |symbol|
          sub = '2000'
          col = Sequel.cast_string(symbol)
          if symbol != :year_of_birth
            sub = '01'
            col = Sequel.function(:lpad, col, 2, '0')
          end
          Sequel.function(:coalesce, col, Sequel.expr(sub))
        end

        strings_with_dashes = strings.zip(['-'] * (symbols.length - 1)).flatten.compact
        concatted_strings = Sequel.join(strings_with_dashes)

	      date = concatted_strings
	      if query.db.database_type == :impala
          date = Sequel.cast(Sequel.function(:concat_ws, '-', *strings), DateTime)
        end
        cast_date(query.db, date)
      end

      def  cast_date(db, date)
        case db.database_type
        when :oracle
          Sequel.function(:to_date, date, 'YYYY-MM-DD')
        when :mssql
          Sequel.lit('CONVERT(DATETIME, ?)', date)
        else
          Sequel.cast(date, Date)
        end
      end

      def determine_domains
        if upstreams.empty?
          if respond_to?(:domain)
            [domain]
          else
            [:invalid]
          end
        else
          domains = upstreams.compact.map(&:domains).flatten.uniq
          domains.empty? ? [:invalid] : domains
        end
      end

      # Validation Related

      def upstream_operator_names
        @upstreams.map(&:operator_name)
      end

      def validate(db)
        add_error("invalid label") if label && !label.is_a?(String)
        self.class.validations.each do |args|
          send(*args)
        end
      end

      def validate_no_upstreams
        add_error("has upstreams", upstream_operator_names) unless @upstreams.empty?
      end

      def validate_one_upstream
        validate_at_least_one_upstream
        validate_at_most_one_upstream
      end

      def validate_at_most_one_upstream
        add_error("has multiple upstreams", upstream_operator_names) if @upstreams.length > 1
      end

      def validate_at_least_one_upstream
        add_error("has no upstream") if @upstreams.empty?
      end

      def validate_no_arguments
        add_error("has arguments", @arguments) unless @arguments.empty?
      end

      def validate_one_argument
        validate_at_least_one_argument
        validate_at_most_one_argument
      end

      def validate_at_most_one_argument
        add_error("has multiple arguments", @arguments) if @arguments.length > 1
      end

      def validate_at_least_one_argument
        add_error("has no arguments") if @arguments.empty?
      end

      def validate_option(format, *opts)
        opts.each do |opt|
          if options.has_key?(opt)
            unless format === options[opt]
              add_error("wrong option format", opt.to_s)
            end
          end
        end
      end

      def validate_required_options(*opts)
        opts.each do |opt|
          unless options.has_key?(opt)
            add_error("required option not present", opt.to_s)
          end
        end
      end

      def bad_arguments
        return [] unless self.class.codes_regexp
        @bad_arguments ||= arguments.reject do |arg|
          self.class.codes_regexp === arg
        end
      end

      def validate_codes_match
        unless bad_arguments.empty?
          add_warning("improperly formatted code", *bad_arguments)
        end
      end

      def add_warnings?(db)
        @errors.empty? && db && db.adapter_scheme != :mock
      end

      def add_error(*args)
        errors << args
      end

      def add_warning(*args)
        warnings << args
      end

      def needs_arguments_cte?(args)
        impala? && arguments.length > 5000
      end

      def arguments_fix(db, args = nil)
        args ||= arguments
        return args unless needs_arguments_cte?(args)
        args = args.dup
        first_arg = Sequel.expr(args.shift).as(:arg)
        args.unshift(first_arg)
        args = args.map { |v| [v] }
        args_cte = db.values(args)
        db[:args]
          .with(:args, args_cte)
          .select(:arg)
      end
    end
  end
end

# Require all operator subclasses eagerly
Dir.new(File.dirname(__FILE__)).
  entries.
  each{|filename| require_relative filename if filename =~ /\.rb\z/ && filename != File.basename(__FILE__)}
ConceptQL::Operators.operators.values.each(&:freeze)
