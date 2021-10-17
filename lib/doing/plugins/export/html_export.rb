$wwid.register_plugin({
  name: 'html',
  type: :export,
  class: 'HTMLExport',
  trigger: 'html?|web(?:page)?',
  config: {
    'html_template' => {
      'css' => nil,
      'haml' => nil
    }
  }
})

class HTMLExport
  include Util

  def render(items, variables: {})
    return if items.nil?

    opt = variables[:options]

    items_out = []
    items.each do |i|
      # if i.has_key?('note')
      #   note = '<span class="note">' + i['note'].map{|n| n.strip }.join('<br>') + '</span>'
      # else
      #   note = ''
      # end
      if String.method_defined? :force_encoding
        title = i['title'].force_encoding('utf-8').link_urls
        note = i['note'].map { |line| line.force_encoding('utf-8').strip.link_urls } if i['note']
      else
        title = i['title'].link_urls
        note = i['note'].map { |line| line.strip.link_urls } if i['note']
      end

      interval = get_interval(i) if i['title'] =~ /@done\((\d{4}-\d\d-\d\d \d\d:\d\d.*?)\)/ && opt[:times]
      interval ||= false

      items_out << {
        date: i['date'].strftime('%a %-I:%M%p'),
        title: title.gsub(/(@[^ (]+(\(.*?\))?)/im, '<span class="tag">\1</span>').strip, #+ " #{note}"
        note: note,
        time: interval,
        section: i['section']
      }
    end

    template = if $wwid.config['html_template']['haml'] && File.exist?(File.expand_path($wwid.config['html_template']['haml']))
                 IO.read(File.expand_path($wwid.config['html_template']['haml']))
               else
                 $wwid.haml_template
               end

    style = if $wwid.config['html_template']['css'] && File.exist?(File.expand_path($wwid.config['html_template']['css']))
              IO.read(File.expand_path($wwid.config['html_template']['css']))
            else
              $wwid.css_template
            end

    totals = opt[:totals] ? tag_times(format: :html, sort_by_name: opt[:sort_tags], sort_order: opt[:tag_order]) : ''
    engine = Haml::Engine.new(template)
    @out = engine.render(Object.new,
                       { :@items => items_out, :@page_title => variables[:page_title], :@style => style, :@totals => totals })
  end
end