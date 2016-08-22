require 'sequelizer'

DB = Object.new.extend(Sequelizer).db unless defined?(DB)


if %w(omopv4 omopv4_plus).include?(ENV['DATA_MODEL']) && !DB.table_exists?(:source_to_concept_map)
  $stderr.puts <<END
The source_to_concept_map table doesn't exist in this database,
so it appears this doesn't include the necessary OMOP vocabulary
data. Please review the README for how to setup the test database
with the vocabulary, which needs to be done before running tests.
END
  exit 1
end

