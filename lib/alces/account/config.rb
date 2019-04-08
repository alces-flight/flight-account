#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of flight-account.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# This project is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with this project. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on flight-account, please visit:
# https://github.com/alces-software/flight-account
#===============================================================================

require 'etc'
require 'flight_config'

module Alces
  module Account
    class Config
      include FlightConfig::Updater

      class << self
        def cache
          @cache ||= read
        end

        def method_missing(s, *a, &b)
          if respond_to_missing?(s) == :account_config_method
            cache.send(s, *a, &b)
          else
            super
          end
        end

        def respond_to_missing?(s, **k)
          if cache.respond_to?(s, **k)
            :account_config_method
          else
            super
          end
        end
      end

      allow_missing_read

      def __data__initialize(data)
        data.set_from_env(:sso_url) { 'cw_SSO_URL' }
      end

      def root
        File.join(File.dirname(__FILE__),'..','..','..')
      end

      def sso_url
        __data__.fetch(:sso_url, default: 'https://accounts.alces-flight.com')
      end

      def auth_user
        __data__.fetch(:auth_user)
      end

      def auth_token
        __data__.fetch(:auth_token)
      end

      def username
        __data__.fetch(:auth_user, default: Etc.getlogin)
      end

      def set(method, value)
        if value
          __data__.set(method, value: value)
        else
          __data__.delete(method)
        end
      end

      def path
        File.expand_path('~/.config/flight/accounts/config.yml')
      end
    end
  end
end
