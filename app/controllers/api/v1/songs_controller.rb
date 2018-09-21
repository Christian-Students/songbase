class Api::V1::SongsController < ApplicationController

  def songs
    render json: Song.all.map(&:app_entry), status: 200
  end

end