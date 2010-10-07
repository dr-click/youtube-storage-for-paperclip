class VideosController < ApplicationController
  def index
    @videos = Video.all
  end

  def show
    @video = Video.find(params[:id])
  end

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(params[:video])
    
    if @video.save
      redirect_to(videos_path, :notice => 'Video was successfully created.')
    else
      render :action => "new"
    end
      
  end

  def destroy
    @video = Video.find(params[:id])
    @video.destroy
    
    redirect_to(videos_url)
  end
end
