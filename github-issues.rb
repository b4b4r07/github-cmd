#!/usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require
require 'time'

conf = Pit.get 'github.com', :require => {
  'login' => 'username on github.com',
  'password' => 'your-password'
}

client = Octokit::Client.new :login => conf['login'], :password => conf['password']

user = client.user
pages = (user.public_repos + user.total_private_repos)/100 + 1

repos = 1.upto(pages).map{|page|
  puts "reading page #{page}.."
  client.repos('shokai', :per_page => 100, :page => page)
}.flatten.reject{|repo|
  repo.open_issues_count < 1
}.sort{|a,b|
  b.updated_at <=> a.updated_at
}

unless ARGV.include? 'all'
  repos.delete_if do |repo|
    Time.parse(repo.updated_at) < Time.now - 60*60*24*60
  end
end

repos.each_with_index do |repo, i|
  puts "[#{i+1}/#{repos.size}] #{repo.html_url} (#{repo.open_issues_count} issues)"
  client.issues(repo.full_name).each do |i|
    puts " - #{i.title}"
  end
end


