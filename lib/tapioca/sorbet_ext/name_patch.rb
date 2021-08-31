# typed: true
# frozen_string_literal: true

module T
  module Types
    class Simple
      module NamePatch
        def name
          @name ||= ::Tapioca::Reflection.qualified_name_of(@raw_type).freeze
        end
      end

      T::Types::Simple::Private::Pool.instance_variable_set(:@cache, ObjectSpace::WeakMap.new)
      prepend NamePatch
    end
  end
end
