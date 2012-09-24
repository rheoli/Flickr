require 'net/http'
require 'digest/md5'
require 'uri'
require "rexml/document"

class Flickr
  REST_URI="/services/rest/"
  @@api_key=nil
  @@shared_secret=nil

  def self.api_key(_key)
    @@api_key=_key
  end

  def self.shared_secret(_key)
    @@shared_secret=_key
  end

  def initialize(_auth_token)
    @auth_token=_auth_token
  end
     
  def call_rest(_method, _options, _post=false, _sign=false)
    _options[:method]=_method
    _options[:api_key]=@@api_key
    if _sign
      _options[:auth_token]=@auth_token
      psign=_options.collect { |a, b| "#{a}#{b}" }.sort.join
      p psign
      _options[:api_sig]=Digest::MD5.hexdigest(@@shared_secret+psign)
    end
    params=_options.collect { |a, b| "#{a}=#{b}" }.join("&")
    res = Net::HTTP.start("api.flickr.com", 80) do |http|
       if _post
         http.post(REST_URI, params)
       else
         http.get(REST_URI+"?#{params}")
       end
    end
    res.body
  end

  def post_photo(_file, _options)
    _options[:api_key]=@@api_key
    _options[:auth_token]=@auth_token
    psign=_options.collect { |a, b| "#{a}#{b}" }.sort.join
    _options[:api_sig]=Digest::MD5.hexdigest(@@shared_secret+psign)
    boundary = "--_ruby-311721796827358"
    parts=[]
    _options.each do |k, v|
       parts<<"Content-Disposition: form-data; name=#{k}\r\n\r\n#{v}\r\n"
    end
    filedata=File.open(_file).read
    parts<<"Content-Disposition: form-data; name=photo; filename=#{_file}\r\nContent-Type: image/jpeg\r\n\r\n#{filedata}\r\n"
    query=""
    parts.each do |p|
      query<<"--"+boundary+"\r\n"+p
    end
    query<<"--"+boundary+"--\r\n"
    res = Net::HTTP.start("api.flickr.com", 80) do |http|
       http.post("/services/upload/", query, "Content-type" => "multipart/form-data; boundary=" + boundary)
    end
    doc = REXML::Document.new res.body
    if doc.root.attributes["stat"]=="ok"
      return doc.root.elements["photoid"].text
    end
    nil
  end

  def find_by_username(_user)
    res=call_rest("flickr.people.findByUsername", {:username=>_user})
    doc = REXML::Document.new res
    if doc.root.attributes["stat"]=="ok"
      return doc.root.elements["user"].attributes["id"]
    end
    nil
  end

  def create_set(_title, _photo_id)
    res=call_rest("flickr.photosets.create", {:title=>_title, :primary_photo_id=>_photo_id}, true, true)
    p res
    doc = REXML::Document.new res
    if doc.root.attributes["stat"]=="ok"
      return doc.root.elements["photoset"].attributes["id"]
    end
    nil
  end

  def add_photo(_set, _photo_id)
    res=call_rest("flickr.photosets.addPhoto", {:photoset_id=>_set, :photo_id=>_photo_id}, true, true)
    #p res
    doc = REXML::Document.new res
    if doc.root.attributes["stat"]=="ok"
      return true
    end
    false
  end

  def get_list(_uid)
    res=call_rest("flickr.photosets.getList", {:user_id=>_uid})
    #p res
    doc = REXML::Document.new res
    sets={}
    if doc.root.attributes["stat"]=="ok"
      doc.root.elements.each("photosets/photoset") do |e|
        sets[e.elements["title"].text]=e.attributes["id"]
      end
    end
    sets
  end

end

#=EOF
