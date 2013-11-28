require 'hiera/backend/eyaml/subcommand'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'

class Hiera
  module Backend
    module Eyaml
      module Subcommands

        class Recrypt < Subcommand

          def self.options
            []
          end

          def self.description
            "recrypt an eyaml file"
          end

          def self.validate options
            if ARGV.empty?
              Trollop::die "You must specify an eyaml file" unless options[:eyaml]
              options[:source] = :eyaml
              options[:input_data] = File.read options[:eyaml]
            else
              Trollop::die "You cannot specify --eyaml, and an eyaml file as an argument" if options[:eyaml]
              options[:source] = :eyaml
              options[:eyaml] = ARGV.shift
              options[:input_data] = File.read options[:eyaml]
            end
            options
          end

          def self.execute 

            encrypted_parser = Parser::ParserFactory.encrypted_parser
            tokens = encrypted_parser.parse Eyaml::Options[:input_data]
            decrypted_input = tokens.each_with_index.to_a.map{|(t,index)| t.to_decrypted :index => index}.join

            decrypted_parser = Parser::ParserFactory.decrypted_parser
            edited_tokens = decrypted_parser.parse(decrypted_input)

            encrypted_output = edited_tokens.map{ |t| t.to_encrypted }.join

            filename = Eyaml::Options[:eyaml]
            File.open("#{filename}", 'w') { |file|
              file.write encrypted_output
            }

            nil
          end

        end

      end
    end
  end
end
