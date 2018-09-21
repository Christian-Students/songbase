class SongsController < ApplicationController
  before_action :set_song, only: [:show, :edit, :update, :destroy]
  before_action :authenticate, only: [:new, :edit, :create, :update, :destroy]
  before_action :check_maintenance
  before_action :adjust_lang_params, only: [:create, :update]

  def app
    set_songs
    @song_id = params[:s]
  end

  def admin
    set_songs_admin
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
      redirect_to admin_path, notice: "Song was successfully updated. #{view_context.link_to 'Click here', song_path(@song), class: 'flash_link'} to go to app."
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

  def set_song
    @song = Song.find(params[:id] || params[:s])
  end

  def set_songs
    @songs ||= []

    Song.all.includes(books: :song_books).each do |song|
      song.titles.values.each do |title|
        @songs << song.app_entry
      end
    end
    sort_songs(@songs)
  end

  def set_songs_admin
    @songs = {}
    @songs[:duplicate] =  sort_songs(Song.duplicates.includes(books: :song_books).map(&:admin_entry)) if super_admin
    @songs[:changed] = sort_songs(Song.recently_changed.includes(books: :song_books).map(&:admin_entry))
    @songs[:unchanged] = sort_songs((Song.all.includes(books: :song_books) - Song.duplicates - Song.recently_changed).map(&:admin_entry))
  end

  def song_params
    params.require(:song).permit(:lyrics, :firstline_title, :custom_title, :chorus_title, :lang)
  end

  def sort_songs(songs)
    songs.sort_by! { |s| clean_for_sorting(s[:title]) }
  end

  def clean_for_sorting str
    str.gsub(/[’'",“\-—–!?()]/, "").upcase
  end

  def time_ago_in_words(time)
    time.to_s
  end
end
