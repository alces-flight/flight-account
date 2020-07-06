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
require 'alces/account/api'
require 'alces/account/banner'
require 'alces/account/config'
require 'alces/account/errors'
require 'whirly'
require 'tty-prompt'
require 'tty-pager'
require 'tty-table'
require 'html2text'
require 'word_wrap'
require 'open-uri'
require 'zxcvbn'

module Alces
  module Account
    module Commands
      class Account
        def status(args, options)
          Alces::Account::Banner.emit
          table = TTY::Table.new
          table << ['Account Server', Config.sso_url.sub(/https?:\/\//, '')]
          if Config.auth_token
            table << ['Username', Config.username]
            table << ['Email', Config.email]
          end
          klass = Class.new(TTY::Table::Border) do
            def_border do
              center ': '
            end
          end
          puts table.render_with(klass, alignments: [:right, :left] )
          if !Config.auth_token
            prompt.say Paint%["\nYou are currently %{logged_out} of the Alces Flight platform.\n", '#2794d8', logged_out: ['logged out', '#57c4f8']]
          end
        end

        def get(args, options)
          Alces::Account::Banner.emit if $stdout.tty?
          key = args.first
          puts Config.get(key.downcase)
        end

        def subscribe(args, options)
          if Config.auth_token
            prompt.warn "You are currently logged in to the Alces Flight platform as #{Paint[Config.username, :yellow, :bright]}."
            return
          end
          Alces::Account::Banner.emit
          prompt.say Paint[WordWrap.ww("To sign up for your Alces Flight account please enter your username, email address and password and agree to the privacy policy and terms of service.", 70), '#2794d8']
          username = prompt.ask(sprintf('%20s','Username:'), default: Config.username)
          email = prompt.ask(sprintf('%20s','Email address:')) do |q|
            q.validate(:email, 'Invalid email address')
          end
          password = prompt.mask(sprintf('%20s','Password:')) do |q|
            q.validate( lambda do |a|
                          a.match(/.{8}/) &&
                            Zxcvbn.test(a, [username, email]).score >= 2
                        end, 'Unacceptable password (must be at least 8 chars and not too weak)')
          end
          confirm = prompt.mask(sprintf('%20s','Confirm password:')) do |q|
            q.validate(->(a){a == password}, 'Confirmation must match password')
          end
          prompt.say "\n"
          if agree_tos
            prompt.say "\n"
            spam_friendly = agree_mkting
            begin
              values = {
                username: username,
                password: password,
                email: email,
                terms: true,
                opted_into_marketing: spam_friendly,
              }
              Whirly.start(spinner: 'star',
                           remove_after_stop: true,
                           append_newline: false,
                           status: Paint['Signing you up', '#2794d8']) do
                nil #api.signup(values)
              end
            rescue AccountEmailError
              prompt.error "Email address already in use."
              email = prompt.ask(sprintf('%20s','Email address:')) do |q|
                q.validate(:email, 'Invalid email address')
              end
              retry
            rescue AccountUsernameError
              prompt.error "Username already in use."
              username = prompt.ask(sprintf('%20s','Username:'), default: Config.username)
              retry
            end

            prompt.say Paint%[
                         "\nThanks for subscribing!\n\nA confirmation email "\
                         "has been sent to:\n\n  %{email}\n",
                         '#2794d8',
                         email: [email, :bright, :yellow]
                       ]
            prompt.say Paint%[
                         WordWrap.ww(
                           "Please check your inbox and follow the "\
                           "link in the email to confirm your account.  "\
                           "Once confirmed you can use the %{alcesflightlogin} "\
                           "command to log in to your Alces Flight "\
                           "platform account.",
                           70
                         ),
                         '#2794d8',
                         alcesflightlogin: ["[37;1m`[48;5;68malces flight login[49m`[0m", :white]
                       ]
          end
        rescue TTY::Reader::InputInterrupt
          nil
        end

        def agree_mkting
          prompt.say 'Do you wish to receive marketing information from Alces Flight?'
          prompt.say Paint[
                       WordWrap.ww(
                         'The information you provide may be used to keep you '\
                         "informed about our future products and events.\n",
                         70
                       ),
                       :black
                     ]
          # Confusingly the tty-prompt API returns "No" as "True" from #no?
          # We could use #yes? instead, but then it defaults to "Yes"
          # which isn't what we want to be GDPR-friendly :rolleyes:
          !prompt.no?("Would you like to opt-in?")
        end
        
        def agree_tos
          prompt.say "Do you agree to the Alces Flight website Privacy Policy and Terms of Service?\n\n"
          agree = prompt.expand('(Y)es/(N)o/View (T)erms/View (P)rivacy Policy?') do |q|
            q.choice key: 'y', name: 'Yes, I agree', value: :yes
            q.choice key: 'n', name: "No, I don't agree", value: :no
            q.choice key: 't', name: 'View Terms of Service', value: :view_tos
            q.choice key: 'p', name: 'View Privacy Policy', value: :view_pp
          end
          case agree
          when :view_tos
            display_terms
          when :view_pp
            display_privacy_policy
          when :yes
            return true
          else
            return false
          end
          raise RetryAgreement.new
        rescue RetryAgreement
          retry
        end
        
        def login(args, options)
          if Config.auth_token
            prompt.warn "You are currently logged in to the Alces Flight platform as #{Paint[Config.username, :yellow, :bright]}."
            return
          end
          Alces::Account::Banner.emit
          username = if args[0].nil?
                       prompt.say Paint["To sign in to your Alces Flight account please enter your username and\npassword.\n", '#2794d8']
                       prompt.ask('Username:', default: Config.username)
                     else
                       prompt.say Paint["To sign in to your Alces Flight account please enter your password.\n", '#2794d8']
                       args[0]
                     end
          password = prompt.mask('Password:')

          login = nil
          
          Whirly.start(spinner: 'star',
                       remove_after_stop: true,
                       append_newline: false,
                       status: Paint['Logging you in', '#2794d8']) do
            login = api.login(username, password)
          end
          token = login['authentication_token']
          email = login['email']

          Config.set(:sso_url, Config.sso_url)
          Config.set(:auth_token, token)
          Config.set(:auth_user, username)
          Config.set(:auth_email, email)

          prompt.say Paint["\nYou are now logged in to the Alces Flight plaform.", '#2794d8']
        rescue AccountError
          prompt.error "Log in failed: #{$!.message}"
          prompt.warn WordWrap.ww(
                        "If you've forgotten your password, "\
                        "please visit https://alces-flight.com "\
                        "to recover your account.",
                        70
                      )
        rescue TTY::Reader::InputInterrupt
          nil
        end

        def logout(args, options)
          if Config.auth_token
            Config.set(:auth_token, nil)
            Config.set(:sso_url, nil)
          end
          prompt.say Paint["You are now logged out of the Alces Flight platform.", '#2794d8']
        end

        private
        def api
          @api ||= API.new
        end

        def prompt
          @prompt ||= TTY::Prompt.new(help_color: :cyan)
        end

        def display_flight_url(url, marker)
          content = ""
          process = false
          Html2Text.convert(open(url).read).split("\n").each do |l|
            if l == marker
              process = true
            elsif l == 'Compute'
              process = false
            end
            content << (l.length > 70 ? WordWrap.ww(l, 70) : l ) << "\n" if process
          end
          TTY::Pager.new.page(content)
        end

        def display_privacy_policy
          display_flight_url('https://alces-flight.com/privacy', 'Privacy policy.')
        end
        
        def display_terms
          display_flight_url('https://alces-flight.com/terms', 'Terms of service.')
        end
      end
    end
  end
end
