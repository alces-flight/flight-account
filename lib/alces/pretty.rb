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
