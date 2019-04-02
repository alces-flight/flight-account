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

require 'tty-prompt'
require 'paint'

module Alces
  module Pretty
    class << self
      def banner(title, version)
          s = <<EOF

  'o`
 'ooo`               %{title}
 `oooo`              %{version}
  `oooo`         'o`
    `ooooo`  `ooooo
       `oooo:oooo`
          `v  -[ %{alces} %{flight} ]-
EOF
          prompt.say Paint%[s,
                            38, 5, 68, 49, 1,
                     title: [sprintf('%40s',title), 1, 38, 5, 15],
                     version: [sprintf('%40s',version), 1, 38, 5, 15],
                     alces: ['alces', 1, 38, 5, 249],
                     flight: ['flight', 1, 38, 5, 15]
                    ]
        end

      def command(name)
        Paint['`', 37, 1] <<
          Paint[name, 37, 1, 48, 5, 68] <<
          Paint['`', 37, 1]
      end

      private
      def prompt
        @prompt ||= TTY::Prompt.new(help_color: :cyan)
      end
    end
  end
end
