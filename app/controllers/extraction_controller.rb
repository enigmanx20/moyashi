class ExtractionController < ApplicationController
  before_action :prepare_project
  before_action :prepare_search, only: [:search, :extract]

  def show
    @columns = Label.where(project_id: @project.id).where("white_list != ?", "")
  end

  def search
    render :show
  end

  def extract
    if params[:ids].try(:any?)
      files = {}

      # parse params
      case params[:data_format]
      when "csv"
        delimiter = ","
        extension = "csv"
      else
        delimiter = "\t"
        extension = "tsv"
      end
      lower_limit = params[:m_z_lower_limit].try(:to_f) || @project.m_z_start
      higher_limit = params[:m_z_higher_limit].try(:to_f) || @project.m_z_end

      # check excluding m/z value whether it match m/z of project
      excluding_m_z = params[:exclude_m_z] ? params[:exclude_m_z].split(/,|\t/).map(&:to_f) : []

      # prepare files
      extracted_spectra, selectors = @project.extract_spectra(
                                        params[:group_name],
                                        params[:ids],
                                        lower_limit,
                                        higher_limit,
                                        params[:exclude_null],
                                        excluding_m_z
                                      )
      extracted_spectra = extracted_spectra.map{|v| v.join(delimiter)}.join("\n")
      file_name = "#{params[:group_name]}(#{params[:ids].size})mz(#{@project.m_z_to_a[selectors.min]}-#{@project.m_z_to_a[selectors.max]}).#{extension}"
      files[file_name] = extracted_spectra
      files["mz.tsv"] = details_of_selectors(selectors, @project, lower_limit, higher_limit)

      files["details_of_spectra.tsv"] = details_of_spectra(@records, @table_header)

      files["condition_of_extraction.tsv"] = condition_of_searching

      # save files to desktop
      dir_name = "funalyzer_#{Time.now.strftime("%y%m%d")}"
      dir_name << "_#{params[:group_name]}" if params[:group_name] != ""
      save_result_to_desktop(dir_name, files)

      flash[:notice] = "Extraction was completed succesfully. Extracted files have been saved on your Desktop."
    end

    render :show
  end



  private
    def prepare_project
      @project = Project.find(params[:id])
    end

    def prepare_search
      @columns = Label.where(project_id: @project.id).where("white_list != ?", "")
      @table_header = @project.table_header
      @records = @project.get_table_class.where(search_params)
    end

    def search_params
      return nil unless params[:search]
      params.require(:search)
    end

    def details_of_selectors(selectors, project, lower_limit, higher_limit)
      index_l = project.m_z_lower(lower_limit)
      index_h = project.m_z_higher(higher_limit)
      ids_excluded = (index_l..index_h).to_a - selectors.to_a

      m_z = project.m_z_to_a

      return result = <<EOF
m/z information of Project #{project.name}
start\t#{project.m_z_start.to_s}
end\t#{project.m_z_end.to_s}
inverval\t#{project.m_z_interval}

exact m/z of Project #{project.name}\t#{m_z.join("\t")}
m/z included in extracted file\t#{m_z.values_at(*selectors).join("\t")}
m/z excluded in extracted file\t#{m_z.values_at(*ids_excluded).join("\t")}
EOF
    end

    def details_of_spectra(records, header)
      result = ""
      result << header.join("\t") << "\n"
      records.each do |record|
        tmp = []
        header.each do |column|
          tmp << record.send(column)
        end
        result << tmp.join("\t") << "\n"
      end
      result
    end

    def condition_of_searching
      return "nothing particular" unless params[:search]

      result = "label name\tconditions\n"
      params[:search].each_pair do |name, ary|
        tmp = [name] + ary
        result << tmp.join("\t") << "\n"
      end
    end

    def save_result_to_desktop(dir_name, files={})
      Dir.chdir(Dir.home + "/Desktop") do
        i = 0
        dir_name_tmp = dir_name
        while Dir.exists?(dir_name_tmp)
          i += 1
          dir_name_tmp = dir_name + "-#{i.to_s}"
        end

        Dir.mkdir(dir_name_tmp, 0775)

        Dir.chdir(dir_name_tmp) do
          files.each_pair do |file_name, content|
            File.open(file_name, "w") do |file|
              file.puts content
            end
          end
        end
      end
    end
end
