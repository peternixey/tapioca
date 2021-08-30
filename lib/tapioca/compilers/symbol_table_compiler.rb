# typed: strong
# frozen_string_literal: true

module Tapioca
  module Compilers
    class SymbolTableCompiler
      extend(T::Sig)

      sig do
        params(
          gem: Gemfile::GemSpec,
          indent: Integer
        ).returns(String)
      end
      def compile(
        gem,
        indent = 0
      )
        Tapioca::Compilers::SymbolTable::SymbolGenerator.new(gem, indent).generate
      end
    end
  end
end
