#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "set"

ROOT = File.expand_path("..", __dir__)
DEFAULT_SOURCE = File.join(ROOT, "docs", "friends-new-prompts-staged.json")
DEFAULT_TRANSLATIONS_ROOT = "/tmp/friends_expansion_translation_packets"
DEFAULT_CANDIDATE_NAME = "translated.json"
LOCALES = %w[da de es fi fr it ja nb nl pl pt-BR ru sv zh-Hans].freeze

options = {
  source: DEFAULT_SOURCE,
  translations_root: DEFAULT_TRANSLATIONS_ROOT,
  candidate_name: DEFAULT_CANDIDATE_NAME,
  locales: LOCALES,
  apply: false
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/merge_friends_expansion_translations.rb [options]"
  parser.on("--source PATH", "Staged English source (default: docs/friends-new-prompts-staged.json)") { |value| options[:source] = value }
  parser.on("--translations-root PATH", "Root containing <locale>/<candidate-name> files") { |value| options[:translations_root] = value }
  parser.on("--candidate-name NAME", "Candidate filename inside each locale directory (default: translated.json)") { |value| options[:candidate_name] = value }
  parser.on("--locales LIST", "Comma-separated locales to merge") { |value| options[:locales] = value.split(",").map(&:strip) }
  parser.on("--apply", "Write prompt bank files. Without this, dry-run only.") { options[:apply] = true }
end.parse!

unknown_locales = options.fetch(:locales) - LOCALES
abort "Unknown locales: #{unknown_locales.join(", ")}" if unknown_locales.any?

def load_json(path)
  JSON.parse(File.read(path))
rescue Errno::ENOENT
  abort "File not found: #{path}"
rescue JSON::ParserError => e
  abort "Invalid JSON in #{path}: #{e.message}"
end

def write_json(path, data)
  File.write(path, JSON.pretty_generate(data) + "\n")
end

def validate_translation!(source_prompts, candidate_data, locale, candidate_path)
  errors = []
  candidate_prompts = candidate_data["prompts"]

  errors << "language field is #{candidate_data["language"].inspect}, expected #{locale.inspect}" unless candidate_data["language"] == locale
  errors << "missing prompts array" unless candidate_prompts.is_a?(Array)
  return errors unless candidate_prompts.is_a?(Array)

  source_ids = source_prompts.map { |prompt| prompt.fetch("id") }
  candidate_ids = candidate_prompts.map { |prompt| prompt["id"] }

  errors << "prompt count mismatch: expected #{source_prompts.length}, got #{candidate_prompts.length}" unless candidate_prompts.length == source_prompts.length
  errors << "prompt IDs/order mismatch" unless candidate_ids == source_ids

  source_prompts.zip(candidate_prompts).each do |source, candidate|
    next unless source && candidate

    id = source.fetch("id")
    %w[id mode intensity depth topic].each do |field|
      errors << "#{id}: #{field} mismatch" unless candidate[field] == source[field]
    end

    errors << "#{id}: empty translated text" if candidate["text"].to_s.strip.empty?
    errors << "#{id}: text is still English" if candidate["text"] == source["text"]

    source_follow_ups = source.fetch("followUps")
    candidate_follow_ups = candidate["followUps"]
    unless candidate_follow_ups.is_a?(Array) && candidate_follow_ups.length == source_follow_ups.length
      errors << "#{id}: follow-up count mismatch"
      next
    end

    source_follow_ups.zip(candidate_follow_ups).each do |source_fu, candidate_fu|
      fu_id = source_fu.fetch("id")
      errors << "#{id} / #{fu_id}: follow-up id mismatch" unless candidate_fu["id"] == fu_id
      errors << "#{id} / #{fu_id}: follow-up style mismatch" unless candidate_fu["style"] == source_fu["style"]
      errors << "#{id} / #{fu_id}: empty translated follow-up" if candidate_fu["text"].to_s.strip.empty?
      errors << "#{id} / #{fu_id}: follow-up is still English" if candidate_fu["text"] == source_fu["text"]
    end
  end

  errors.map { |error| "#{candidate_path}: #{error}" }
end

source_prompts = load_json(options.fetch(:source)).fetch("prompts")
source_ids = source_prompts.map { |prompt| prompt.fetch("id") }

candidate_by_locale = {}
errors = []

options.fetch(:locales).each do |locale|
  candidate_path = File.join(options.fetch(:translations_root), locale, options.fetch(:candidate_name))
  candidate_data = load_json(candidate_path)
  errors.concat(validate_translation!(source_prompts, candidate_data, locale, candidate_path))
  candidate_by_locale[locale] = candidate_data
end

if errors.any?
  warn "\nMerge preflight failed:"
  errors.each { |error| warn "  - #{error}" }
  exit 1
end

targets = { "en" => { path: File.join(ROOT, "Connections", "Data", "prompts_en.json"), additions: source_prompts } }
candidate_by_locale.each do |locale, data|
  targets[locale] = {
    path: File.join(ROOT, "Connections", "Data", "prompts_#{locale}.json"),
    additions: data.fetch("prompts")
  }
end

targets.each do |locale, target|
  bank = load_json(target.fetch(:path))
  bank_ids = bank.fetch("prompts").map { |prompt| prompt.fetch("id") }
  collisions = source_ids & bank_ids
  if collisions.any?
    abort "#{target.fetch(:path)} already contains staged IDs: #{collisions.first(5).join(", ")}"
  end

  puts "#{options.fetch(:apply) ? "Merging" : "Would merge"} #{target.fetch(:additions).length} prompts into #{target.fetch(:path)}"

  next unless options.fetch(:apply)

  bank.fetch("prompts").concat(target.fetch(:additions))
  write_json(target.fetch(:path), bank)
end

unless options.fetch(:apply)
  puts "\nDry-run only. Re-run with --apply after all translation files are final."
end
