module AngularHelper
  def angular_templates(location)
    app_views_location = File.join(Rails.root, 'app', 'views')

    base_location = File.join(app_views_location, location)
    to_strip_for_client_path = base_location
    to_strip_for_view_path = app_views_location

    Dir[File.join(base_location, '**', '*.haml')].each do |f|
      next if File.basename(f).start_with? '_'
      client_path = f[to_strip_for_client_path.length+1..-1].sub(/\.haml$/, '')
      view_path = f[to_strip_for_view_path.length+1..-1].sub(/\.haml$/, '')

      haml_tag :script, type: 'text/ng-template', id: client_path do
        haml_concat render file: view_path
      end
    end
  end
end
