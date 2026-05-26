#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "set"

ROOT = File.expand_path("..", __dir__)
SOURCE_PATH = File.join(ROOT, "Connections", "Data", "prompts_en.json")
DRAFT_PATH = File.join(ROOT, "docs", "friends-new-prompts.md")
OUT_JSON = File.join(ROOT, "docs", "friends-new-prompts-staged.json")
OUT_MD = File.join(ROOT, "docs", "friends-new-prompts-staged.md")

TOPIC_CODES = {
  "Appreciation" => "appreciation",
  "Communication" => "communication",
  "Conflict" => "conflict",
  "Daily Life" => "dailyLife",
  "Emotions" => "emotions",
  "Growth" => "growth",
  "Identity" => "identity",
  "Intimacy" => "intimacy",
  "Past" => "past",
  "Values" => "values"
}.freeze

INTENSITY_CODES = {
  "Light" => "light",
  "Honest" => "honest",
  "Unfiltered" => "unfiltered"
}.freeze

DEPTH_LABELS = {
  "warmUp" => "Warm Up",
  "realTalk" => "Real Talk",
  "deepDive" => "Deep Dive"
}.freeze

DEPTH_PLANS = {
  ["light", "appreciation"] => %w[warmUp realTalk deepDive],
  ["light", "communication"] => %w[warmUp realTalk realTalk realTalk deepDive deepDive deepDive warmUp realTalk],
  ["light", "conflict"] => %w[warmUp warmUp warmUp realTalk realTalk realTalk deepDive deepDive deepDive],
  ["light", "emotions"] => %w[warmUp warmUp warmUp realTalk realTalk realTalk deepDive deepDive deepDive],
  ["light", "growth"] => %w[warmUp warmUp realTalk realTalk deepDive deepDive realTalk],
  ["light", "identity"] => %w[warmUp realTalk deepDive],
  ["light", "intimacy"] => %w[warmUp warmUp realTalk realTalk realTalk deepDive deepDive deepDive deepDive],
  ["light", "past"] => %w[warmUp warmUp warmUp realTalk realTalk realTalk deepDive deepDive deepDive deepDive],
  ["light", "values"] => %w[warmUp realTalk deepDive deepDive],

  ["honest", "appreciation"] => %w[warmUp warmUp realTalk realTalk realTalk deepDive deepDive],
  ["honest", "communication"] => %w[realTalk realTalk deepDive],
  ["honest", "conflict"] => %w[deepDive],
  ["honest", "dailyLife"] => %w[warmUp warmUp realTalk realTalk realTalk deepDive deepDive],
  ["honest", "emotions"] => %w[warmUp realTalk realTalk deepDive deepDive deepDive],
  ["honest", "growth"] => %w[warmUp realTalk realTalk realTalk deepDive deepDive deepDive deepDive],
  ["honest", "identity"] => %w[warmUp realTalk realTalk deepDive deepDive deepDive],
  ["honest", "intimacy"] => %w[realTalk realTalk deepDive deepDive deepDive deepDive],
  ["honest", "past"] => %w[warmUp realTalk realTalk deepDive deepDive deepDive deepDive deepDive],
  ["honest", "values"] => %w[warmUp realTalk realTalk deepDive deepDive deepDive deepDive deepDive],

  ["unfiltered", "appreciation"] => %w[warmUp warmUp warmUp realTalk realTalk realTalk deepDive deepDive deepDive deepDive],
  ["unfiltered", "communication"] => %w[warmUp warmUp realTalk realTalk realTalk deepDive deepDive deepDive],
  ["unfiltered", "dailyLife"] => %w[warmUp realTalk realTalk realTalk deepDive deepDive deepDive],
  ["unfiltered", "emotions"] => %w[deepDive],
  ["unfiltered", "growth"] => %w[warmUp warmUp realTalk realTalk realTalk deepDive deepDive deepDive],
  ["unfiltered", "identity"] => %w[warmUp realTalk realTalk deepDive deepDive deepDive deepDive],
  ["unfiltered", "intimacy"] => %w[warmUp realTalk realTalk deepDive deepDive deepDive deepDive],
  ["unfiltered", "past"] => %w[warmUp warmUp realTalk realTalk realTalk deepDive deepDive deepDive],
  ["unfiltered", "values"] => %w[warmUp realTalk deepDive]
}.freeze

