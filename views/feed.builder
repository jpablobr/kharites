xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title Kharites::Configuration.kharites.title
  xml.id Kharites::Configuration.kharites.url_base
  xml.author { xml.name Kharites::Configuration.kharites.author }

  @notes.each do |note|
    xml.entry do
      xml.title note.title
      xml.link "rel" => "alternate", "href" => "/past/#{url_for(note)}"
      xml.id full_url_for(note)
      xml.published note.created_at
      xml.updated note.created_at
      xml.author { xml.name Kharites::Configuration.kharites.author }
      xml.summary md(note.summary), "type" => "html"
      xml.content md(note.body.to_s), "type" => "html"
    end
  end
end
