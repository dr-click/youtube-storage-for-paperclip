class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string      :title                    #I supposed that the video has a title field, if you wish to remove then you have to reomve from youtube_storage.rb
      t.text        :description              #I supposed that the video has a description field, if you wish to remove then you have to reomve from youtube_storage.rb
      t.string      :youtube_id               #The field that has the id of the video on youtube, this field is mandatory
      t.string      :media_file_name          #paperclip attribute 
      t.string      :media_content_type       #paperclip attribute
      t.integer     :media_file_size          #paperclip attribute
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
