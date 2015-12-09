require 'active_support/inflector'

module Associatable
  def belongs_to(model, options = {})
    self.assoc_options_store[model] = BelongsToOptions.new(model, options)

    define_method(model) do
      options = self.class.assoc_options_store[model]
      foreign_key = options.foreign_key
      primary_key = options.primary_key
      key = self.send(foreign_key)
      options.model_class.where(options.primary_key => key).first
    end
  end

  def has_many(model, options = {})
    self.assoc_options_store[model] = HasManyOptions.new(model, self.name, options)

    define_method(model) do
      options = self.class.assoc_options_store[model]
      foreign_key = options.foreign_key
      primary_key = options.primary_key
      key = self.send(primary_key)
      options.model_class.where(foreign_key => key)
    end
  end

  def assoc_options_store
    @assoc_options_store ||= {}
    @assoc_options_store
  end

end

class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(model, options = {})
    defaults = {
      :foreign_key => "#{model}_id".to_sym,
      :class_name => model.to_s.camelcase,
      :primary_key => :id
    }
    defaults.keys.each do |key|
      if options[key]
        self.send("#{key}=", options[key])
      else
        self.send("#{key}=", defaults[key])
      end
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(model, self_class, options = {})
    defaults = {
      :foreign_key => "#{self_class.underscore}_id".to_sym,
      :class_name => model.to_s.singularize.camelcase,
      :primary_key => :id
    }
    defaults.keys.each do |key|
      if options[key]
        self.send("#{key}=", options[key])
      else
        self.send("#{key}=", defaults[key])
      end
    end
  end
end

class ActiveRecordObject
  extend Associatable
end
