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

require 'commander/no-global-highline'
require 'alces/account/commands/account'

module Alces
  module Account
    class CLI
      include Commander::Methods

      def run
        program :name, 'alces account'
        program :version, '0.0.1'
        program :description, 'Alces Flight platform account management'

        command :status do |c|
          c.syntax = 'account status'
          c.summary = 'Shows the current account information'
          c.action Commands::Account, :status
        end

        command :login do |c|
          c.syntax = 'account login'
          c.summary = 'Log in to your Alces Flight account'
          c.description = 'Log in to your Alces Flight account.'
          c.action Commands::Account, :login
        end

        command :logout do |c|
          c.syntax = 'account logout'
          c.summary = 'Log out of your Alces Flight account'
          c.description = 'Log out of your Alces Flight account.'
          c.action Commands::Account, :logout
        end

        command :subscribe do |c|
          c.syntax = 'account subscribe'
          c.summary = 'Create a new Alces Flight account'
          c.description = 'Create a new Alces Flight account.'
          c.action Commands::Account, :subscribe
        end

        run!
      end
    end
  end
end
