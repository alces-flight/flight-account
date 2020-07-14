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
require 'commander'
require 'alces/account/commands/account'
require 'alces/account/version'

module Alces
  module Account
    class CLI
      PROGRAM_NAME = ENV.fetch('FLIGHT_PROGRAM_NAME','account')

      extend Commander::CLI

      program :application, 'Flight Account'
      program :name, PROGRAM_NAME
      program :version, "v#{Alces::Account::VERSION}"
      program :description, 'Alces Flight platform account management.'
      program :help_paging, false
      default_command :help

      class << self
        def cli_syntax(command, args_str = nil)
          command.syntax = [
            PROGRAM_NAME,
            command.name,
            args_str
          ].compact.join(' ')
        end

        def run_account_method(m)
          Proc.new do |args, opts, config|
            Commands::Account.new.send(m, args, opts)
          end
        end
      end

      command :status do |c|
        cli_syntax(c)
        c.summary = 'Display your current login status'
        c.description = 'Display your current login status.'
        c.action run_account_method(:status)
      end

      command :get do |c|
        cli_syntax(c, '<username|email|auth_token|server>')
        c.summary = 'Get a configuration value from the config file.'
        c.description = 'Display your current login status.'
        c.description = "The `get` command can be used to print a configuration value in the config file."
        c.action run_account_method(:get)
      end

      command :login do |c|
        cli_syntax(c)
        c.summary = 'Log in to your Alces Flight account'
        c.description = 'Log in to your Alces Flight account.'
        c.action run_account_method(:login)
      end

      command :logout do |c|
        cli_syntax(c)
        c.summary = 'Log out of your Alces Flight account'
        c.description = 'Log out of your Alces Flight account.'
        c.action run_account_method(:logout)
      end

      # XXX Disable subscribe command.  It currently isn't fully implemented
      # and isn't needed for the initial release.
      # command :subscribe do |c|
      #   cli_syntax(c)
      #   c.summary = 'Create a new Alces Flight account'
      #   c.description = 'Create a new Alces Flight account.'
      #   c.action run_account_method(:subscribe)
      # end
    end
  end
end
