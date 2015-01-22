class Tables::Importer
  attr_reader :user, :application, :table
  attr_accessor :rows, :column_specs, :table_name

  include ActiveModel::Validations

  TmpDir = "#{Rails.root}/tmp"

  def initialize(user, application, table=nil)
    @user = user
    @application = application
    @table = table
    @table_name = table.name if table.present?

    @rows = []
    @column_specs = []
  end

  def save_csv(file_param)
    # TODO: don't read all the file in memory at once (use IO.copy_stream?)
    contents = file_param.read

    File.open(csv_filename, "wb") do |f|
      f.write contents
    end

    # Validate that all rows have the same length
    rows = read_csv
    rows.size > 1 and rows.all? {|row| row.size == rows[0].size}
    # TODO: report reason for invalid file
  end

  def guess_column_specs
    headers = read_csv.first
    headers.map do |col|
      guessed_field = find_table_field_by_name(col)
      col_spec = if guessed_field
                   {action: 'existing_field', name: guessed_field.name, field: guessed_field.guid}
                 else
                   {action: 'new_field', name: col.strip, field: nil}
                 end
      col_spec[:action] = 'ignore' if col.blank?
      col_spec
    end
  end

  def column_specs=(specs)
    raise ArgumentError unless specs.is_a?(Array)
    @column_specs = specs.map &:with_indifferent_access
  end

  def guess_column_specs!
    self.column_specs = guess_column_specs
  end

  def new_table?
    table.blank?
  end

  def table_has_field?(field_guid)
    table.present? and table.fields.detect {|f| f.guid == field_guid}
  end

  def find_table_field_by_name(name)
    name = name.strip.downcase
    table.presence and table.fields.detect {|f| f.name.downcase == name}
  end

  def find_table_record(elastic_record, field_guid, value)
    value = value.to_f_if_looks_like_number
    candidates = elastic_record.where(field_guid => value).to_a
    candidates.detect do |candidate|
      candidate.properties[field_guid] == value
    end
  end

  validate do
    errors.add(:table_name, 'Table name cannot be blank') unless table_name.present?

    headers = read_csv.first
    errors.add(:base, 'Number of column specifications and imported columns must match') if headers.count != column_specs.count

    if column_specs.select {|col| col[:action].to_s == 'existing_identifier'}.count > 1
      errors.add(:base, "Only one identifier column is allowed")
    end

    column_specs.each_with_index do |col, i|
      error_key = "column_specs[#{i}]"
      case col[:action].to_s
      when 'ignore'
      when 'new_field'
        errors.add(error_key, 'is missing a name') unless col[:name].present?
      when 'existing_field', 'existing_identifier'
        errors.add(error_key, 'has no field selected') unless table_has_field?(col[:field])
      else
        errors.add(error_key, 'action is invalid')
      end
    end
  end

  def execute!
    # Create/update table definition
    new_imported_fields = prepare_column_specs
    if new_table?
      @table = Tables::Local.new table_name, Guid.new.to_s, new_imported_fields
      application.tables << @table
    else
      @table = application.find_table(@table.guid)
      new_imported_fields.each do |field|
        @table.fields << field
      end
    end
    application.save!

    # Import data
    inserted = 0
    failed = 0
    updated = 0

    identifier_index = column_specs.find_index {|col| col[:action] == 'existing_identifier'}
    identifier_spec = column_specs[identifier_index] unless identifier_index.nil?

    elastic_record = application.elastic_record_for(@table)
    rows = read_csv
    rows.drop(1).each do |row|
      # Lookup record to update if using a column as identifier
      record = find_table_record(elastic_record, identifier_spec[:field], row[identifier_index]) if identifier_index
      record = elastic_record.new if record.nil?

      row.each_with_index do |cell, i|
        col_spec = column_specs[i]
        unless col_spec[:action] == 'ignore'
          field = col_spec[:field]
          record.properties[field] = cell.to_f_if_looks_like_number
        end
      end
      is_new = !record.persisted?

      if record.save
        if is_new
          inserted += 1
        else
          updated += 1
        end
      else
        failed += 1
      end
    end

    {inserted: inserted, updated: updated, failed: failed}
  end

  # Returns an array of TableField objects for new fields *and* updates field/guid attribute
  def prepare_column_specs
    column_specs.select do |col|
      col[:action] == 'new_field'
    end.map do |col|
      field_guid = Guid.new.to_s
      col[:field] = field_guid
      TableFields::Local.new col[:name], field_guid, ''
    end
  end

  def read_csv
    if @rows.blank?
      CSV.foreach(csv_filename) do |row|
        @rows << row
      end
    end
    @rows
  end

  def csv_filename
    "#{TmpDir}/#{user.id}-#{application.id}-#{table.guid rescue 'NEW'}.csv"
  end
end

