module Ruboty
  module Handlers
    class Scorekeeper < Base
      NAMESPACE = "scorekeeper"

      on( /(?<name>.+[^+])\+\+$/,
        name: "increment",
        description: "Increment <name>'s point",
        all: true,
      )
      on( /(?<name>.+[^-])\-\-$/,
        name: "decrement",
        description: "Decrement <name>'s point",
        all: true,
      )

      on( /scorekeeper$|show(?: me)?(?: the)? (?:scorekeeper|scoreboard)$/i,
        name: "scoreboard",
        description: "Show scoreboard",
      )

      on( /scorekeeper (?<name>.+)$|what(?:'s| is)(?: the)? score of (?<name>.+)\??$/i,
        name: "score",
        description: "Show current point of <name>",
        missing: true
      )

      on( /scorekeeper delete (?<name>.+)/i,
        name: "delete",
        description: "Delete a point of <name>",
      )

      on( /scorekeeper merge (?<from_name>.+) with (?<to_name>.+)/i,
        name: "merge",
        description: "Merge a point of <from_name> with <to_name>",
      )
      private

      def increment(message)
        name = normalize_name(message[:name])
        point = scores[name].to_i + 1
        scores[name] = point
        message.reply("incremented #{name} (#{point} pt)")
      end

      def decrement(message)
        name = normalize_name(message[:name])
        point = scores[name].to_i - 1
        scores[name] = point
        message.reply("decremented #{name} (#{point} pt)")
      end

      def score(message)
        name = normalize_name(message[:name])
        point = scores[name]
        message.reply("#{name} has #{point} points")
      end

      def scoreboard(message)
        message.reply(
          scores.sort_by{|key, value|
            -value
          }.map.with_index(1){|data, index|
            "#{index} : #{data.first} (#{data.last} pt)"
          }.join("\n")
        )
      end

      def delete(message)
        name = normalize_name(message[:name])
        if scores.delete(name)
          message.reply("deleted a point of #{name}")
        else
          message.reply("#{name} is not found")
        end
      end

      def merge(message)
        from = normalize_name(message[:from_name])
        to   = normalize_name(message[:to_name])
        from_point = scores[from] || 0
        to_point   = scores[to] || 0

        scores[to] = to_point + from_point
        scores.delete(from)
        message.reply("Merge {from_point}pt of #{from} with #{to}")
      end

      def scores
        robot.brain.data[NAMESPACE] ||= {}
      end

      def normalize_name(name)
        name.strip.gsub(ignore_name_matcher,"")
      end

      def ignore_name_matcher
        /^@|:$/ # IRC, Hipchat, Slack
      end
    end
  end
end
