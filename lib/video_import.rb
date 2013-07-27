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
        enclosure = item.search('enclosure').first
        add_video(id.text, enclosure)
      }

    end

  end

  protected

  def add_video(id, enclosure)
    event = Event.find(id)
    if event and event.conference == @conference
      video = Video.new(url: enclosure['url'], mimetype: enclosure['type'])
      event.videos << video
    end
  end

  def fetch_remote
    Nokogiri::XML(open(@url))
  end

end
