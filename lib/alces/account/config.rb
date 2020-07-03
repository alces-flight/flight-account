#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Account.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Account is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Account. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Account, please visit:
# https://github.com/alces-flight/flight-account
#==============================================================================
require 'xdg'
require 'yaml'
require 'fileutils'
require 'etc'

module Alces
  module Account
    module Config
      class << self

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
          ENV['flight_SSO_URL'] ||
            data[:sso_url] ||
            # 'http://accounts.alces-flight.lvh.me:4000'
            # 'https://staging.accounts.alces-flight.com'
            'https://accounts.alces-flight.com'
        end

        def auth_token
          data[:auth_token]
        end

        def email
          data[:auth_email]
        end

        def username
          data[:auth_user] || Etc.getlogin
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
          if File.exists?(config_file)
            YAML.load_file(config_file)
          else
            {}
          end
        end

        def save
          unless Dir.exists?(config_dir)
            FileUtils.mkdir_p(config_dir, mode: 0700)
          end
          File.write(config_file, data.to_yaml)
          # File may contain auth token so should not be world-readable!
          File.chmod(0600, config_file)
        end

        def config_file
          File.join(config_dir, 'config.yml')
        end

        def config_dir
          @xdg ||= XDG::Environment.new
          File.join(@xdg.config_home, subdirectory)
        end
      end
    end
  end
end
