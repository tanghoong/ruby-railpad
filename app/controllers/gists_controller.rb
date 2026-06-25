class GistsController < ApplicationController
  before_action :set_gist, only: %i[show edit update destroy run]

  # GET /gists or /gists.json
  def index
    @gists = Gist.recent

    if params[:search].present?
      search_term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%"
      @gists = @gists.where(
        "title LIKE ? OR description LIKE ? OR code LIKE ?",
        search_term, search_term, search_term
      )
    end

    if params[:status].present?
      case params[:status]
      when "published" then @gists = @gists.published
      when "draft"     then @gists = @gists.unpublished
      end
    end

    @gists = @gists.load
  end

  # GET /gists/1 or /gists/1.json
  def show
  end

  # GET /gists/new
  def new
    @gist = Gist.new
  end

  # GET /gists/1/edit
  def edit
  end

  # POST /gists or /gists.json
  def create
    @gist = Gist.new(gist_params)

    respond_to do |format|
      if @gist.save
        format.html { redirect_to @gist, notice: "Gist was successfully created." }
        format.json { render :show, status: :created, location: @gist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gists/1 or /gists/1.json
  def update
    respond_to do |format|
      if @gist.update(gist_params)
        format.html { redirect_to @gist, notice: "Gist was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @gist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gists/1 or /gists/1.json
  def destroy
    @gist.destroy!

    respond_to do |format|
      format.html { redirect_to gists_path, notice: "Gist was successfully deleted.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /gists/1/run
  def run
    result = GistExecutionService.new(@gist).call
    @gist.update!(output: result[:output], output_at: Time.current)

    if result[:error]
      redirect_to @gist, alert: "Execution blocked or failed — see output below."
    else
      redirect_to @gist, notice: "Code executed successfully."
    end
  end

  private

  def set_gist
    @gist = Gist.find(params.expect(:id))
  end

  def gist_params
    params.expect(gist: [ :title, :description, :code, :language, :published, :article_id ])
  end
end
