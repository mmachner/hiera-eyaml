require 'rubygems'

class Hiera
  module Backend
    module Eyaml
      class Plugins

        @@plugins = []
        @@commands = []
        @@options = []

        def self.register_options args
          options = args[ :options ]
          plugin = args[ :plugin ]
          options.each do |name, option_hash|
            new_option = {:name => "#{plugin}_#{name}"}
            new_option.merge! option_hash
            @@options << new_option
          end
        end

        def self.options
          @@options
        end

        def self.find

          gem_version = Gem::Version.new(Gem::VERSION)
          this_version = Gem::Version.create(Hiera::Backend::Eyaml::VERSION)
          index = gem_version >= Gem::Version.new("1.8.0") ? Gem::Specification : Gem.source_index

          [index].flatten.each do |source|
            specs = gem_version >= Gem::Version.new("1.6.0") ? source.latest_specs(true) : source.latest_specs

            specs.each do |spec|
              spec = spec.to_spec if spec.respond_to?(:to_spec)
              next if @@plugins.include? spec

              dependency = spec.dependencies.find { |d| d.name == "hiera-eyaml" }
              next if dependency && !dependency.requirement.satisfied_by?( this_version )

              file = nil
              if gem_version >= Gem::Version.new("1.8.0")
                file = spec.matches_for_glob("**/eyaml_init.rb").first
              else
                file = Gem.searcher.matching_files(spec, "**/eyaml_init.rb").first
              end

              next unless file

              @@plugins << spec
              load file
            end

          end

          @@plugins

        end

        def self.plugins
          @@plugins
        end

        def self.commands
          @@commands
        end

      end
    end
  end
end
