require 'mime/types'

class Video < ActiveRecord::Base
  #You can add more allowed videos types, but you have to check for allowed youtube videos types.
  ALLOWED_VIDEOS_TYPES= ['application/x-mp4', 'video/mpeg', 'video/quicktime', 'video/x-flv', 'video/mp4', 'video/mpeg4', 'video/mpeg4-generic', 'video/x-ms-wmv', 'video/mpg']
  
  #Replace with your youtube credential 
  YOUTUBE_CONFIG = {:developer_key=>"replace_with_developer_key",                #you have to get a new youtube developer key
                    :login_name=>"replace_with_your_login_name",                 #the login name that you use to login into youtube
                    :login_password=>"replace_with_your_password",               #the password
                    :youttube_username=>"replace_with_your_youttube_username"}   #this is not the login name, it's a youtube username, you can get it from your profile in youtube 
                    
  has_attached_file :media,  
                    :url=> ':youtube_url',
                    :youtube_options=>YOUTUBE_CONFIG,
                    :storage=>:youtube
  
  validates_presence_of :title, :description
  validates_attachment_presence :media, :message=>"Must be set."
  validates_attachment_content_type :media, :content_type=>ALLOWED_VIDEOS_TYPES
end
