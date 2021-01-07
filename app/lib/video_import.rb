class VideoImport
  require 'open-uri'
  require 'nokogiri'

  def initialize(conference, url)
    @conference = conference
    @url = url
  end

  def import
    @xml = fetch_remote
    @xml.remove_namespaces!

    ActiveRecord::Base.transaction do
      items = @xml.search('//item')
      items.each { |item|
        id = item.search('identifier').first

        event = find_event(id.text)
        next unless event

        link = item.search('link').first
        next unless link

        add_link(event, link.text)
      }
    end
  end

  protected

  def find_event(id)
    event = Event.find_by(guid: id)
    event if event and event.conference == @conference
  end

  def add_link(event, link)
    event.video_url = link
    event.save
  end

  def fetch_remote
    Nokogiri::XML(open(@url))
  end
end
