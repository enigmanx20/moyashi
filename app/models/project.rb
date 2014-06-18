class Project < ActiveRecord::Base
  # a proc object to define new records table of projects
  Record = Proc.new{
    # = Class Information
    # Pluralization format to take table name from class name is defined in /app/config/initializers/inflections.rb

    belongs_to :project

    serialize :spectrum

    validates :spectrum, presence: {message: "Spectrum is mandatory."}
    validates(
      :spectrum_sample_id,
      presence: {message: "Spectrum sample id (file name of spectrum) is empty."},
      uniqueness: {message: "Spectrum sample id (file name of spectrum) exists already in Database. Submit another spectrum or modify the sample id."}
    )
    validates :project_id, presence: true
    validate :check_white_list, :check_uniqueness

    # Validations for spectrum
    validate :check_spectrum_format
    before_save :convert_spectrum_format, :culculate_total_intensity



    # = functions for the Lab
    def set_spectrum(source)
      # normalization
      spectrum = source.chomp.gsub(/\r\n/, "\n").gsub(/\ *[,\t]\ */, "\t")
      spectrum = spectrum.split("\n").map{|v| v.split("\t") }[0..1]

      # take first 2 lines
      if spectrum[0].size == spectrum[1].size
        method_for_m_z = self.project.m_z_significant_figures_max == 0 ? :to_i : :to_f

        spectrum[0].map!{|v| v == "" ? nil : v.send(method_for_m_z) }
        spectrum[1].map!{|v| v == "" ? nil : v.to_i }

        spectrum = spectrum.transpose
        spectrum.shift
      else
        raise ArgumentError, "Invalid spectrum format. Sizes of each line; #{spectrum[0].size}, #{spectrum[1].size}"
      end
      self.spectrum = spectrum
    end

    def set_spectrum_sample_id(input)
      # normalization
      input = source.gsub(/\r\n/, "\n").gsub(/\ *[,\t]\ */, "\t")

      if /.*?\n(.*?)(\t.*?)?[\n\z]/ =~ input
        self.spectrum_sample_id = $1
      end
    end

    def spectrum_re_allocate_m_z(first_m_z=nil)
      first_m_z = first_m_z.is_a?(Numeric) ? first_m_z : self.project.m_z_start
      if spectrum
        significant_figure = self.project.m_z_significant_figures.values.max

        spectrum.map!.with_index do |(m_z, intensity), i|
          new_m_z = (first_m_z + self.project.m_z_interval * i).round(significant_figure)
          [new_m_z, intensity]
        end
      else
        false
      end
    end



    private
      def check_white_list
        Label.white_list(project_id).each_pair do |column_name, white_list|
          if white_list != [] && (not white_list.include?(send(column_name)) )
            errors.add(column_name.to_sym, "invalid argument")
          end
        end
      end

      def check_uniqueness
        Label.where(project_id: project_id).each do |label|
          next unless label.uniqueness
          if 0 < self.class.where(label.name.to_sym => self.send(label.name.to_sym)).count
            errors.add(label.name.to_sym, "#{label.name} label must be unique. \"#{self.send(label.name.to_sym)}\" is already exists.")
          end
        end
      end

      # = Format of Spectrum
      # Spectrum before validation
      # [ [10.0, 10], [10.1, 10], ... ]  #=> [[m/z[0], intensity[0] ],[m/z[1], intensity[1] ], ... ]
      #
      # Spectrum after validaiton
      # It will be converted to this format.
      # [0, 0, 6121, 1230, ... ] == [ [10.0, 10], [10.1, 10], ... ].map{|v| v[1]}
      def check_spectrum_format
        return unless spectrum && spectrum.first.class == Array

        # make m/z list for check
        m_z = self.project.m_z_to_a
        check_list = Hash[*m_z.zip(Array.new(m_z.size, 0)).flatten]


        # check whether all m/z are submited
        spectrum.each do |m_z, intensity|
          if check_list[m_z]
            check_list[m_z] += 1
          else
            if errors.count{|sym, msg| /Invalid m\/z was detected/ =~ msg } <= 20
              errors.add(:Spectrum, "Invalid m/z was detected: #{m_z.to_s} m/z.")
            end
          end

          # check NULL
          if intensity == nil
            errors.add(:Spectrum, "NULL was detected at #{m_z.to_s} m/z.")
          elsif not /\A-?([1-9]\d*|0)(\.\d+)?\z/ =~ intensity.to_s
            if errors.count{|sym, msg| /Invalid intensity was detected/ =~ msg } <= 20
              errors.add(:Spectrum, "Invalid intensity was detected: #{m_z.to_s} m/z, #{intensity.to_s} intensity.")
            end
          end
        end

        check_list.each_pair do |m_z, count|
          if count == 0
            # errors.add(:Spectrum, "No data exists at #{m_z} m/z.") # Comment outed to permit NULL in DB record.
          elsif count > 1
            errors.add(:Spectrum, "There are plural intensity at #{m_z.to_s} m/z.")
          end
        end
      end

      def convert_spectrum_format
        # convert format after validation
        # [[10.2, 1231], [10.3, 83124], ... ]
        # => [[10.0, nil], [10.1, nil], [10.2, 1231], [10.3, 83124], ... ]
        # => [nil, nil, 1231, 83124, ... ]
        return true unless spectrum && spectrum.first.class == Array

        hash = Hash.new(nil)
        result = []

        spectrum.each do |m_z, intensity|
          hash[m_z] = intensity
        end

        self.project.m_z_to_a.each do |m_z|
          result << hash[m_z]
        end

        self.spectrum = result
      end

      def culculate_total_intensity
        self.spectrum_total_intensity = spectrum.inject(0){|s,i| i ? s+i : s}
      end
  }

  Columns_for_spectra = %w[spectrum spectrum_sample_id spectrum_total_intensity]



  # define record classes for initializing
  ActiveRecord::Base.connection.tables.each do |table_name|
    next unless /records(\d+)/ =~ table_name
    class_name = "Record#{$1}"
    self.const_set class_name, Class.new(ActiveRecord::Base, &Record)
    Rails.logger.info "constant #{class_name} was defined."
  end



  has_many :labels, dependent: :destroy
  accepts_nested_attributes_for(
    :labels,
    reject_if: :all_blank,
    allow_destroy: true
  )

  has_attached_file(
    :avatar,
    :styles => {
      :medium => "300x300#",
      :thumb => "100x100#"
    },
    :default_url => "/images/avatar/:style/missing.png"
  )
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  validates(
    :name,
    uniqueness: {message: "That project name exists already."},
    presence: {message: "Project name can't be blank."}
  )
  validate :check_m_z_information

  after_create :create_records_table
  after_destroy :destroy_records_table



  # get class which represents table of this project
  def get_table_class
    self.class.const_get("Record#{id}")
  end

  # get name of table eof this project
  def get_table_name
    "project_records#{id}"
  end

  def labels_with_order
    Label.where(project_id: id).order(:label_order)
  end

  def label_names_with_order
    Label.where(project_id: id).order(:label_order).pluck(:name)
  end

  def table_header
    header = %w[id] + label_names_with_order + %w[spectrum_sample_id spectrum_total_intensity created_at updated_at]
    header.map(&:to_sym)
  end

  # return Array object of project's m/z information
  def m_z_to_a
    return @m_z_ary if @m_z_ary
    @m_z_ary = []
    significant_figures = m_z_significant_figures.values.max

    tmp = m_z_start
    i = 0
    while tmp <= m_z_end
      @m_z_ary << tmp
      i += 1
      tmp = (m_z_start + m_z_interval * i).round(significant_figures)
    end

    @m_z_ary.freeze
  end

  def m_z_to_h
    return @m_z_hash if @m_z_hash
    @m_z_hash = {}
    m_z_to_a.each_with_index do |m_z, i|
      @m_z_hash[m_z] = i
    end

    @m_z_hash.freeze
  end

  def m_z_significant_figures
    m_z_property = {
      start:    self.m_z_start,   # default: 10.0
      end:      self.m_z_end,     # default: 2000.0
      interval: self.m_z_interval # default: 0.1
    }

    m_z_property.each_pair do |property, float|
      /\A([1-9]\d*|0)(\.(\d+))?\z/ =~ float.to_s
      m_z_property[property] = $3 ? $3.length : 0
    end
    m_z_property
  end

  def m_z_significant_figures_max
    m_z_significant_figures.values.max
  end

  def m_z_index(num)
    m_z_to_a.index(num)
  end

  def m_z_lower(lower_limit)
    m_z_index(lower_limit) || m_z_start
  end

  def m_z_higher(higher_limit)
    m_z_index(higher_limit) || m_z_end
  end

  def extract_spectra(group_name, ids, lower_limit=nil, higher_limit=nil, except_null=nil, excluding_m_z=[])
    # initializing
    except_null = except_null && true

    result = []
    m_z = m_z_to_a

    # parse limits
    index_l = m_z_lower(lower_limit)
    index_h = m_z_higher(higher_limit)
    unless index_l && index_h
      raise ArgumentError, "Invalid argument for project; #{name}"
    end

    # take spectra to process
    spectra = get_table_class.where(id: ids).pluck(:id, :spectrum)
    if except_null || excluding_m_z.any?
      # prepare for null check
      ids_null = {}
      (index_l..index_h).each do |i|
        ids_null[i] = true
      end

      excluding_m_z.each do |m_z|
        ids_null[m_z_to_h[m_z]] = false
      end

      # null check
      spectra.each do |id, spectrum|
        spectrum[index_l..index_h].each_with_index do |intensity, i|
          i += index_l
          next unless ids_null[i]
          ids_null[i] = false unless intensity
        end
      end

      selectors = ids_null.keep_if{|k,v| v}.keys
    else
      selectors = index_l..index_h
    end

    result << ["#{group_name}(#{ids.size})", "m/z", *m_z.values_at(*selectors)]

    spectra.each do |id, spectrum|
      result << [nil, id, *spectrum.values_at(*selectors) ]
    end

    return result.transpose, selectors
  end



  private
    def check_m_z_information
      %w[m_z_start m_z_end m_z_interval].each do |v|
        # debug code. This can be deleted.
        # logger.info self.send(v).inspect
        # logger.info self.send("#{v}_before_type_cast").inspect

        case self.send("#{v}_before_type_cast")
        when /\A-?([1-9]\d*|0)(\.\d+)?\z/, Float
          # it's ok.
          if self.send(v) <= 0
            errors.add v.to_sym, "Please enter integer or decimal greater than 0."
          end
        when nil
          errors.add v.to_sym, "#{v.gsub("m_z_", "m/z ")} can't be blank."
        else
          errors.add v.to_sym, "Please enter integer or deciaml for m/z."
        end
      end

      if m_z_start >= m_z_end
        erros.add :m_z_end, "m/z end must be greater than m/z start."
      end
    end

    def create_records_table
      connection.create_table get_table_name do |t|
        # Reference Project::Columns_for_spectra
        t.text :spectrum

        # string型にして置かないとvalidates uniqueness: の為の検索に、空白を含んだ文字列が引っかからない。
        # ActiveRecordでなくSqlite3側の問題。詳細理由は不明。
        t.string :spectrum_sample_id
        t.integer :spectrum_total_intensity

        t.references :project
        t.timestamps
      end
      create_table_class
    end

    def create_table_class
      self.class.const_set "Record#{id}", Class.new(ActiveRecord::Base, &Record)
    end

    def destroy_records_table
      connection.drop_table get_table_name
    end
end

