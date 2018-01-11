require "conceptql/version"
require "conceptql/logger"
require "conceptql/paths"
require "conceptql/utils"
require "conceptql/behaviors/windowable"
require "conceptql/query"
require "conceptql/null_query"
require "conceptql/database"
require "conceptql/data_model"
require_relative "conceptql/query_modifiers/gdm/pos_query_modifier"
require_relative "conceptql/query_modifiers/gdm/drug_query_modifier"
require_relative "conceptql/query_modifiers/gdm/provider_query_modifier"
require_relative "conceptql/query_modifiers/gdm/provenance_query_modifier"
require_relative "conceptql/query_modifiers/omopv4_plus/provider_query_modifier"
require_relative "conceptql/query_modifiers/omopv4_plus/pos_query_modifier"
require_relative "conceptql/query_modifiers/omopv4_plus/drug_query_modifier"
require_relative "conceptql/query_modifiers/omopv4_plus/provenance_query_modifier"

module ConceptQL
  def self.metadata(opts = {})
    {
      categories: categories,
      operators: ConceptQL::Nodifier.new.to_metadata(opts)
    }
  end

  def self.categories
    [
      'Select by Clinical Codes',
      'Select by Property',
      'Get Related Data',
      'Modify Data',
      'Combine Streams',
      'Filter by Comparing',
      'Filter Single Stream',
    ].map.with_index do |name, priority|
      { name: name, priority: priority }
    end
  end
end
