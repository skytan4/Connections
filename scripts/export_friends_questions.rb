#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

root = File.expand_path("..", __dir__)
source_path = File.join(root, "Connections", "Data", "prompts_en.json")
output_path = File.join(root, "docs", "friends-questions.md")

bank = JSON.parse(File.read(source_path))
prompts = bank.fetch("prompts").select { |prompt| prompt["mode"] == "friends" }

tone_order = %w[light honest unfiltered]
depth_order = %w[warmUp realTalk deepDive]
label = {
  "light" => "Light",
  "honest" => "Honest",
  "unfiltered" => "Unfiltered",
  "warmUp" => "Warm Up",
  "realTalk" => "Real Talk",
  "deepDive" => "Deep Dive",
  "dailyLife" => "Daily Life",
  "identity" => "Identity",
  "communication" => "Communication",
  "emotions" => "Emotions",
  "appreciation" => "Appreciation",
  "conflict" => "Conflict",
  "growth" => "Growth",
  "values" => "Values",
  "past" => "Past",
  "intimacy" => "Intimacy",
  "parenting" => "Parenting",
  "fallInLove" => "Fall in Love"
}

normalize = lambda do |text|
  text
    .downcase
    .tr("\u2018\u2019", "'")
    .tr("\u201c\u201d", '"')
    .gsub(/[^a-z0-9]+/, " ")
    .strip
end

duplicate_groups = prompts
  .group_by { |prompt| normalize.call(prompt.fetch("text")) }
  .values
  .select { |group| group.length > 1 }

lines = []
lines << "# Friends Questions"
lines << ""
lines << "Source: `Connections/Data/prompts_en.json`"
lines << "Generated: 2026-05-26"
lines << "Total Friends prompts: #{prompts.length}"
lines << "Exact normalized duplicate main questions found: #{duplicate_groups.length}"
lines << ""
lines << "Use this as the working list when adding new Friends prompts. The ID shows where each prompt currently lives in the app data."
lines << ""

if duplicate_groups.any?
  lines << "## Duplicate Main Questions"
  lines << ""
  duplicate_groups.each do |group|
    lines << "- #{group.first.fetch("text")}"
    group.each { |prompt| lines << "  - `#{prompt.fetch("id")}`" }
  end
  lines << ""
end

tone_order.each do |intensity|
  by_tone = prompts.select { |prompt| prompt["intensity"] == intensity }
  next if by_tone.empty?

  lines << "## #{label.fetch(intensity, intensity)}"
  lines << ""

  depth_order.each do |depth|
    by_depth = by_tone.select { |prompt| prompt["depth"] == depth }
    next if by_depth.empty?

    lines << "### #{label.fetch(depth, depth)}"
    lines << ""

    topics = by_depth
      .map { |prompt| prompt["topic"] }
      .uniq
      .sort_by { |topic| label.fetch(topic, topic) }

    topics.each do |topic|
      group = by_depth.select { |prompt| prompt["topic"] == topic }

      lines << "#### #{label.fetch(topic, topic)}"
      lines << ""

      group.each_with_index do |prompt, index|
        lines << "#{index + 1}. #{prompt.fetch("text")}"
        lines << "   - ID: `#{prompt.fetch("id")}`"

        follow_ups = prompt["followUps"] || []
        next if follow_ups.empty?

        lines << "   - Follow-ups:"
        follow_ups.each do |follow_up|
          lines << "     - #{follow_up.fetch("text")} (`#{follow_up.fetch("style")}`)"
        end
      end

      lines << ""
    end
  end
end

File.write(output_path, lines.join("\n"))
puts JSON.generate(outPath: output_path, count: prompts.length, duplicateGroups: duplicate_groups.length)
