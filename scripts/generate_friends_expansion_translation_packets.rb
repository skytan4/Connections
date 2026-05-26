#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "optparse"

ROOT = File.expand_path("..", __dir__)
DEFAULT_OUTPUT = "/tmp/friends_expansion_translation_packets"
STAGED_SOURCE = File.join(ROOT, "docs", "friends-new-prompts-staged.json")

LOCALES = {
  "da" => {
    language_name: "Danish",
    brief: "docs/localization/danish-brief.md"
  },
  "de" => {
    language_name: "German",
    brief: "docs/localization/german-brief.md"
  },
  "es" => {
    language_name: "Spanish",
    brief: "docs/localization/spanish-brief.md"
  },
  "fi" => {
    language_name: "Finnish",
    brief: "docs/localization/finnish-brief.md"
  },
  "fr" => {
    language_name: "French",
    brief: "docs/localization/french-brief.md"
  },
  "it" => {
    language_name: "Italian",
    brief: "docs/localization/italian-brief.md"
  },
  "ja" => {
    language_name: "Japanese",
    brief: "docs/localization/japanese-brief.md"
  },
  "nb" => {
    language_name: "Norwegian Bokmal",
    brief: "docs/localization/norwegian-brief.md"
  },
  "nl" => {
    language_name: "Dutch",
    brief: "docs/localization/dutch-brief.md"
  },
  "pl" => {
    language_name: "Polish",
    brief: "docs/localization/polish-brief.md"
  },
  "pt-BR" => {
    language_name: "Brazilian Portuguese",
    brief: "docs/localization/brazilian-portuguese-brief.md"
  },
  "ru" => {
    language_name: "Russian",
    brief: "docs/localization/russian-brief.md"
  },
  "sv" => {
    language_name: "Swedish",
    brief: "docs/localization/swedish-brief.md"
  },
  "zh-Hans" => {
    language_name: "Simplified Chinese",
    brief: "docs/localization/simplified-chinese-brief.md"
  }
}.freeze

options = {
  output: DEFAULT_OUTPUT,
  locales: LOCALES.keys
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/generate_friends_expansion_translation_packets.rb [options]"
  parser.on("--output PATH", "Output directory (default: #{DEFAULT_OUTPUT})") { |value| options[:output] = value }
  parser.on("--locales LIST", "Comma-separated locales, e.g. es,fr,pt-BR") do |value|
    options[:locales] = value.split(",").map(&:strip)
  end
end.parse!

unknown_locales = options[:locales] - LOCALES.keys
raise "Unknown locales: #{unknown_locales.join(", ")}" if unknown_locales.any?

staged = JSON.parse(File.read(STAGED_SOURCE))
prompts = staged.fetch("prompts")
raise "Expected staged prompts" if prompts.empty?

def non_negotiables(path)
  lines = File.readlines(path, chomp: true)
  start = lines.index { |line| line.strip == "## Agent Non-Negotiables" }
  raise "Missing Agent Non-Negotiables in #{path}" unless start

  finish = ((start + 1)...lines.length).find { |index| lines[index].start_with?("## ") } || lines.length
  lines[start...finish].join("\n").strip
end

def prompt_for(locale, config, source_json, non_negotiables_text)
  <<~MARKDOWN
    # Friends Expansion Translation Packet: #{config.fetch(:language_name)} (`#{locale}`)

    Translate the attached Friends prompt expansion into #{config.fetch(:language_name)}.

    ## Source

    The English source records are in `source.json` in this same packet folder.

    ## Language Brief

    Follow the full language brief:

    `#{config.fetch(:brief)}`

    #{non_negotiables_text}

    ## Task

    Translate all #{source_json.fetch("prompts").length} prompt records from English into #{config.fetch(:language_name)}.

    These are all Friends mode prompts. Preserve the app's thoughtful, natural, emotionally intelligent tone. Keep Friends prompts friendship-coded, not romantic or couples-coded.

    ## Hard Constraints

    - Output raw JSON only.
    - Translate every `text` field on each prompt.
    - Translate every follow-up `text`.
    - Preserve every `id` exactly.
    - Preserve `mode`, `intensity`, `depth`, `topic`, and follow-up `style` exactly.
    - Preserve record order exactly.
    - Do not add, remove, split, merge, or renumber prompts.
    - Do not leave English placeholders unless the language brief explicitly requires a brand term to remain English.
    - Do not include comments, Markdown, explanations, or code fences in the output.

    ## Output Shape

    ```json
    {
      "language": "#{locale}",
      "prompts": [
        {
          "id": "p_friends_light_warmUp_appreciation_005",
          "text": "Translated prompt text",
          "mode": "friends",
          "intensity": "light",
          "depth": "warmUp",
          "topic": "appreciation",
          "followUps": [
            {
              "id": "p_friends_light_warmUp_appreciation_005_fu_1",
              "text": "Translated follow-up 1",
              "style": "origin"
            },
            {
              "id": "p_friends_light_warmUp_appreciation_005_fu_2",
              "text": "Translated follow-up 2",
              "style": "impact"
            }
          ]
        }
      ]
    }
    ```

    ## English Source Preview

    The first record is:

    ```json
    #{JSON.pretty_generate(source_json.fetch("prompts").first)}
    ```
  MARKDOWN
end

output_root = File.expand_path(options.fetch(:output))
FileUtils.rm_rf(output_root)
FileUtils.mkdir_p(output_root)

manifest = {
  "source" => STAGED_SOURCE,
  "promptCount" => prompts.length,
  "locales" => {}
}

options.fetch(:locales).each do |locale|
  config = LOCALES.fetch(locale)
  locale_dir = File.join(output_root, locale)
  FileUtils.mkdir_p(locale_dir)

  source_json = {
    "language" => "en",
    "targetLanguage" => locale,
    "prompts" => prompts
  }

  brief_path = File.join(ROOT, config.fetch(:brief))
  packet_prompt = prompt_for(locale, config, source_json, non_negotiables(brief_path))

  File.write(File.join(locale_dir, "source.json"), JSON.pretty_generate(source_json) + "\n")
  File.write(File.join(locale_dir, "agent_prompt.md"), packet_prompt)
  File.write(File.join(locale_dir, "output.expected.json"), JSON.pretty_generate({ "language" => locale, "prompts" => [] }) + "\n")

  manifest.fetch("locales")[locale] = {
    "languageName" => config.fetch(:language_name),
    "brief" => config.fetch(:brief),
    "source" => File.join(locale_dir, "source.json"),
    "prompt" => File.join(locale_dir, "agent_prompt.md"),
    "expectedOutput" => File.join(locale_dir, "output.expected.json")
  }
end

File.write(File.join(output_root, "manifest.json"), JSON.pretty_generate(manifest) + "\n")
puts JSON.generate(output: output_root, locales: options.fetch(:locales), promptCount: prompts.length)
