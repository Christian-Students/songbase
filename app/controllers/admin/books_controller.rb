class Admin::BooksController < ApplicationController

  def index
    @books = Book.all
  end

  def show
    @book = Book.find(params[:id])
    @song_data = SongBook.includes(:song).where(book: @book).map do |sb|
      {
        song: sb.song,
        reference: sb
      }
    end
  end

end