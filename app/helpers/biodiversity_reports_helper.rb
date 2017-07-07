module BiodiversityReportsHelper

  def link_to_toggle_soil_sample_fields(soil_sample)
    return unless soil_sample
    verb = soil_sample.has_temperature_or_ph_level? ? 'Omit' : 'Add'
    link_to "#{verb} soil sample", '#soil_sample_fields',
      {id: 'lnk-toggle-soil-sample-fields', 'data-toggle': 'collapse'}
  end

  # Append the 'in' class so that the initial state of the collapse is visible.
  # For example, when the user has entered soil sample values during a failed
  # create, failed update, or edit, the fields should be visible by default,
  # rather than collapsed.
  # Note: In Bootstrap 4, 'in' has changed to 'show'.
  def show_css_class(soil_sample)
    soil_sample&.has_temperature_or_ph_level? && 'in' # boostrapV4: 'show'
  end

  def link_to_add_fields(link_text, form_builder, association)
    new_object = form_builder.object.send(association).klass.new
    id = new_object.object_id
    fields = form_builder.fields_for(association, new_object, child_index: id) do |fields_builder|
      render(association.to_s.singularize + "_fields", f: fields_builder)
    end
    link_to(link_text, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

end
