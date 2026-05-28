#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"

ROOT = File.expand_path("..", __dir__)
DEFAULT_SOURCE = File.join(ROOT, "docs", "friends-new-prompts-staged.json")
DEFAULT_PACKETS_ROOT = "/tmp/friends_expansion_translation_packets"

options = {
  source: DEFAULT_SOURCE,
  packets_root: DEFAULT_PACKETS_ROOT
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/assemble_friends_expansion_translation.rb --locale LOCALE [options]"
  parser.on("--source PATH", "Staged English source (default: docs/friends-new-prompts-staged.json)") { |value| options[:source] = value }
  parser.on("--packets-root PATH", "Translation packet root (default: /tmp/friends_expansion_translation_packets)") { |value| options[:packets_root] = value }
  parser.on("--locale LOCALE", "Locale to assemble") { |value| options[:locale] = value }
end.parse!

abort "Missing --locale" unless options[:locale]

def load_json(path)
  JSON.parse(File.read(path))
rescue Errno::ENOENT
  abort "File not found: #{path}"
rescue JSON::ParserError => e
  abort "Invalid JSON in #{path}: #{e.message}"
end

source_prompts = load_json(options.fetch(:source)).fetch("prompts")
source_ids = source_prompts.map { |prompt| prompt.fetch("id") }
locale = options.fetch(:locale)
locale_dir = File.join(options.fetch(:packets_root), locale)
abort "Locale packet directory not found: #{locale_dir}" unless Dir.exist?(locale_dir)

batch_dirs = Dir[File.join(locale_dir, "batch_*")].sort
abort "No batch directories found in #{locale_dir}" if batch_dirs.empty?

assembled_prompts = []
batch_dirs.each_with_index do |batch_dir, index|
  path = File.join(batch_dir, "translated.json")
  data = load_json(path)

  unless data["language"] == locale
    abort "#{path}: language is #{data["language"].inspect}, expected #{locale.inspect}"
  end

  prompts = data["prompts"]
  abort "#{path}: missing prompts array" unless prompts.is_a?(Array)

  assembled_prompts.concat(prompts)
  puts "Read batch #{index + 1}: #{prompts.length} prompts"
end

assembled_ids = assembled_prompts.map { |prompt| prompt["id"] }
unless assembled_ids == source_ids
  missing = source_ids - assembled_ids
  extra = assembled_ids - source_ids
  abort [
    "#{locale}: assembled IDs/order do not match staged source",
    ("missing: #{missing.first(10).join(", ")}" if missing.any?),
    ("extra: #{extra.first(10).join(", ")}" if extra.any?)
  ].compact.join("\n")
end

output_path = File.join(locale_dir, "translated.json")
File.write(output_path, JSON.pretty_generate({ "language" => locale, "prompts" => assembled_prompts }) + "\n")
puts "Wrote #{output_path} (#{assembled_prompts.length} prompts)"
