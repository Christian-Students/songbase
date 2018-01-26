class SongsController < ApplicationController
  before_action :set_song, only: [:show, :edit, :update, :destroy]
  before_action :set_songs, only: [:app, :admin]
  before_action :authenticate, only: [:new, :edit, :create, :update, :destroy]
  before_action :check_maintenance
  before_action :adjust_lang_params, only: [:create, :update]

  def app
    @song_id = params[:s]
  end

  def admin
    set_songs_to_check
  end

  def show
  end

  def new
    @song = Song.new
  end

  def edit
  end

  def create
    @song = Song.new(song_params)

    respond_to do |format|
      if @song.save
        Audit.create(user: current_user, song: @song, time: Time.zone.now)
        format.html { redirect_to admin_path, notice: 'Song was successfully created.' }
        format.json { render :show, status: :created, location: @song }
      else
        format.html { render :new }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @song.update(song_params)
      Audit.create(user: current_user, song: @song, time: Time.zone.now)
      redirect_to admin_path, notice: 'Song was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @song.destroy
      redirect_to admin_path, notice: 'Song was successfully destroyed.'
    else
      render :back
    end
  end

  private

  def adjust_lang_params
    if params[:song][:lang] == "new_lang"
      params[:song][:lang] = params[:song][:new_lang]
    end
  end

  def set_songs_to_check
    @songs_to_check = Song.all.select { |song|
      song.audits.any? && song.audits.last.time - 7.days < Time.zone.now
    }.sort_by { |song| song.audits.last.time }.reverse!.map { |s|
      {
        title: [s.custom_title, s.firstline_title, s.chorus_title].reject(&:blank?).first,
        model: s,
        edit_timestamp: s.audits.last.time
      }
    }
  end

  def set_song
    @song = Song.find(params[:id] || params[:s])
  end

  def set_songs
    @songs = []
    Song.all.each do |song|
      song.titles.each do |t|
        @songs << {
          title: t[1],
          model: song,
          edit_timestamp: song.audits.last&.time
        }
      end
    end
    @songs.sort_by! { |s| clean_for_sorting(s[:title]) }
  end

  def song_params
    params.require(:song).permit(:lyrics, :firstline_title, :custom_title, :chorus_title, :lang)
  end

  def clean_for_sorting str
    str.gsub(/[’'",“\-—–!?()]/, "").upcase
  end
end
