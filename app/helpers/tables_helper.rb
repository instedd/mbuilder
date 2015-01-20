module TablesHelper
  def table_importer_to_angular(importer, column_specs)
    {
      applicationId: importer.application.id,
      tableGuid: (importer.table.guid rescue nil),
      fields: (importer.table.fields rescue []),
      columnSpecs: column_specs
    }.to_json_oj
  end
end

