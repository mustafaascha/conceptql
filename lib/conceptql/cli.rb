$: << "lib"

require 'thor'
require 'sequelizer'
require 'json'
require 'pp'
require 'csv'
require_relative 'query'
require_relative 'knitter'

module ConceptQL
  class CLI < Thor
    include Sequelizer

    class_option :adapter,
      aliases: :a,
      desc: 'adapter for database'
    class_option :host,
      aliases: :h,
      banner: 'localhost',
      desc: 'host for database'
    class_option :username,
      aliases: :u,
      desc: 'username for database'
    class_option :password,
      aliases: :P,
      desc: 'password for database'
    class_option :port,
      aliases: :p,
      type: :numeric,
      banner: '5432',
      desc: 'port for database'
    class_option :database,
      aliases: :d,
      desc: 'database for database'
    class_option :search_path,
      aliases: :s,
      desc: 'schema for database (PostgreSQL only)'

    desc 'run_statement statement_file', 'Reads the ConceptQL statement from the statement file and executes it against the DB'
    def run_statement(statement_file)
      q = cdb(options).query(criteria_from_file(statement_file))
      puts q.sql
      puts JSON.pretty_generate(q.statement)
      pp q.query.all
    end

    desc "annotate_statement", "Reads in a statement and annotates it"
    def annotate_statement(statement_file)
      q = ConceptQL::Query.new(db(options), criteria_from_file(statement_file))
      pp q.annotate
    end

    desc 'show_graph statement_file', 'Reads the ConceptQL statement from the file and shows the contents as a ConceptQL graph'
    option :watch_file
    def show_graph(file)
      graph_it(criteria_from_file(file))
      system('open /tmp/graph.pdf')
    end

    desc 'show_and_tell_file statement_file', 'Reads the ConceptQL statement from the file and shows the contents as a ConceptQL graph, then executes the statement against the DB'
    option :full
    option :watch_file
    def show_and_tell_file(file)
      show_and_tell(criteria_from_file(file), options)
    end

    desc 'fake_graph file', 'Reads the ConceptQL statement from the file and shows the contents as a ConceptQL graph'
    def fake_graph(file)
      require_relative 'fake_annotater'
      annotated = ConceptQL::FakeAnnotater.new(criteria_from_file(file)).annotate
      pp annotated
      ConceptQL::AnnotateGrapher.new.graph_it(annotated, '/tmp/graph.pdf')
      system('open /tmp/graph.pdf')
    end

    desc 'metadata', 'Generates the metadata.js file for the JAM'
    def metadata
      File.write('metadata.js', "$metadata = #{ConceptQL.metadata(warn: true).to_json};")
      File.write('metadata.json', ConceptQL.metadata.to_json)
      if system("which", "json_pp", out: File::NULL, err: File::NULL)
        system("cat metadata.json | json_pp", out: "metadata_pp.json")
      end
    end

    desc 'selection_operators', 'Generates a TSV of all the selection operators'
    def selection_operators
      require 'csv'
      CSV.open('selection_operators.tsv', 'w', col_sep: "\t") do |csv|
        csv << ["name"]
        ConceptQL.metadata[:operators].values.select { |v| v[:basic_type] == :selection }.map { |v| v[:preferred_name] }.each do |name|
          csv << [name]
        end
      end

      CSV.open('domains.tsv', 'w', col_sep: "\t") do |csv|
        csv << ["name"]
        ConceptQL::Operators::TABLE_COLUMNS.each do |domain, columns|
          next unless columns.include?(:person_id)
          next if domain.to_s =~ /era\Z/
          csv << [domain]
        end
      end
    end

    desc 'knit', 'Processes ConceptQL fenced code segments and produces a Markdown file'
    option :ignore_cache, type: :boolean
    def knit(file)
      opts = {}
      if options[:ignore_cache]
        opts[:cache_options] = { ignore: true }
      end
      ConceptQL::Knitter.new(ConceptQL::Database.new(db), file, opts).knit
    end

    desc 'dumpit', 'Dumps out test data into CSVs'
    def dumpit(path)
      path = Pathname.new(path)
      path.mkpath unless path.exist?
      headers_path = path + 'headers'
      headers_path.mkpath unless headers_path.exist?
      db.tables.each do |table|
        puts "Dumping #{table}..."
        ds = db[table]
        rows = ds.select_map(ds.columns)
        CSV.open(path + "#{table}.csv", "wb") do |csv|
          rows.each { |row| csv << row }
        end
        CSV.open(headers_path + "#{table}.csv", "wb") do |csv|
          csv << ds.columns
        end
      end
    end

    private
    desc 'show_and_tell_db conceptql_id', 'Fetches the ConceptQL from a DB and shows the contents as a ConceptQL graph, then executes the statement against our test database'
    option :full
    option :watch_file
    def show_and_tell_db(conceptql_id)
      result = fetch_conceptql(conceptql_id, options)
      puts "Concept: #{result[:label]}"
      show_and_tell(result[:statement].to_hash, options, result[:label])
    end

    desc 'show_db_graph conceptql_id', 'Shows a graph for the conceptql statement represented by conceptql_id in the db specified by db_url'
    def show_db_graph(conceptql_id)
      result = fetch_conceptql(conceptql_id, options)
      graph_it(result[:statement], db, result[:label])
    end

    def fetch_conceptql(conceptql_id)
      my_db = db(options)
      my_db.extension(:pg_array, :pg_json)
      my_db[:concepts].where(concept_id: conceptql_id).select(:statement, :label).first
    end

    def show_and_tell(statement, options, title = nil)
      my_db = db(options)
      q = ConceptQL::Query.new(my_db, statement)
      statement = q.annotate
      puts 'JSON'
      puts JSON.pretty_generate(statement)
      graph_it(statement, title)
      STDIN.gets
      puts q.sql
      STDIN.gets
      results = q.all
      if options[:full]
        pp results
      else
        pp filtered(results)
      end
      puts results.length
    end

    def graph_it(statement, title = nil)
      my_db = db(options)
      q = ConceptQL::Query.new(my_db, statement).annotate
      ConceptQL::AnnotateGrapher.new.graph_it(q, '/tmp/graph.pdf')
    end

    def criteria_from_file(file)
      case File.extname(file)
      when '.json'
        JSON.parse(File.read(file))
      else
        eval(File.read(file))
      end
    end

    def filtered(results)
      results.each { |r| r.delete_if { |k,v| v.nil? } }
    end

    def cdb(options)
      ConceptQL::Database.new(db(options))
    end
  end
end

