class RscriptController < ApplicationController
# ==================================================
  # = PCA analysis
  # ==================================================
  def pca
  end

  def run_pca
    # argument checking
      
    unless check_params [:m_z_min, :m_z_max, :pcx, :pcy], [:file1, :file2]
      flash[:alert] = 'Not enough parameters.'
      render :pca
      return
    end

    extend Rscript::PCA

    run(
      params[:m_z_min],
      params[:m_z_max],
      params[:pcx],
      params[:pcy],
      params[:file1],
      params[:file2]
    )

    redirect_to rscript_pca_path, notice: 'Your command has been sent to R.'
  end
  
  private
    def check_params(strings, files)
      return false if strings.find_index{|v| params[v].empty? }
      return false if files.find_index{|v| params[v].nil? }
      true
    end
end
