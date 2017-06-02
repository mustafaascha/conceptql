module ConceptQL
  def self.root
    (Pathname.new(__dir__) + ".." + "..").expand_path
  end

  def self.schemas_dir
    root + 'schemas'
  end

  def self.config_dir
    root + 'config'
  end
end
