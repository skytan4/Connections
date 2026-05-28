#!/usr/bin/env ruby
# frozen_string_literal: true

path = File.expand_path("../docs/friends-new-prompts.md", __dir__)

origin_by_topic = {
  "Appreciation" => [
    "What made that stand out to you?",
    "What did it give you that you needed at the time?",
    "What do you think made it feel so meaningful?",
    "What part of it have you carried with you?"
  ],
  "Communication" => [
    "What makes that easier or harder to say out loud?",
    "What do you usually hope the other person understands?",
    "What tends to get in the way of saying it directly?",
    "When have you felt most understood around this?"
  ],
  "Conflict" => [
    "What usually makes that kind of tension harder to name?",
    "What do you think was really underneath it?",
    "What would have helped the disagreement feel safer?",
    "What part of it was hardest to admit?"
  ],
  "Daily Life" => [
    "What does that reveal about the way your life feels right now?",
    "Who gets to see that part of your life most clearly?",
    "What makes that feel ordinary on the outside but important to you?",
    "How long has that been true for you?"
  ],
  "Emotions" => [
    "What usually brings that feeling up for you?",
    "What do you tend to do with that feeling when it shows up?",
    "Who handles that side of you with the most care?",
    "What makes that feeling hard to show?"
  ],
  "Growth" => [
    "What helped you notice that change in yourself?",
    "What made that lesson stick?",
    "Where do you still feel unfinished with it?",
    "Who has helped you grow in that direction?"
  ],
  "Identity" => [
    "What do you think people miss when they see only that version of you?",
    "When did you first notice that about yourself?",
    "Who sees that part of you most accurately?",
    "What makes that part of you feel important?"
  ],
  "Intimacy" => [
    "What has to be present for that kind of trust to feel possible?",
    "What makes that kind of closeness feel safe instead of pressured?",
    "When have you felt that with a friend before?",
    "What do you protect by holding that back?"
  ],
  "Past" => [
    "What part of that memory still feels active in you?",
    "How did that experience shape what you expect from friends?",
    "What do you understand about it differently now?",
    "Who were you at that point in your life?"
  ],
  "Values" => [
    "Where do you think that value came from?",
    "When has that value been tested in a friendship?",
    "What makes that one non-negotiable for you?",
    "How do you recognize that value in someone else's actions?"
  ]
}

impact_by_topic = {
  "Appreciation" => [
    "Have you ever told them that directly?",
    "How did it change the way you saw the friendship?",
    "What would it look like to return that kind of care?",
    "How does remembering it affect you now?"
  ],
  "Communication" => [
    "What would change if you said it more plainly?",
    "How do you think a good friend would respond?",
    "What would help you communicate it with more trust?",
    "What do you want to practice doing differently next time?"
  ],
  "Conflict" => [
    "What would repair look like in that situation?",
    "What would you want to do differently next time?",
    "How could that kind of disagreement strengthen a friendship?",
    "What boundary or honesty might it be asking for?"
  ],
  "Daily Life" => [
    "What kind of support would make that easier?",
    "How does it affect the way you show up for friends?",
    "What would feel different if someone understood that better?",
    "What small change would make it feel lighter?"
  ],
  "Emotions" => [
    "What helps you feel less alone in it?",
    "What would you want a friend to do with that information?",
    "How does that feeling affect the way you connect with people?",
    "What would it look like to let someone meet you there?"
  ],
  "Growth" => [
    "How has that changed the kind of friend you want to be?",
    "What would progress look like from here?",
    "Who would notice that growth first?",
    "What might your friendships gain if you keep growing there?"
  ],
  "Identity" => [
    "How does that affect the way you let people know you?",
    "What would feel different if that part of you were more accepted?",
    "How has that shaped your friendships?",
    "What would it mean to be seen more fully there?"
  ],
  "Intimacy" => [
    "What would it change if you let someone closer there?",
    "What kind of friendship makes room for that?",
    "How do you know when someone has earned that trust?",
    "What would you want a friend to understand before you shared it?"
  ],
  "Past" => [
    "How does it still affect the way you connect now?",
    "What would you tell your younger self about that friendship?",
    "What did it teach you to seek or avoid?",
    "What part of that story are you still making peace with?"
  ],
  "Values" => [
    "How does that value shape who you stay close to?",
    "What happens when a friend does not share it?",
    "How do you want to live that value more clearly?",
    "What does that value ask of you as a friend?"
  ]
}

def pick(options, text, salt)
  options[(text.bytes.sum + salt) % options.length]
end

raw_lines = File.readlines(path, chomp: true)

# Make the script idempotent while these drafts are still being reviewed.
lines = []
i = 0
while i < raw_lines.length
  if raw_lines[i] == "  - Follow-ups:"
    i += 3
    next
  end

  lines << raw_lines[i]
  i += 1
end

result = []
current_topic = nil
in_prompt_sections = false
i = 0

while i < lines.length
  line = lines[i]

  if line.start_with?("## Light", "## Honest", "## Unfiltered")
    in_prompt_sections = true
  elsif line.start_with?("### ")
    current_topic = line.delete_prefix("### ").strip
  end

  result << line

  if in_prompt_sections && line.start_with?("- ") && !line.start_with?("- Follow-ups:")
    next_line = lines[i + 1]
    unless next_line&.include?("Follow-ups:")
      prompt_text = line.delete_prefix("- ").strip
      topic = current_topic || "Communication"
      origins = origin_by_topic.fetch(topic, origin_by_topic.fetch("Communication"))
      impacts = impact_by_topic.fetch(topic, impact_by_topic.fetch("Communication"))

      result << "  - Follow-ups:"
      result << "    - #{pick(origins, prompt_text, 0)} (`origin`)"
      result << "    - #{pick(impacts, prompt_text, 7)} (`impact`)"
    end
  end

  i += 1
end

File.write(path, result.join("\n") + "\n")
