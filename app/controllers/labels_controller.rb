class LabelsController < ApplicationController
  before_action :prepare_variables

  def index
    @labels = @project.labels_with_order
  end

  def update
    if @project.update(project_params)
      redirect_to labels_project_path(@project), notice: 'Labels have been updated successfully.'
    else
      render action: 'index'
    end
  end



  private
    def prepare_variables
      @project = Project.find(params[:id])
    end

    def project_params
      params[:project] && params.require(:project).permit(labels_attributes: [:id, :name, :white_list, :uniqueness, :_destroy, :label_order])
    end
end
