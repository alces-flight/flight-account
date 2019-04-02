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

require 'http'
require 'json'
require 'alces/account/errors'

module Alces
  module Account
    class API
      def login(username, password)
        sso_base_url = Config.sso_url.chomp('/')

        response = http.post(
          "#{sso_base_url}/sign-in",
          params: {
            permanent: 1
          },
          json: {
            account: {
              username: username,
              password: password
            }
          }
        )

        if !response.status.success?
          data = (JSON.parse(response) rescue {})
          if data.key?('error')
            raise AccountError, data['error']
          else
            raise AccountError, response.to_s
          end
        else
          JSON.parse(response.to_s)['user']
        end
      end

      def signup(values)
        sso_base_url = Config.sso_url.chomp('/')
        response = http.post(
          "#{sso_base_url}/sign-up",
          json: {
            account: values
          }
        )

        if !response.status.success?
          data = (JSON.parse(response) rescue {})
          if errors = data['errors']
            if errors.key?('username')
              raise AccountUsernameError
            elsif errors.key?('email')
              raise AccountEmailError
            else
              raise AccountError, (errors.map do |k,v|
                                 "#{k} #{v.join}"
                               end.join("; "))
            end
          else
            raise AccountError, response.to_s
          end
        else
          JSON.parse(response.to_s)
        end
      end
      
      private

      def http
        h = HTTP.headers(
          user_agent: 'Flight-Account/0.0.1',
          accept: 'application/json'
        )
#        if Config.auth_token
#          h.auth("Bearer #{Config.auth_token}")
#        else
          h
#        end
      end
    end
  end
end
