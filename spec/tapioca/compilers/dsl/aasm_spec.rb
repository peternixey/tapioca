# typed: strict
# frozen_string_literal: true

require "spec_helper"

class Tapioca::Compilers::Dsl::AASMSpec < DslSpec
  describe("#initialize") do
    it("gathers no constants if there are no classes that include AASM") do
      assert_empty(gathered_constants)
    end

    it("gathers only classes that include AASM") do
      add_ruby_file("content.rb", <<~RUBY)
        class StateMachine
          include AASM
          aasm { state :existing, initial: true }
        end
      RUBY

      assert_equal(["StateMachine"], gathered_constants)
    end
  end

  describe("#decorate") do
    it("generates empty RBI file if this is no state machine") do
      add_ruby_file("content.rb", <<~RUBY)
        class StateMachine
        end
      RUBY

      expected = <<~RBI
        # typed: strong
      RBI

      assert_equal(expected, rbi_for(:StateMachine))
    end

    it("generates correct RBI file") do
      add_ruby_file("content.rb", <<~RUBY)
        class StateMachine
          include AASM
          extend T::Sig

          aasm do
            state :sleeping, initial: true
            state :running, :cleaning

            event :run do
              before { before_run }
              transitions from: :sleeping, to: :running
            end
          end

          private

          sig { void }
          def before_run; end
        end
      RUBY

      expected = <<~RBI
        # typed: strong

        class StateMachine
          sig { returns(T::Boolean) }
          def cleaning?; end

          sig { returns(T::Boolean) }
          def may_run?; end

          sig { params(opts: T.untyped).returns(T.untyped) }
          def run(*opts); end

          sig { params(opts: T.untyped).returns(T.untyped) }
          def run!(*opts); end

          sig { params(opts: T.untyped).returns(T.untyped) }
          def run_without_validation!(*opts); end

          sig { returns(T::Boolean) }
          def running?; end

          sig { returns(T::Boolean) }
          def sleeping?; end

          sig { params(args: T.untyped, block: T.nilable(T.proc.bind(PrivateAASMMachine).void)).returns(PrivateAASMMachine) }
          def self.aasm(*args, &block); end

          class PrivateAASMMachine < AASM::Base
            sig { params(name: T.untyped, options: T.untyped, block: T.proc.bind(PrivateAASMEvent).void).returns(T.untyped) }
            def event(name, options = nil, &block); end

            class PrivateAASMEvent < AASM::Core::Event
              sig { params(block: T.proc.bind(StateMachine).void).returns(T.untyped) }
              def after(&block); end

              sig { params(block: T.proc.bind(StateMachine).void).returns(T.untyped) }
              def after_commit(&block); end

              sig { params(block: T.proc.bind(StateMachine).void).returns(T.untyped) }
              def after_transaction(&block); end

              sig { params(block: T.proc.bind(StateMachine).void).returns(T.untyped) }
              def before(&block); end

              sig { params(block: T.proc.bind(StateMachine).void).returns(T.untyped) }
              def before_success(&block); end

              sig { params(block: T.proc.bind(StateMachine).void).returns(T.untyped) }
              def before_transaction(&block); end

              sig { params(block: T.proc.bind(StateMachine).void).returns(T.untyped) }
              def ensure(&block); end

              sig { params(block: T.proc.bind(StateMachine).void).returns(T.untyped) }
              def error(&block); end

              sig { params(block: T.proc.bind(StateMachine).void).returns(T.untyped) }
              def success(&block); end
            end
          end

          STATE_CLEANING = T.let(T.unsafe(nil), Symbol)
          STATE_RUNNING = T.let(T.unsafe(nil), Symbol)
          STATE_SLEEPING = T.let(T.unsafe(nil), Symbol)
        end
      RBI

      assert_equal(expected, rbi_for(:StateMachine))
    end
  end
end
