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
#==============================================================================

require 'commander'
require 'alces/account/commands/account'
require 'alces/account/version'

module Alces
  module Account
    class CLI
      PROGRAM_NAME = ENV.fetch('FLIGHT_PROGRAM_NAME','account')

      extend Commander::Delegates
      program :application, Alces::Account::TITLE
      program :name, PROGRAM_NAME
      program :version, Alces::Account::RELEASE
      program :description, 'Alces Flight platform account management.'
      program :help_paging, false
      default_command :help
      silent_trace!

      class << self
        def cli_syntax(command, args_str = nil)
          command.syntax = [
            PROGRAM_NAME,
            command.name,
            args_str
          ].compact.join(' ')
        end
      end

      command :status do |c|
        cli_syntax(c)
        c.summary = 'Display your current login status'
        c.description = 'Display your current login status.'
        c.action Commands::Account, :status
      end

      command :login do |c|
        cli_syntax(c)
        c.summary = 'Log in to your Alces Flight account'
        c.description = 'Log in to your Alces Flight account.'
        c.action Commands::Account, :login
      end

      command :logout do |c|
        cli_syntax(c)
        c.summary = 'Log out of your Alces Flight account'
        c.description = 'Log out of your Alces Flight account.'
        c.action Commands::Account, :logout
      end

      command :subscribe do |c|
        cli_syntax(c)
        c.summary = 'Create a new Alces Flight account'
        c.description = 'Create a new Alces Flight account.'
        c.action Commands::Account, :subscribe
      end
    end
  end
end
