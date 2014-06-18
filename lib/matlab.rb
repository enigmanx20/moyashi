module Matlab
  LIB_DIR = Rails.root.join('lib', 'matlab')
  OUTPUT_BASE_DIR = Pathname.new(Dir.home).join('Desktop')



  module Base
    def copy_files_to_output_base_dir(dir_name, files=[])
      # make target directory for copying
      Dir.chdir(Dir.home + "/Desktop") do
        i = 0
        dir_name_tmp = dir_name
        while Dir.exists?(dir_name_tmp)
          i += 1
          dir_name_tmp = dir_name + "-#{i.to_s}"
        end
        dir_name = dir_name_tmp

        # make directory
        Dir.mkdir(dir_name, 0775)
      end

      dest_dir = Dir.home + '/Desktop' + "/#{dir_name}" 

      FileUtils.copy(files, dest_dir)

      dest_dir
    end
  end



  module PCA_LDA
    # ------------------------------------------------
    # matlab -r 'PCA_LDA(mozmin, mozmax, pcx, pcy)'
    # data1.txtとdata2.txtを読み込んで主成分分析を行い、第pcx主成分をx軸、第pcy主成分をy軸にとってプロットし、その後線形判別分析（LDA）を行う。
    # 読み込みの範囲（m/z）は、mozminからmozmaxまで。
    # ------------------------------------------------

    include Base

    W_DIR = LIB_DIR.join('pca_lda')
    MATLAB_FILE = W_DIR.join('PCA_LDA.m')

    def run(m_z_min, m_z_max, pcx, pcy, file1, file2)
      # argument checking
      unless file1.respond_to?(:path) && file2.respond_to?(:path)
        raise ArgumentError, "Unexpected type of argument."
      end

      dir_name = Time.now.strftime("PCA-LDA_%y%m%d")
      files = [MATLAB_FILE.to_s]

      dest_dir = copy_files_to_output_base_dir(dir_name, files)

      [file1, file2].each_with_index do |file, i|
        FileUtils.cp(file.path, dest_dir + "/data#{i + 1}.txt")
      end

      Thread.new do
        Dir.chdir(dest_dir) do
          system("matlab -r 'PCA_LDA(#{m_z_min}, #{m_z_max}, #{pcx}, #{pcy})'")
        end
      end
    end
  end



  module PCA_QDA
    # ------------------------------------------------
    # matlab -r 'PCA_QDA(mozmin, mozmax, pcx, pcy)'
    # 主成分分析を行い、第pcx主成分をx軸、第pcy主成分をy軸にとってプロットし、その後二次判別分析（QDA）を行う。
    # 読み込みの範囲（m/z）は、mozminからmozmaxまで。
    # ------------------------------------------------

    include Base

    W_DIR = LIB_DIR.join('pca_qda')
    MATLAB_FILE = W_DIR.join('PCA_QDA.m')

    def run(m_z_min, m_z_max, pcx, pcy, file1, file2)
      # argument checking
      unless file1.respond_to?(:path) && file2.respond_to?(:path)
        raise ArgumentError, "Unexpected type of argument."
      end

      dir_name = Time.now.strftime("PCA-QDA_%y%m%d")
      files = [MATLAB_FILE.to_s]

      dest_dir = copy_files_to_output_base_dir(dir_name, files)

      [file1, file2].each_with_index do |file, i|
        FileUtils.cp(file.path, dest_dir + "/data#{i + 1}.txt")
      end

      Thread.new do
        Dir.chdir(dest_dir) do
          system("matlab -r 'PCA_QDA(#{m_z_min}, #{m_z_max}, #{pcx}, #{pcy})'")
        end
      end
    end
  end



  module WilcoxonRankSumTest
    # ------------------------------------------------
    # matlab -r 'Rank_sum(mozmin, mozmax)'
    # mozminからmozmaxまでの各m/zについてWilcoxon rank sum testを行い、中央値とp値の情報をファイル出力する 。
    # ------------------------------------------------

    include Base

    W_DIR = LIB_DIR.join('rank_sum')
    MATLAB_FILE = W_DIR.join('Rank_sum.m')

    def run(m_z_min, m_z_max, file1, file2)
      # argument checking
      unless file1.respond_to?(:path) && file2.respond_to?(:path)
        raise ArgumentError, "Unexpected type of argument."
      end

      dir_name = Time.now.strftime("Wilcoxon_Rank-Sum_test_%y%m%d")
      files = [MATLAB_FILE.to_s]

      dest_dir = copy_files_to_output_base_dir(dir_name, files)

      [file1, file2].each_with_index do |file, i|
        FileUtils.cp(file.path, dest_dir + "/data#{i + 1}.txt")
      end

      Thread.new do
        Dir.chdir(dest_dir) do
          system("matlab -r 'Rank_sum(#{m_z_min}, #{m_z_max})'")
        end
      end
    end
  end



  module WelchTTest
    # ------------------------------------------------
    # matlab -r 'Rank_sum(mozmin, mozmax)'
    # mozminからmozmaxまでの各m/zについてWilcoxon rank sum testを行い、中央値とp値の情報をファイル出力する 。
    # ------------------------------------------------

    include Base

    W_DIR = LIB_DIR.join('welch_ttest')
    MATLAB_FILE = W_DIR.join('Welch_ttest.m')

    def run(m_z_min, m_z_max, file1, file2)
      # argument checking
      unless file1.respond_to?(:path) && file2.respond_to?(:path)
        raise ArgumentError, "Unexpected type of argument."
      end

      dir_name = Time.now.strftime("Welch_T-test_%y%m%d")
      files = [MATLAB_FILE.to_s]

      dest_dir = copy_files_to_output_base_dir(dir_name, files)

      [file1, file2].each_with_index do |file, i|
        FileUtils.cp(file.path, dest_dir + "/data#{i + 1}.txt")
      end

      Thread.new do
        Dir.chdir(dest_dir) do
          system("matlab -r 'Welch_ttest(#{m_z_min}, #{m_z_max})'")
        end
      end
    end
  end
end