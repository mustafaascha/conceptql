require 'facets/kernel/meta_def'
require 'facets/string/snakecase'

module Metadatable
  def preferred_name(value = nil)
    return @preferred_name unless value
    @preferred_name = value
  end

  def desc(value = nil)
    return @desc unless value
    @desc = value
  end

  def predominant_domains(*values)
    return @predominant_domains if values.empty?
    @predominant_domains = values
  end

  def argument(name, options = {})
    (@arguments ||= [])
    @arguments << [name, options]
  end

  def option(name, options = {})
    @options ||= {}
    @options[name] = options
  end

  def domains(*domain_list)
    @domains = domain_list
    define_method(:domains) do
      domain_list
    end
    if domain_list.length == 1
      define_method(:domain) do
        domain_list.first
      end
    end
  end

  def basic_type(value = nil)
    return @basic_type unless value
    @basic_type = value
  end

  def allows_many_upstreams
    @max_upstreams = 99
  end

  def allows_one_upstream
    @max_upstreams = 1
  end

  def just_class_name
    self.to_s.split('::').last
  end

  def humanized_class_name
    just_class_name.gsub(/([A-Z])/, ' \1').lstrip
  end

  def category(category)
    (@categories ||= [])
    @categories << Array(category)
  end

  def reset_categories
    @categories = []
  end

  def inherited(upstream)
    (@options || {}).each do |name, opt|
      upstream.option name, opt
    end

    (@categories || []).each do |cat|
      upstream.category cat
    end

    case @max_upstreams
    when 1
      upstream.allows_one_upstream
    when 99
      upstream.allows_many_upstreams
    end
  end

  def to_metadata(opts = {})
    warn_about_missing_metadata if opts[:warn]
    {
      preferred_name: @preferred_name || humanized_class_name,
      operation: just_class_name.snakecase,
      max_upstreams: @max_upstreams || 0,
      arguments: @arguments || [],
      options: @options || {},
      predominant_domains: @domains || @predominant_domains || [],
      desc: @desc,
      categories: @categories || []
    }
  end

  def warn_about_missing_metadata
    missing = []
    missing << :categories if (@categories || []).empty?
    missing << :desc unless @desc
    missing << :basic_type unless @basic_type
    puts "#{just_class_name} is missing #{missing.join(", ")}" unless missing.empty?
  end
end

