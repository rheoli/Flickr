#!/usr/bin/env ruby

require './flickr'
require 'pp'

photos=[]
photos_id=[]
sets={}


uid=Flickr.find_by_username("rheoli")
sets=Flickr.get_list(uid)

if ARGV.size==0
  puts "Usage: upload.rb {list of albums}"
  exit 0
end

ARGV.each do |phdir|
IO.popen("find /Volumes/TimeMachineDisk/Backup.Stephan/Pictures/Photos/#{phdir} -name '*.AVI*' -o -name '*.avi*' -o -name '*.mov*' -o -name '*.MOV*'", "r") do |p|
  p.each do |line|
    file=line.chomp
    if file=~/\.(AVI|avi|mov|MOV)$/
      photos<<file
    else
      photos_id<<file
    end
  end
end
end

photos_id.each do |p|
  if p=~/^(.+\.(AVI|avi|MOV|mov))\.([a-zA-Z0-9]+)$/
    file=$1
print "#{file}\n"
    if photos.include?(file)
      photos.delete(file)
#     print "delete #{file}\n"
    else
      print "not found #{file} ???\n"
    end
  end
end

photos.each do |file|
    if file=~/\/([a-zA-Z0-9]+)\/([a-zA-Z0-9_\-]+)\/([a-zA-Z0-9_\-]+)\.(AVI|avi|mov|MOV)$/
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
