module Rscript
  LIB_DIR = Rails.root.join('lib', 'rscript')
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



  module PCA
    # ------------------------------------------------
    # Rscript PCA.R
    # data1.txtとdata2.txtを読み込んで主成分分析を行い、第pcx主成分をx軸、第pcy主成分をy軸にとってプロットし、その後線形判別分析（LDA）を行う。
    # 読み込みの範囲（m/z）は、mozminからmozmaxまで。
    # ------------------------------------------------

    include Base

    W_DIR = LIB_DIR.join('pca')
    RSCRIPT_FILE = W_DIR.join('PCA.R')

    def run(m_z_min, m_z_max, pcx, pcy, file1, file2)
      # argument checking
      unless file1.respond_to?(:path) && file2.respond_to?(:path)
        raise ArgumentError, "Unexpected type of argument."
      end

      dir_name = Time.now.strftime("PCA_%y%m%d")
      files = [RSCRIPT_FILE.to_s]

      dest_dir = copy_files_to_output_base_dir(dir_name, files)

      [file1, file2].each_with_index do |file, i|
        FileUtils.cp(file.path, dest_dir + "/data#{i + 1}.txt")
      end

      Thread.new do
        Dir.chdir(dest_dir) do
          system("Rscript PCA.R  #{m_z_min}  #{m_z_max}")
        end
      end
    end
  end
end