VersionFilePath = "#{::Rails.root.to_s}/VERSION"

Mbuilder::Application.config.send "version_name=", if FileTest.exists?(VersionFilePath) then
  IO.read(VersionFilePath)
else
  ENV["MBUILDER_VERSION"] || "development"
end
