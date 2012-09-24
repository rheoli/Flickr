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

# config["photos_base_path"]

ARGV.each do |phdir|
  Dir.open("#{config["photos_base_path"]}/#{phdir}").each do |d|
  
ARGV.each do |phdir|
  AVI|avi|mov|MOV
  IO.popen("find #{path}/#{phdir} -name '*.JPG*' -o -name '*.jpg*' -o -name '*.png*'", "r") do |p|
  p.each do |line|
    file=line.chomp
p file
    if file=~/\.(JPG|jpg|png)$/
      photos<<file
    else
      photos_id<<file
    end
  end
end
end

photos_id.each do |p|
  if p=~/^(.+\.(JPG|jpg|png))\.([a-zA-Z0-9]+)$/
    file=$1
#print "#{file}\n"
    if photos.include?(file)
      photos.delete(file)
#     print "delete #{file}\n"
    else
      print "not found #{file} ???\n"
    end
  end
end

photos.each do |file|
    if file=~/\/([a-zA-Z0-9_]+)\/([a-zA-Z0-9_\-]+)\/([a-zA-Z0-9_\-]+)\.(JPG|jpg|png)$/
      title=$1
      photo_id=Flickr.post_photo(file, {:title=>title, :tags=>title.downcase})
      next if photo_id.nil?
      print "#{file} uploaded.\n"
      system("touch #{file}.#{photo_id}")
      if sets[title].nil?
        set_id=Flickr.create_set(title, photo_id)
        sets[title]=set_id
      else
        Flickr.add_photo(sets[title], photo_id)
      end
    else
      print "#{file} not found.\n"
    end
end

#=EOF
