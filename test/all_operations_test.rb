require_relative './helper'

file_regexps = nil
if !ARGV.empty?
  file_regexps = ARGV.map { |f| /#{f}/ }
end

describe ConceptQL::Operators do

  Dir['./test/statements/**/*'].each do |f|
    next if File.directory? f
    next unless file_regexps.nil? || file_regexps.any? { |r| f =~ r }
    f.slice! './test/statements/'
    basename = File.basename(f)

    it "should produce correct results for #{f}" do
      test_type = basename.split("_").first

      case test_type
      when "crit"
        criteria_ids(f)
      when "anno"
        annotate(f)
      when "count"
        criteria_counts(f)
      when "optcc"
        optimized_criteria_counts(f)
      when "scanno"
        scope_annotate(f)
      when "domains"
        domains(f)
      when "cc"
        criteria_counts(f)
      when "optcc"
        optimized_criteria_counts(f)
      when "num"
        numeric_values(f)
      else
        raise "Invalid operation test prefix: #{test_type}"
      end
    end
  end
end
