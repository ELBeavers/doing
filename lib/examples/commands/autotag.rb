# frozen_string_literal: true

# Example command that calls an existing command (tag) with
# preset options
desc 'Autotag last entry or filtered entries'
command :autotag do |c|
  # Preserve some switches and flags. Values will be passed
  # to tag command.
  c.desc 'Section'
  c.arg_name 'SECTION_NAME'
  c.flag %i[s section], default_value: 'All', multiple: true

  c.desc 'How many recent entries to autotag (0 for all)'
  c.arg_name 'COUNT'
  c.flag %i[c count], default_value: 1, must_match: /^\d+$/, type: Integer

  c.desc 'Don\'t ask permission to autotag all entries when count is 0'
  c.switch %i[force], negatable: false, default_value: false

  c.desc 'Autotag last entry (or entries) not marked @done'
  c.switch %i[u unfinished], negatable: false, default_value: false

  c.desc 'Autotag the last X entries containing TAG.
  Separate multiple tags with comma (--tag=tag1,tag2), combine with --bool'
  c.arg_name 'TAG'
  c.flag [:tag]

  c.desc 'Autotag entries matching search filter,
  surround with slashes for regex (e.g. "/query.*/"),
  start with single quote for exact match ("\'query")'
  c.arg_name 'QUERY'
  c.flag [:search]

  c.desc 'Boolean (AND|OR|NOT) with which to combine multiple tag filters'
  c.arg_name 'BOOLEAN'
  c.flag [:bool], must_match: REGEX_BOOL, default_value: 'AND'

  c.desc 'Select item(s) to tag from a menu of matching entries'
  c.switch %i[i interactive], negatable: false, default_value: false

  c.action do |global, options, _args|
    # Force some switches and flags. We're using the tag
    # command with settings that would invoke autotagging.

    # Force enable autotag
    options[:a] = true
    options[:autotag] = true

    # No need for date values
    options[:d] = false
    options[:date] = false

    # Don't remove any tags
    options[:rename] = nil
    options[:regex] = false
    options[:r] = false
    options[:remove] = false

    cmd = commands[:tag]
    action = cmd.send(:get_action, nil)
    action.call(global, options, [])
  end
end
