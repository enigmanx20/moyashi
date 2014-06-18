class Label < ActiveRecord::Base
  ReservedNames = %w[id project_id created_at updated_at] + Project::Columns_for_spectra

  belongs_to :project

  validates(
    :name,
    uniqueness: {scope: :project_id, message: "It's already existing label."},
    presence: {message: "Label name can't be blank."}
  )
  validate :check_reserved_name, :validates_white_list
  validates :project_id, presence: true
  
  before_validation :normalize_white_list
  after_save :reload_white_list
  after_destroy :reload_white_list

  after_create :adjust_column_in_record_table
  after_destroy :adjust_column_in_record_table



  # white_list cache management
  @white_list = nil

  def self.white_list(project_id)
    reload_white_list unless @white_list
    @white_list[project_id.to_i]
  end

  # inputの際に.gsub(/\n\n+/, "\n")をかける様にしておく。
  def self.reload_white_list
    @white_list = Hash.new{|hash, key| hash[key] = Hash.new([]) }

    self.all.each do |label|
      @white_list[label.project_id.to_i][label.name] = label.white_list.split("\n")
    end

    # logger.info "Label.white_list was reloaded. #{@white_list.inspect}" #for debug
  end



  private
    def check_reserved_name
      if ReservedNames.include?(name)
        errors.add name.to_sym, "[#{ReservedNames.join(", ")}] are reserved label names."
      end
    end

    def normalize_white_list
      self.white_list = white_list.gsub(/\r\n?/, "\n").gsub(/\n{2,}/, "\n").gsub(/^\n/, "")
    end

    def validates_white_list
      new_white_list = white_list.split("\n")
      old_white_list = white_list_was ? white_list_was.split("\n") : []

      deleted_entry = old_white_list - new_white_list

      if deleted_entry.any? && project.get_table_class.where(name.to_sym => deleted_entry).any?
        errors.add(name.to_sym, "Deleting [#{deleted_entry.join(", ")}] entries of #{name} label prohibited the label from being saved because some data have some of these label.")
        self.white_list = white_list_was
      end
    end

    # re-cache the white_list after save
    def reload_white_list
      self.class.reload_white_list
    end



    # after_create, after_destroy
    def adjust_column_in_record_table
      labels = Label.where(project_id: project_id).pluck(:name)
      table_columns = ActiveRecord::Base.connection.columns(project.get_table_name).map(&:name) - ReservedNames
      project = self.project
      
      # Add column which is not exist
      (labels - table_columns).each do |column|
        # This block will be evaluated within context of ActiveRecord::Schema object.
        # Be careful, self is not Label object in this block.
        ActiveRecord::Schema.define do
          add_column project.get_table_name, column, :string
        end
      end

      # remove column which is not needed
      (table_columns - labels).each do |column|
        # this block will be evaluated within context of ActiveRecord::Schema object.
        # Be careful, self is not Label object in this block.
        ActiveRecord::Schema.define do
          remove_column project.get_table_name, column
        end
      end

      # reset all the cached information about columns
      self.project.get_table_class.reset_column_information
    end
end