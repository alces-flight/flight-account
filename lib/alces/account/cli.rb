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
