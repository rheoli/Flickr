#!/usr/bin/env ruby

BASE="#{File.dirname(__FILE__)}"
$: << "#{BASE}/lib"

require 'yaml'
require 'flickr'
require 'pp'

photos=[]
photos_id=[]
sets={}

if ARGV.size==0
  puts "Usage: upload.rb {list of albums}"
  exit 0
end

config=YAML.load(File.open("#{ENV["HOME"]}/.flickr/config.yml"))

Flickr.api_key(config["api_key"])
Flickr.shared_secret(config["shared_secret"])

flickr=Flickr.new(config["auth_token"])

uid=flickr.find_by_username("rheoli")
sets=flickr.get_list(uid)

p sets