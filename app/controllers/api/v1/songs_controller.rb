class Api::V1::SongsController < ApplicationController

  def all_songs
    render json: Song.all
  end
end