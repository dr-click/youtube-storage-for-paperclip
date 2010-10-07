require "rexml/document"
module Paperclip
  module Interpolations
    # Returns the youtube_id of the instance.
    def youtube_id attachment, style
      attachment.instance.youtube_id
    end
  end
  
  module Storage
    module Youtube
      def self.extended base
        begin
          require 'net/http'
        rescue LoadError => e
          log("(Error) #{e.message}")
          e.message << " (Can't find required library 'net/http')"
          raise e
        end
        begin
          require 'net/https'
        rescue LoadError => e
          log("(Error) #{e.message}")
          e.message << " (Can't find required library 'net/https')"
          raise e
        end
        begin
          require 'mime/types'
        rescue LoadError => e
          log("(Error) #{e.message}")
          e.message << " (You may need to install the mime-types gem)"
          raise e
        end
        
        base.instance_eval do
          @youtube_options = @options[:youtube_options] || {}
          
          @developer_key = @options[:developer_key] || @youtube_options[:developer_key]
          @login_name = @options[:login_name] || @youtube_options[:login_name]
          @login_password = @options[:login_password] || @youtube_options[:login_password]
          @youttube_username = @options[:youttube_username] || @youtube_options[:youttube_username]
          
          @auth_host = @options[:auth_host] || @youtube_options[:auth_host] || 'www.google.com'
          @auth_path = @options[:auth_path] || @youtube_options[:auth_path] || '/youtube/accounts/ClientLogin'
          
          @upload_host = @options[:upload_host] || @youtube_options[:upload_host] || 'uploads.gdata.youtube.com'
          @upload_path = @options[:upload_path] || @youtube_options[:upload_path] || "/feeds/api/users/#{@youttube_username}/uploads"
          
          @data_host = @options[:data_host] || @youtube_options[:data_host] || 'gdata.youtube.com'
        end
        
        Paperclip.interpolates(:youtube_url) do |attachment, style|
            style = :thumbnail_1 if style == :thumbnail
            if style == :original
              'http://www.youtube.com/watch?v=:youtube_id'
            else
              "http://i.ytimg.com/vi/:youtube_id/#{style.to_s.split('_').last.to_i}.jpg" 
            end
        end
      end
      
      def login_name
        @login_name
      end
      def login_password
        @login_password
      end
      def developer_key
        @developer_key
      end
      
      def auth_host
        @auth_host
      end
      def auth_path
        @auth_path
      end
      
      def upload_host
        @upload_host
      end
      def upload_path
        @upload_path
      end
      
      def data_host
        @data_host
      end
      
      def token
        @token ||= init_youtube_auth
        @token
      end
      
      def read_file(fname)
        return File.open(fname, 'rb') {|io| io.read}
      end
      
      def update_youtube_id(data)
        doc = REXML::Document.new data
        id = doc.root.elements["id"].text.split("/").last if doc && doc.root
        
        if id
          video = Video.find self.instance.id
          video.update_attribute(:youtube_id, id)
        else
          log("(Error) Video has no id, please reupload to Youtube.")
          raise "Video has no id, please reupload to Youtube."
        end
      end
      
      def init_youtube_auth
          http = Net::HTTP.new( auth_host, 443 )
          http.use_ssl = true
          data = "Email=#{login_name}&Passwd=#{login_password}&service=youtube&source=VTrack"
          headers = {
            'Content-Type' => 'application/x-www-form-urlencoded'
          }
          
          resp, data = http.post( auth_path, data, headers )
          if ( resp.code == '200' )
            return data.scan( /Auth=(.*)/ )
          end
          return nil
        rescue => e
          e.message << " (Can't connect to Youtube)"
          raise e
      end      
      def youtube_delete
        http = Net::HTTP.new(data_host)
        headers = {
          'Content-Type' => 'application/atom+xml',
          'Authorization' => "GoogleLogin auth=#{token}",
          'GData-Version' => '2',
          'X-GData-Key' => "key=#{developer_key}"
        }
        
        resp = http.delete(upload_path+"/#{self.instance.youtube_id}", headers)
        if resp.code != "200"
          log("(Error) Couldn't delete the video from Youtube")
          raise "Couldn't delete the video from Youtube"
        end
      end

      def youtube_direct_upload(video, video_file)
        video_title = self.instance.title || video_file
        video_description = self.instance.description || video_file
        data = <<"DATA"
--f93dcbA3
Content-Type: application/atom+xml; charset=UTF-8

<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:yt="http://gdata.youtube.com/schemas/2007">
  <media:group>
    <media:title type="plain">#{video_title}</media:title>
    <media:description type="plain">#{video_description}</media:description>
    <media:category
      scheme="http://gdata.youtube.com/schemas/2007/categories.cat">People
    </media:category>
    <media:keywords></media:keywords>
  </media:group>
</entry>
--f93dcbA3
Content-Type: #{MIME::Types.type_for(video_file).to_s}  
Content-Transfer-Encoding: binary

#{video}
--f93dcbA3--
DATA

        http = Net::HTTP.new(upload_host)
        http.read_timeout = 1800
        
        headers = {
          'X-GData-Key' => "key=#{developer_key}",
          'Slug' => video_file,
          'Content-Type' => 'multipart/related; boundary="f93dcbA3"',
          'Content-Length' => data.length.to_s,
          'Connection' => 'close',
          'Authorization' => "GoogleLogin auth=#{token}"
        }
        
        resp, data = http.post( upload_path, data, headers )
        
        if resp.code == "201"
          update_youtube_id data
        else
          log("(Error) Couldn't upload the video to Youtube >> #{data}")
          raise "Couldn't upload the video to Youtube >> #{data}"
        end
      end 

      def exists?(style_name = default_style)
        http = Net::HTTP.new(data_host)
        headers = {
          'Content-Type' => 'application/atom+xml',
          'Authorization' => "GoogleLogin auth=#{token}",
          'GData-Version' => '2',
          'X-GData-Key' => "key=#{developer_key}"
        }
        
        resp= http.get(upload_path+"/#{self.instance.youtube_id}", headers)
        if resp.code == "200"
          return true
        elsif
          log("(Error) Couldn't find the video '#{self.instance.youtube_id}'")
          return false
        end
      end
      
      # Returns representation of the data of the file assigned to the given
      # style, in the format most representative of the current storage.
      def to_file style_name = default_style
      end
      
      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|
          begin
            log("Uploading to youtube : #{self.instance.media_file_name}")
            youtube_direct_upload(read_file(file.path), self.instance.media_file_name)
          rescue => e
            log("(Error) #{e.message}")
            raise e.message
          end
        end
        @queued_for_write = {}
      end
      
      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          begin
            log("deleting from youtube : #{self.instance.youtube_id}")
            youtube_delete
          rescue => e
            log("(Error) #{e.message}")
            raise e.message
          end
        end
        @queued_for_delete = []
      end
    end
  end
end