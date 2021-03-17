# typed: true
# frozen_string_literal: true

module Tapioca
  module Cli
    class Generate < Thor
      include Thor::Actions

      class_option :prerequire,
                    aliases: ["-b", "--pre"],
                    banner: "<FILE>",
                    desc: "Specify a file to be required before `Bundler.require` is called."
      class_option :postrequire,
                    aliases: ["-a", "--post"],
                    banner: "FILE",
                    desc: "Specify a file to be required after `Bundler.require` is called."
      class_option :outdir,
                    aliases: ["-o", "--out"],
                    banner: "DIRECTORY",
                    desc: "Specify the output directory for generated RBI files."
      class_option :generate_command,
                    aliases: ["-c", "--cmd"],
                    banner: "COMMAND",
                    desc: "Specify the command to run to regenerate RBI files."
      class_option :exclude,
                    aliases: ["-x"],
                    type: :array,
                    banner: "GEM...",
                    desc: "Specify Gems to be excluded from RBI generation."
      class_option :typed_overrides,
                    aliases: ["-t", "--typed"],
                    type: :hash,
                    banner: "GEM:LEVEL...",
                    desc: "Specify overrides for typed sigils for generated Gem RBIs."

      desc "dsl [CONSTANT]...", "Generate RBIs for dynamic methods."
      long_desc <<~DESCRIPTION
        Generate RBIs for dynamic methods.

        # TODO
      DESCRIPTION
      option :generators,
        type: :array,
        aliases: ["-g", "--gen"],
        banner: "GENERATOR...",
        desc: "Will run with ONLY the specified DSL generators."
      option :verify,
        type: :boolean,
        aliases: ["-V"],
        default: false,
        desc: "Verifies RBIs are up-to-date without modifying existing RBIs."
      def dsl(*constants)
        Tapioca.silence_warnings do
          generator.build_dsl(constants, should_verify: options[:verify])
        end
      end

      desc "gems [GEM]...", "Generate RBIs for project Gem files."
      long_desc <<~DESCRIPTION
        Generate RBIs for project Gem files.

        # TODO
      DESCRIPTION
      def gems(*gems)
        Tapioca.silence_warnings do
          generator.build_gem_rbis(gems)
        end
      end

      desc :requires, "Auto-populate the sorbet/tapioca/require.rb file."
      long_desc <<~DESCRIPTION
        Auto-populate the sorbet/tapioca/require.rb file.

        # TODO
      DESCRIPTION
      def requires
        Tapioca.silence_warnings do
          generator.build_requires
        end
      end

      desc :todos, "Generate a list of unresolved constants."
      long_desc <<~DESCRIPTION
        Generate a list of unresolved constants.

        # TODO
      DESCRIPTION
      def todos
        Tapioca.silence_warnings do
          generator.build_todos
        end
      end

      private

      def generator
        current_command = T.must(current_command_chain.first)
        @generator ||= Generator.new(
          ConfigBuilder.from_options(current_command, options)
        )
      end

      no_commands do
        def self.exit_on_failure?
          true
        end
      end
    end
  end
end
