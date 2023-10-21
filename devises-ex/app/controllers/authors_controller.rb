class AuthorsController < ApplicationController
  before_action :set_author, only: [:show_authors, :edit_authors, :update_authors]
  before_action :authenticate_author!, except: [:show_authors]  # Devise authentication

  # ... other methods ...
  def index
    @filterrific = initialize_filterrific(
      Author,
      params[:filterrific],
      select_options: {
        sorted_by: Author.options_for_sorted_by
      }
    ) || return

    @authors = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
      format.csv { send_data Author.to_csv, filename: "authors-#{Date.today}.csv" }
    end
  end

  def show_authors
    # binding.break
   
  end


  def new_authors
    @author = Author.new
  end

  def edit_authors
  end

  # POST 
  def create_authors
    @author = Author.new(author_params)
  
    if @author.save
      sign_in(@author) unless current_author
      redirect_to author_show_authors_path(@author), notice: 'Author was successfully created.'
    else
      render :new_authors
    end
  end
  

  def update_authors
    # binding.break
    if @author.update(author_params)
      redirect_to author_show_authors_path(@author), notice: 'Author was successfully updated.'
    else
      render :edit_authors
    end
  end

  private

  def set_author
    @author = Author.find(params[:author_id])
  end

  def author_params
    params.require(:author).permit(:name, :email, :password, :password_confirmation)
  end
end
