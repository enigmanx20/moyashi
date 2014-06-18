class MatlabController < ApplicationController
  # ==================================================
  # = PCA-LDA analysis
  # ==================================================
  def pca_lda
  end

  def run_pca_lda
    # argument checking
      
    unless check_params [:m_z_min, :m_z_max, :pcx, :pcy], [:file1, :file2]
      flash[:alert] = 'Not enough parameters.'
      render :pca_lda
      return
    end

    extend Matlab::PCA_LDA

    run(
      params[:m_z_min],
      params[:m_z_max],
      params[:pcx],
      params[:pcy],
      params[:file1],
      params[:file2]
    )

    redirect_to matlab_pca_lda_path, notice: 'Your command has been sent to MATLAB.'
  end



  # ==================================================
  # = PCA-QDA analysis
  # ==================================================
  def pca_qda
  end

  def run_pca_qda
    # argument checking
      
    unless check_params [:m_z_min, :m_z_max, :pcx, :pcy], [:file1, :file2]
      flash[:alert] = 'Not enough parameters.'
      render :pca_qda
      return
    end

    extend Matlab::PCA_QDA

    run(
      params[:m_z_min],
      params[:m_z_max],
      params[:pcx],
      params[:pcy],
      params[:file1],
      params[:file2]
    )

    redirect_to matlab_pca_qda_path, notice: 'Your command has been sent to MATLAB.'
  end



  # ==================================================
  # = Wilcoxon Rank-sum test analysis
  # ==================================================
  def wilcoxon_rank_sum_test
  end

  def run_wilcoxon_rank_sum_test
    # argument checking
      
    unless check_params [:m_z_min, :m_z_max], [:file1, :file2]
      flash[:alert] = 'Not enough parameters.'
      render :wilcoxon_rank_sum_test
      return
    end

    extend Matlab::WilcoxonRankSumTest

    run(
      params[:m_z_min],
      params[:m_z_max],
      params[:file1],
      params[:file2]
    )

    redirect_to matlab_wilcoxon_rank_sum_test_path, notice: 'Your command has been sent to MATLAB.'
  end



  # ==================================================
  # = Welch T-test analysis
  # ==================================================
  def welch_ttest
  end

  def run_welch_ttest
    # argument checking
      
    unless check_params [:m_z_min, :m_z_max], [:file1, :file2]
      flash[:alert] = 'Not enough parameters.'
      render :wilcoxon_rank_sum_test
      return
    end

    extend Matlab::WelchTTest

    run(
      params[:m_z_min],
      params[:m_z_max],
      params[:file1],
      params[:file2]
    )

    redirect_to matlab_welch_ttest_path, notice: 'Your command has been sent to MATLAB.'
  end



  private
    def check_params(strings, files)
      return false if strings.find_index{|v| params[v].empty? }
      return false if files.find_index{|v| params[v].nil? }
      true
    end
end
