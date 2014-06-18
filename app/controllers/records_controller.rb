class RecordsController < ApplicationController
  before_action :set_project, :set_labels
  before_action :set_record, only: [:show, :edit, :update, :destroy]

  # GET /records/1
  # GET /records/1.json
  def show
    @table_header = @project.table_header
  end

  # GET /records/new
  def new
    @record = @project.get_table_class.new()
    @record.project_id = @project.id
  end

  def new_next
    attributes = @project.get_table_class.last.try(:attributes).try(:reject) do |key, value|
      not Label.white_list(@project.id).keys.map(&:to_s).include?(key.to_s)
    end
    @record = @project.get_table_class.new(attributes)
    @record.project_id = @project.id

    render :new
  end

  # GET /records/1/edit
  def edit
  end

  # POST /records
  # POST /records.json
  def create
    p params
    @record = @project.get_table_class.new(record_params)
    @record.project_id = @project.id

    respond_to do |format|
      if parse_spectrum_params && @record.save
        format.html { redirect_to new_next_project_records_path(@project), notice: 'Record was successfully created. Enter next.' }
        # format.json { render action: 'show', status: :created, location: @record }
      else
        format.html { render action: 'new' }
        # format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /records/1
  # PATCH/PUT /records/1.json
  def update
    
    respond_to do |format|
      if parse_spectrum_params && @record.update(record_params)
        format.html { redirect_to project_path(@project), notice: 'Record was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        # format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    @record.destroy
    respond_to do |format|
      format.html { redirect_to project_path(@project) }
      # format.json { head :no_content }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_record
      # @record = Record.find(params[:id])
      @record = @project.get_table_class.find(params[:id])
    end

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_labels
      @labels = Label.where(project_id: @project.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def record_params
      if params[:record]
        params.require(:record).permit(*Label.white_list(@project.id).keys.map(&:to_sym))
      else
        nil
      end
    end

    def parse_spectrum_params
      if params[:spectrum]

        case params[:spectrum_format]
        when "normalized"
          source = params[:spectrum].read
        when "raw"
          source = SpectrumUtil::Converter.normalize_raw_data(params[:spectrum].read)
        else
          raise ArgumentError, "Invalid spectrum format"
        end

        @record.set_spectrum(source)
        @record.spectrum_sample_id = File.basename(params[:spectrum].original_filename, ".*")

        if params[:spectrum_re_allocation]
          if /\A-?([1-9]\d*|0)(\.\d+)?\z/ =~ params[:spectrum_first_m_z] && @project.m_z_to_a.include?(params[:spectrum_first_m_z].to_f)
            first_m_z = params[:spectrum_first_m_z].to_f
            @record.spectrum_re_allocate_m_z(first_m_z)
          else
            @record.errors.add :spectrum, "Invalid m/z to re-allocate was submitted. It can't be found in m/z of this project."
            return false
          end
        end  
      end
      
      true
    end
end
