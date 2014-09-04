#!/usr/bin/env ruby

require 'cgi'
require 'cinch'
require 'json'
require 'open-uri'

require_relative 'plugins/subchecker'

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = 'irc.snoonet.org'
    c.nick     = 'AlphaGhost'
    c.channels = ['#destinythegame']
    config.plugins.plugins = [SubChecker]
  end

  helpers do
    def wiki(query)
      url = 'http://destiny.wikia.com'
      path = "/api/v1/Search/List/?query=#{CGI.escape(query)}&limit=5"
      JSON.load(open(url + path))['items']
    rescue
      'No results found'
    end
  end

  on :message, /^!wiki (.+)/ do |m, query|
    wiki(query).each do |item|
      m.reply "#{item['title']} - #{item['url']}"
    end
  end
end

bot.start
