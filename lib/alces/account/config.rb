require 'xdg'
require 'yaml'

module Alces
  module Account
    module Config
      class << self
        include XDG::BaseDir::Mixin
        
        def root
          File.join(File.dirname(__FILE__),'..','..','..')
        end

        def method_missing(s,*a,&b)
          if data.key?(s)
            data[s]
          else
            super
          end
        end

        def respond_to_missing?(s)
          data.key?(s)
        end

        def sso_url
          ENV['cw_SSO_URL'] || data[:sso_url] || 'https://staging.accounts.alces-flight.com'
        end

        def auth_token
          data[:auth_token]
        end

        def set(key, value)
          if value
            data[key.to_sym] = value
          else
            data.delete(key.to_sym)
          end
          save
        end

        private
        def data
          @data ||= load
        end

        def subdirectory
          File.join('flight','accounts')
        end

        def load
          files = config.home.glob('config.yml')
          if files.first
            YAML.load_file(files.first)
          else
            {}
          end
        end

        def save
          unless Dir.exists?(config.home.to_s)
            Dir.mkdir(config.home.to_s, 0700)
          end
          File.write(config_file, data.to_yaml)
          File.chmod(0600, config_file)  # File may contain auth token so should not be world-readable!
        end

        def config_file
          File.join(config.home.to_s,'config.yml')
        end
      end
    end
  end
end
