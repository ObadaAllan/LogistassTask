# app/controllers/books_controller.rb
require 'csv'

class BooksController < ApplicationController
  before_action :authenticate_author!
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def index
    @filterrific = initialize_filterrific(
      Book,
      params[:filterrific],
      select_options: {
        sorted_by: Book.options_for_sorted_by,
        with_author_id: Author.pluck(:name, :id)
      },
      persistence_id: false, # Disables session persistence
      available_filters: [:sorted_by, :search_query, :with_author_id, :with_release_date_gte]
    ) || return

    @books = @filterrific.find.page(params[:page]) 

    respond_to do |format|
      format.html
      format.js # For ajax-based pagination
      format.csv { send_data generate_csv(@books), filename: 'books.csv' } # Add this line for CSV format responses
    end
  end

  def show
  end

  def new
    @book = Book.new
  end

  def edit
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: 'Book was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: 'Book was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_url, notice: 'Book was successfully destroyed.'
  end

  private

    def set_book
      @book = Book.find(params[:id])
    end

    def handle_record_not_found
      redirect_to books_url, alert: 'Book not found.'
    end

    def book_params
      params.require(:book).permit(:name, :release_date, :author_id)
    end

    def generate_csv(books)
      CSV.generate(headers: true) do |csv|
        csv << ['Book Name', 'Release Date', 'Author'] 
        books.each do |book|
          csv << [book.name, book.release_date, book.author.name] 
        end
      end
    end
end
