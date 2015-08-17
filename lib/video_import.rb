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

        enclosure = item.search('enclosure').first
        add_video(event, enclosure)

        link = item.search('link').first
        add_link(event, link.text)
      }
    end
  end

  protected

  def find_event(id)
    event = Event.find(id)
    event if event and event.conference == @conference
  end

  def add_video(event, enclosure)
    event.videos << Video.new(url: enclosure['url'], mimetype: enclosure['type'])
  end

  def add_link(event, link)
    event.links << Link.new(title: "Video Recording", url: link)
  end

  def fetch_remote
    Nokogiri::XML(open(@url))
  end
end
