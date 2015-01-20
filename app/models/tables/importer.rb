class Tables::Importer
  attr_reader :user, :application, :table, :rows
  attr_accessor :column_specs, :table_name

  TmpDir = "#{Rails.root}/tmp"

  def initialize(user, application, table=nil)
    @user = user
    @application = application
    @table = table
    @table_name = table.name if table.present?

    @rows = []
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
      col_spec = { action: :new_field, name: col, field: nil }
      col_spec[:action] = :ignore if col.blank?
      col_spec
    end
  end

  def column_specs=(specs)
    raise ArgumentError unless specs.is_a?(Array)
    @column_specs = specs.map &:with_indifferent_access
  end

  def new_table?
    table.blank?
  end

  def table_has_field?(field_guid)
    table.present? and table.fields.detect {|f| f.guid == field_guid}
  end

  def valid?
    return false if table_name.blank?

    headers = read_csv.first
    return false if headers.count != column_specs.count

    prev_identifier = nil
    column_specs.all? do |col|
      case col[:action].to_s
      when 'new_field'
        col[:name].present?
      when 'ignore'
        true
      when 'existing_field'
        table_has_field? col[:field]
      when 'existing_identifier'
        if prev_identifier.nil?
          prev_identifier = col
          table_has_field?(col[:field])
        else
          # more than one column used as identifier
          false
        end
      else
        # unknown action
        false
      end
    end
  end

  def execute!
    # Create/update table definition
    fields = new_fields
    if new_table?
      @table = Tables::Local.new table_name, Guid.new.to_s, fields
      application.tables << @table
    else
      @table = application.find_table(@table.guid)
      fields.each do |field|
        @table.fields << field
      end
    end
    application.save!

    # Import data
    inserted = 0
    failed = 0
    updated = 0

    elastic_record = application.elastic_record_for(@table)
    rows = read_csv
    rows.drop(1).each do |row|
      attrs = {}
      row.each_with_index do |cell, i|
        col_spec = column_specs[i]
        unless col_spec[:action] == 'ignore'
          field = col_spec[:field]
          attrs[field] = cell.to_f_if_looks_like_number
        end
      end
      record = elastic_record.new attrs
      if record.save
        inserted += 1
      else
        failed += 1
      end
    end

    {inserted: inserted, updated: updated, failed: failed}
  end

  def new_fields
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

