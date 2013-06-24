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

$photos={}

def loop(_dir)
  Dir.open(_dir).each do |d|
    next if d=~/^\./
    path="#{_dir}/#{d}"
    if File.directory?(path)
      loop(path)
    else
      #jpg|JPG|png|PNG|mov|MOV|avi|AVI
      if path=~/^(.+\.(jpg|JPG|png|PNG))(\.([0-9]+))?$/
        photo=$1; id=$4
        $photos[photo]=id
      end
    end
  end
end

ARGV.each do |phdir|
  loop("#{config["photos_base_path"]}/#{phdir}")
end

$photos.each do |photo, id|
  if id.nil?
    #-Upload
    puts "Upload #{photo}"
    if photo=~/^#{config["photos_base_path"]}\/([A-Za-z\/]+)\/([0-9_]+)\/(.+)$/
      name=$1; date=$2
      puts "#{name} / #{date}"
      tags = name.split(/\//)
      name = tags[0]
      photo_id=flickr.post_photo(photo, {:title=>name, :tags=>tags.join(' ').downcase})
      system("touch #{photo}.#{photo_id}")
      if sets[name].nil?
        puts " - create set #{name}"
        set_id=flickr.create_set(name, photo_id)
        sets[name]=set_id
      else
        puts " - add to set #{name}"
        flickr.add_photo(sets[name], photo_id)
      end
    else
      puts " -> not in regex found"
    end
  end
end

#=EOF
