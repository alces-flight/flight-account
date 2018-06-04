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
          JSON.parse(response.to_s)['user']['authentication_token']
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
