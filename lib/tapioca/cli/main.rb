# typed: true
# frozen_string_literal: true

require "tapioca/cli/generate"

module Tapioca
  module Cli
    class Main < Thor
      include Thor::Actions

      desc :init, "Initializes your project to use Tapioca and Sorbet."
      long_desc <<~EOS
        Initializes your project to use Tapioca and Sorbet.

        Generates Sorbet configuration for your project, adds all Tapioca configuration and bootstraps your project
        with a Tapioca binstub.
      EOS
      def init
        create_config
        create_post_require
        generate_binstub
      end

      desc :version, "Prints Tapioca version information."
      def version
        puts "Tapioca v#{Tapioca::VERSION}"
      end
      map T.unsafe(%w[--version -v] => :version)

      desc "generate COMMAND", "Generators for creating project RBI files."
      subcommand :generate, Tapioca::Cli::Generate

      desc "sync", "Syncs RBIs to Gemfile."
      long_desc <<~EOS
        Syncs RBIs to Gemfile.

        Loads all Gems from your Gemfile into memory. Performs runtime introspection
        on the loaded types to understand their structure then generates an RBI file for
        each Gem with a versioned name.

        Output can be found in the `sorbet/rbi/gems` directory and will have a name in the form
        of `GEM@VERSION.rbi`.
      EOS
      def sync
        Tapioca.silence_warnings do
          generator.sync_rbis_with_gemfile
        end
      end

      private

      def generator
        current_command = T.must(current_command_chain.first)
        @generator ||= Generator.new(
          ConfigBuilder.from_options(current_command, options)
        )
      end

      def create_config
        create_file(Config::SORBET_CONFIG, skip: true) do
          <<~CONTENT
            --dir
            .
          CONTENT
        end
      end

      def create_post_require
        create_file(Config::DEFAULT_POSTREQUIRE, skip: true) do
          <<~CONTENT
            # typed: false
            # frozen_string_literal: true

            # Add your extra requires here
          CONTENT
        end
      end

      def generate_binstub
        installer = Bundler::Installer.new(Bundler.root, Bundler.definition)
        spec = Bundler.definition.specs.find { |s| s.name == "tapioca" }
        installer.generate_bundler_executable_stubs(spec, { force: true })
      end

      no_commands do
        def self.exit_on_failure?
          true
        end
      end
    end
  end
end
