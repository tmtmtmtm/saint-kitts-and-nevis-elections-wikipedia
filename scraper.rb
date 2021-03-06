#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'pry'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  constituency = ''
  noko.xpath('//h3[span[@id="Elected_MPs"]]/following-sibling::table[1]/tr[td]').each do |tr|
    tds = tr.css('td')
    data = { 
      name: tds[1].text,
      wikiname: tds[1].xpath('.//a[not(@class="new")]/@title').text,
      party: tds[2].text.tidy,
      area: tds[3].text.tidy,
      term: 2015,
    }
    ScraperWiki.save_sqlite([:name, :area, :term], data)
  end
end

scrape_list('https://en.wikipedia.org/wiki/Saint_Kitts_and_Nevis_general_election,_2015')
