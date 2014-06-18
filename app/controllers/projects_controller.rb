class ProjectsController < ApplicationController
  before_action :set_project, except: [:index, :new, :create]#, only: [:show, :edit, :update, :delete, :destroy, :show_delete_records]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all.order(created_at: :desc)
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @table_header = @project.table_header
    @records = @project.get_table_class.all
  end

  # GET /projects/new
  def new
    @project = Project.new(m_z_start: 10.0, m_z_end: 2000.0, m_z_interval: 0.1)
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to projects_path, notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    @project.avatar = nil if params[:delete_avatar]

    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
  end


  def show_delete_records
    @table_header = @project.table_header
    @records = @project.get_table_class.all
  end


  def delete_records
    unless params[:deleting_records]
      redirect_to delete_records_project_path(@project), notice: 'No records were selected.'
      return
    end

    ids = @project.get_table_class.pluck(:id)
    ids &= params[:deleting_records].map(&:to_i)

    @records = @project.get_table_class.find(ids)

    begin
      ActiveRecord::Base.transaction do
        @records.each do |record|
          record.destroy!
        end
      end
    rescue
      redirect_to delete_records_project_path(@project), notice: "Some errors have occured. Data couldn't be deleted."
    else
      redirect_to project_path(@project), notice: "Data have been deleted successfully."
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :comment, :m_z_start, :m_z_end, :m_z_interval, :avatar)
    end
end