def next_id(existing, mode, intensity, depth, topic)
  prefix = "p_#{mode}_#{intensity}_#{depth}_#{topic}_"
  max = existing
    .grep(/^#{Regexp.escape(prefix)}\d{3}$/)
    .map { |id| id.delete_prefix(prefix).to_i }
    .max || 0

  format("%<prefix>s%<n>03d", prefix: prefix, n: max + 1)
end

def duplicate_key(text)
  text
    .downcase
    .tr("\u2018\u2019", "'")
    .tr("\u201c\u201d", '"')
    .gsub(/[^a-z0-9]+/, " ")
    .strip
end

source = JSON.parse(File.read(SOURCE_PATH))
existing_ids = source.fetch("prompts").map { |prompt| prompt.fetch("id") }
existing_text_keys = source
  .fetch("prompts")
  .select { |prompt| prompt["mode"] == "friends" }
  .map { |prompt| duplicate_key(prompt.fetch("text")) }
  .to_set

drafts = []
current_intensity = nil
current_topic = nil
current_prompt = nil
current_follow_ups = nil

File.readlines(DRAFT_PATH, chomp: true).each do |line|
  if line.start_with?("## ")
    current_intensity = INTENSITY_CODES[line.delete_prefix("## ").strip]
  elsif line.start_with?("### ")
    current_topic = TOPIC_CODES[line.delete_prefix("### ").strip]
  elsif line.start_with?("- ")
    next unless current_intensity && current_topic

    text = line.delete_prefix("- ").strip
    next if text.empty?

    current_prompt = {
      "text" => text,
      "mode" => "friends",
      "intensity" => current_intensity,
      "topic" => current_topic,
      "followUps" => []
    }
    drafts << current_prompt
  elsif line.start_with?("    - ") && current_prompt
    text = line.sub(/\s*\(`(origin|impact)`\)\s*$/, "").strip.delete_prefix("- ").strip
    style = line[/`(origin|impact)`/, 1]
    current_prompt.fetch("followUps") << { "text" => text, "style" => style }
  end
end

raise "No drafts parsed" if drafts.empty?

missing_metadata = drafts.select { |prompt| prompt["intensity"].nil? || prompt["topic"].nil? }
raise "Missing metadata for #{missing_metadata.length} drafts" if missing_metadata.any?

internal_dups = drafts.group_by { |prompt| duplicate_key(prompt.fetch("text")) }.values.select { |group| group.length > 1 }
raise "Internal duplicate draft prompts: #{internal_dups.map { |group| group.first["text"] }.join(", ")}" if internal_dups.any?

existing_dups = drafts.select { |prompt| existing_text_keys.include?(duplicate_key(prompt.fetch("text"))) }
raise "Drafts duplicate existing Friends prompts: #{existing_dups.map { |prompt| prompt["text"] }.join(", ")}" if existing_dups.any?

depth_indices = Hash.new(0)
staged = drafts.map do |prompt|
  key = [prompt.fetch("intensity"), prompt.fetch("topic")]
  plan = DEPTH_PLANS.fetch(key) { raise "No depth plan for #{key.inspect}" }
  depth = plan.fetch(depth_indices[key]) { raise "Depth plan exhausted for #{key.inspect}" }
  depth_indices[key] += 1

  id = next_id(existing_ids, "friends", prompt.fetch("intensity"), depth, prompt.fetch("topic"))
  existing_ids << id

  follow_ups = prompt.fetch("followUps")
  raise "#{prompt["text"]}: expected 2 follow-ups, got #{follow_ups.length}" unless follow_ups.length == 2

  {
    "id" => id,
    "text" => prompt.fetch("text"),
    "mode" => "friends",
    "intensity" => prompt.fetch("intensity"),
    "depth" => depth,
    "topic" => prompt.fetch("topic"),
    "followUps" => follow_ups.each_with_index.map do |follow_up, index|
      {
        "id" => "#{id}_fu_#{index + 1}",
        "text" => follow_up.fetch("text"),
        "style" => follow_up.fetch("style")
      }
    end
  }
end

File.write(OUT_JSON, JSON.pretty_generate({ "prompts" => staged }) + "\n")

md = []
md << "# Staged Friends Prompt Additions"
md << ""
md << "Generated from `docs/friends-new-prompts.md`."
md << ""
md << "Total staged prompts: #{staged.length}"
md << ""

staged.group_by { |prompt| [prompt["intensity"], prompt["depth"], prompt["topic"]] }.each do |(intensity, depth, topic), group|
  md << "## #{intensity} / #{DEPTH_LABELS.fetch(depth)} / #{topic}"
  md << ""
  group.each do |prompt|
    md << "- `#{prompt["id"]}` #{prompt["text"]}"
    prompt.fetch("followUps").each do |follow_up|
      md << "  - #{follow_up["text"]} (`#{follow_up["style"]}`)"
    end
  end
  md << ""
end

File.write(OUT_MD, md.join("\n"))
puts JSON.generate(json: OUT_JSON, markdown: OUT_MD, count: staged.length)
