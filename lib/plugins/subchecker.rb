require 'cinch'
require 'snoo'

# This class needs refactoring!
# original source: i
# https://gist.githubusercontent.com/makzu/4166608/raw/caeb58500a4d4496ec41bb9114f6d05f7587e116/subchecker.rb
class SubChecker
  include Cinch::Plugin

  def initialize(*args)
    super
    @reddit = Snoo::Client.new
    listings = get_listings
    @already_checked = listings['data']['children'].map { |post| post['data']['id'] }
    @already_checked.reverse!
  end

  def get_listings
    @reddit.get_listing(
                          subreddit: 'DestinyTheGame',
                          page: 'top',
                          sort: 'new'
                        )
  end

  timer 61, method: :check

  def check
    listings = get_listings

    debug 'Checking sub.  Got ids: ' + listings['data']['children'].map { |post| post['data']['id'] }.to_s

    listings['data']['children'].each do |post|
      unless @already_checked.include? post['data']['id']
        posttitle = post['data']['title'].gsub(/[\x00-\x1f]/, '')
        posttitle.gsub!("\n", '')

        # TODO add formatting?
        Channel('#destinythegame').send "#{posttitle} - #{post['data']['over_18'] ? "\cB[NSFW]\cB " : ''}post by #{post['data']['author']} at http://redd.it/#{post['data']['id']}"

        @already_checked.push post['data']['id']
        @already_checked.shift if @already_checked.length > 100
      end
    end
  end
end
