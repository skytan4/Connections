#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "set"

ROOT = File.expand_path("..", __dir__)
DEFAULT_SOURCE = File.join(ROOT, "docs", "friends-new-prompts-staged.json")
METADATA_FIELDS = %w[id mode intensity depth topic].freeze

options = {
  source: DEFAULT_SOURCE,
  verbose: false
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/validate_friends_expansion_translation.rb --candidate PATH --locale LOCALE [options]"
  parser.on("--source PATH", "Staged English source (default: docs/friends-new-prompts-staged.json)") { |value| options[:source] = value }
  parser.on("--candidate PATH", "Translated staged JSON file") { |value| options[:candidate] = value }
  parser.on("--locale LOCALE", "Expected language field") { |value| options[:locale] = value }
  parser.on("--verbose", "Print passing summary details") { options[:verbose] = true }
end.parse!

abort "Missing --candidate" unless options[:candidate]
abort "Missing --locale" unless options[:locale]

def load_json(path)
  JSON.parse(File.read(path))
rescue Errno::ENOENT
  abort "File not found: #{path}"
rescue JSON::ParserError => e
  abort "Invalid JSON in #{path}: #{e.message}"
end

def prompts_from(data, path)
  prompts = data["prompts"]
  abort "#{path}: missing top-level prompts array" unless prompts.is_a?(Array)

  prompts
end

source_data = load_json(options.fetch(:source))
candidate_data = load_json(options.fetch(:candidate))
source_prompts = prompts_from(source_data, options.fetch(:source))
candidate_prompts = prompts_from(candidate_data, options.fetch(:candidate))
locale = options.fetch(:locale)

errors = []

if candidate_data["language"] != locale
  errors << "language field is #{candidate_data["language"].inspect}, expected #{locale.inspect}"
end

if candidate_prompts.length != source_prompts.length
  errors << "prompt count mismatch: expected #{source_prompts.length}, got #{candidate_prompts.length}"
end

source_ids = source_prompts.map { |prompt| prompt.fetch("id") }
candidate_ids = candidate_prompts.map { |prompt| prompt["id"] }

if candidate_ids != source_ids
  errors << "prompt IDs or order do not match staged English source"
  missing = source_ids - candidate_ids
  extra = candidate_ids - source_ids
  errors << "missing IDs: #{missing.join(", ")}" if missing.any?
  errors << "extra IDs: #{extra.join(", ")}" if extra.any?
end

if candidate_ids.length != candidate_ids.compact.uniq.length
  duplicates = candidate_ids.compact.tally.select { |_id, count| count > 1 }.keys
  errors << "duplicate candidate IDs: #{duplicates.join(", ")}"
end

source_by_id = source_prompts.to_h { |prompt| [prompt.fetch("id"), prompt] }

candidate_prompts.each_with_index do |candidate, index|
  id = candidate["id"]
  source = source_by_id[id]
  next unless source

  METADATA_FIELDS.each do |field|
    next if candidate[field] == source[field]

    errors << "#{id}: #{field} mismatch: expected #{source[field].inspect}, got #{candidate[field].inspect}"
  end

  text = candidate["text"].to_s
  errors << "#{id}: prompt text is empty" if text.strip.empty?
  errors << "#{id}: prompt text is still English" if text == source["text"]

  source_follow_ups = source.fetch("followUps")
  candidate_follow_ups = candidate["followUps"]
  unless candidate_follow_ups.is_a?(Array)
    errors << "#{id}: followUps is not an array"
    next
  end

  if candidate_follow_ups.length != source_follow_ups.length
    errors << "#{id}: follow-up count mismatch: expected #{source_follow_ups.length}, got #{candidate_follow_ups.length}"
    next
  end

  candidate_follow_ups.each_with_index do |candidate_fu, follow_index|
    source_fu = source_follow_ups.fetch(follow_index)
    fu_id = source_fu.fetch("id")

    if candidate_fu["id"] != fu_id
      errors << "#{id}: follow-up #{follow_index} id mismatch: expected #{fu_id.inspect}, got #{candidate_fu["id"].inspect}"
      next
    end

    if candidate_fu["style"] != source_fu["style"]
      errors << "#{id} / #{fu_id}: style mismatch: expected #{source_fu["style"].inspect}, got #{candidate_fu["style"].inspect}"
    end

    fu_text = candidate_fu["text"].to_s
    errors << "#{id} / #{fu_id}: follow-up text is empty" if fu_text.strip.empty?
    errors << "#{id} / #{fu_id}: follow-up text is still English" if fu_text == source_fu["text"]
  end
end

if errors.any?
  warn "\nValidation failed for #{options.fetch(:candidate)}:"
  errors.each { |error| warn "  - #{error}" }
  exit 1
end

puts "Validation passed: #{locale} #{candidate_prompts.length} prompts" if options.fetch(:verbose)
exit 0
