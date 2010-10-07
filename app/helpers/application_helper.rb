module ApplicationHelper
  def video_object_tag(video, style=:thumbnail)
    tag = %Q(
      <object width="460" height="330">
        <param name="movie" value="http://www.youtube.com/v/#{video.youtube_id}&amp;hl=en_US&amp;fs=1"></param>
        <param name="allowFullScreen" value="true"></param>
        <param name="allowscriptaccess" value="always"></param>
        <embed src="http://www.youtube.com/v/#{video.youtube_id}&amp;hl=en_US&amp;fs=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="460" height="330"></embed>
      </object>
    )
    return tag
  end
  
end
