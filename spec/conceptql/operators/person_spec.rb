require 'spec_helper'
require 'conceptql/operators/person'
require_double('stream_for_casting')

describe ConceptQL::Operators::Person do
  it_behaves_like(:casting_operator)
end



