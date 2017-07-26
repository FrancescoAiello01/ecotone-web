require 'rails_helper'

RSpec.feature "User edits a biodiversity report" do

  let(:user) { create(:user) }
  let(:biodiversity_report) { create(:biodiversity_report, author: user) }

  before do
    sign_in(user)
  end

  context "without an existing soil sample" do

    before do
      visit edit_biodiversity_report_path(biodiversity_report)
    end

    scenario "providing valid soil sample data" do
      fill_in('pH level', with: '10')
      fill_in('biodiversity_report_soil_sample_attributes_temperature', with: '100')
      fill_in('Moisture', with: '3')
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully updated."
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_no_content('No soil sample')
      expect(page).to have_content('pH Level: 10')
      expect(page).to have_content('Temperature: 100')
      expect(page).to have_content('Moisture: 3.0')
    end

  end

  context "with an existing soil sample" do

    # Coupled with the `let(:biodiversity_report)` above, creates a biodiversity
    # report with the existing logged in user and a soil sample. Because of the
    # way FactoryGirl creates associated models, do it this way, rather than
    # with a trait that sets the soil_sample association in the biodiversity_report
    # factory and `create(:biodiversity_report, :with_soil_sample, author: user )`.
    let!(:soil_sample) { create(:soil_sample, biodiversity_report: biodiversity_report) }

    before do
      visit edit_biodiversity_report_path(biodiversity_report)
    end

    scenario "omitting the existing soil sample" do
      fill_in('pH level', with: '')
      fill_in('biodiversity_report_soil_sample_attributes_temperature', with: '')
      fill_in('Moisture', with: '')
      page.find('#biodiversity_report_soil_sample_attributes__destroy', visible: false).set('1')
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully updated."
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_content('No soil sample')
      expect(page).to have_no_content('pH Level: 1.5') # Set by soil_sample factory
      expect(page).to have_no_content('Temperature: 20.5') # Set by soil_sample factory
      expect(page).to have_no_content('Moisture: 3.5') # Set by soil_sample factory
    end

    scenario "modifying the existing soil sample providing valid data" do
      fill_in('pH level', with: '2')
      fill_in('biodiversity_report_soil_sample_attributes_temperature', with: '99')
      fill_in('Moisture', with: '1')
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully updated."
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_no_content('No soil sample')
      expect(page).to have_content('pH Level: 2')
      expect(page).to have_content('Temperature: 99')
      expect(page).to have_content('Moisture: 1.0')
    end

    scenario "modifying the existing soil sample providing invalid data" do
      fill_in('pH level', with: '-1')
      fill_in('biodiversity_report_soil_sample_attributes_temperature', with: 'fake')
      fill_in('Moisture', with: '-1')
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: /The form contains .* errors./
      expect(page.find("#error_explanation")).to have_content("Soil sample ph level must be greater than or equal to 0")
      expect(page.find("#error_explanation")).to have_content("Soil sample temperature is not a number")
      expect(page).to have_css('#soil_fields.collapse.in')
      expect(page).to have_field('pH level', with: '-1')
      expect(page).to have_field('biodiversity_report_soil_sample_attributes_temperature', with: 'fake')
      expect(page).to have_field('Moisture', with: '-1')
    end

  end

  context "without an existing fungi sample" do

    before do
      visit edit_biodiversity_report_path(biodiversity_report)
    end

    scenario "providing valid fungi sample data" do
      within('.fungi_sample') do
        fill_in('Location within plot', with: 'on a rock')
        fill_in('Size', with: '1.5')
        fill_in('Description', with: 'description of fungi')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully updated."
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_no_content('No fungi sample')
      expect(page).to have_content('Location within plot: on a rock')
      expect(page).to have_content('Size: 1.5')
      expect(page).to have_content('Description: description of fungi')
    end

  end

  context "with an existing fungi sample" do

    let!(:fungi_sample) { create(:fungi_sample, biodiversity_report: biodiversity_report) }

    before do
      visit edit_biodiversity_report_path(biodiversity_report)
    end

    scenario "omitting the existing fungi sample" do
      within('.fungi_sample') do
        fill_in('Location within plot', with: '')
        fill_in('Size', with: '')
        fill_in('Description', with: '')
      end
      page.find('#biodiversity_report_fungi_sample_attributes__destroy', visible: false).set('1')
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully updated."
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_content('No fungi sample')
      expect(page).to have_no_content('Location_within_plot: on a rock') # Set by fungi_sample factory
      expect(page).to have_no_content('Size: 1.5') # Set by fungi_sample factory
      expect(page).to have_no_content('Description: description of fungi sample') # Set by fungi_sample factory
    end

    scenario "modifying the existing fungi sample providing valid data" do
      within('.fungi_sample') do
        fill_in('Location within plot', with: 'on a rock')
        fill_in('Size', with: '1.5')
        fill_in('Description', with: 'description of fungi')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully updated."
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_no_content('No fungi sample')
      expect(page).to have_content('Location within plot: on a rock')
      expect(page).to have_content('Size: 1.5')
      expect(page).to have_content('Description: description of fungi')
    end

    scenario "modifying the existing fungi sample providing invalid data" do
      within('.fungi_sample') do
        fill_in('Location within plot', with: '')
        fill_in('Size', with: '-1')
        fill_in('Description', with: '')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: /The form contains .* errors./
      expect(page.find('#error_explanation')).to have_content("Fungi sample location within plot can't be blank")
      expect(page.find('#error_explanation')).to have_content('Fungi sample size must be greater than or equal to 0')
      expect(page.find('#error_explanation')).to have_content("Fungi sample description can't be blank")
      expect(page).to have_css('#fungi_fields.collapse.in')
      expect(page).to have_field('Location within plot', with: '')
      expect(page).to have_field('Size', with: '-1')
      expect(page).to have_field('Description', with: '')
    end

  end

  context "without an existing lichen sample" do

    before do
      visit edit_biodiversity_report_path(biodiversity_report)
    end

    scenario "providing valid lichen sample data" do
      within('.lichen_sample') do
        fill_in('Location within plot', with: 'on a rock')
        fill_in('Description', with: 'description of lichen')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully updated."
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_no_content('No lichen sample')
      expect(page).to have_content('Location within plot: on a rock')
      expect(page).to have_content('Description: description of lichen')
    end

  end

  context "with an existing lichen sample" do

    let!(:lichen_sample) { create(:lichen_sample, biodiversity_report: biodiversity_report) }

    before do
      visit edit_biodiversity_report_path(biodiversity_report)
    end

    scenario "omitting the existing lichen sample" do
      within('.lichen_sample') do
        fill_in('Location within plot', with: '')
        fill_in('Description', with: '')
      end
      page.find('#biodiversity_report_lichen_sample_attributes__destroy', visible: false).set('1')
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully updated."
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_content('No lichen sample')
      expect(page).to have_no_content('Location_within_plot: on a rock') # Set by lichen_sample factory
      expect(page).to have_no_content('Description: description of lichen sample') # Set by lichen_sample factory
    end

    scenario "modifying the existing lichen sample providing valid data" do
      within('.lichen_sample') do
        fill_in('Location within plot', with: 'on a rock')
        fill_in('Description', with: 'description of lichen')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully updated."
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_no_content('No lichen sample')
      expect(page).to have_content('Location within plot: on a rock')
      expect(page).to have_content('Description: description of lichen')
    end

    scenario "modifying the existing lichen sample providing invalid data" do
      within('.lichen_sample') do
        fill_in('Location within plot', with: '')
        fill_in('Description', with: '')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: /The form contains .* errors./
      expect(page.find('#error_explanation')).to have_content("Lichen sample location within plot can't be blank")
      expect(page.find('#error_explanation')).to have_content("Lichen sample description can't be blank")
      expect(page).to have_css('#lichen_fields.collapse.in')
      expect(page).to have_field('Location within plot', with: '')
      expect(page).to have_field('Description', with: '')
    end

  end

  context 'without an existing plant sample' do

    before do
      visit edit_biodiversity_report_path(biodiversity_report)
    end

    scenario 'providing valid plant sample data', js: true do
      click_link('Add plant sample')
      within('.plant_sample') do
        select('Plant Example', from: 'Plant')
        fill_in('Abundance', with: '1')
        fill_in('Percent cover', with: '2')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector '.alert', text: 'Biodiversity report was successfully updated.'
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_no_content('No plant samples')
      expect(page).to have_content('Common name: Plant Example')
      expect(page).to have_content('Abundance: 1')
      expect(page).to have_content('Percent Cover: 2')
    end

  end

  context 'with one existing plant sample' do

    let!(:plant_sample) { create(:plant_sample, biodiversity_report: biodiversity_report) }

    before do
      visit edit_biodiversity_report_path(biodiversity_report)
    end

    scenario 'removing the existing plant sample', js: true do
      click_link('Remove plant sample')
      click_button('Update Biodiversity report')
      expect(page).to have_selector '.alert', text: 'Biodiversity report was successfully updated.'
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_content('No plant samples')
    end

    scenario 'modifying the existing plant sample with valid data' do
      within('.plant_sample') do
        fill_in('Abundance', with: '2')
        fill_in('Percent cover', with: '3')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector '.alert', text: 'Biodiversity report was successfully updated.'
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_no_content('No plant samples')
      expect(page).to have_content('Common name: Plant Example')
      expect(page).to have_content('Abundance: 2')
      expect(page).to have_content('Percent Cover: 3')
    end

    scenario "modifying the existing plant sample providing invalid data" do
      within('.plant_sample') do
        fill_in('Abundance', with: '-1')
        fill_in('Percent cover', with: '-1')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector ".alert", text: /The form contains .* errors./
      expect(page.find('#error_explanation')).to have_content('Plant samples abundance must be greater than 0')
      expect(page.find('#error_explanation')).to have_content('Plant samples percent cover must be greater than 0')
      expect(page).to have_field('Abundance', with: '-1')
      expect(page).to have_field('Percent cover', with: '-1')
    end

  end

  context 'with two existing plant samples' do

    let!(:plant_sample_1) { create(:plant_sample, biodiversity_report: biodiversity_report) }
    let!(:plant_sample_2) { create(:plant_sample, biodiversity_report: biodiversity_report) }

    before do
      visit edit_biodiversity_report_path(biodiversity_report)
    end

    scenario 'modifying the existing plant samples with valid data' do
      within all('.plant_sample').first do
        fill_in('Abundance', with: '2')
        fill_in('Percent cover', with: '2')
      end
      within all('.plant_sample').last do
        fill_in('Abundance', with: '3')
        fill_in('Percent cover', with: '3')
      end
      click_button('Update Biodiversity report')
      expect(page).to have_selector '.alert', text: 'Biodiversity report was successfully updated.'
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_no_content('No plant samples')
      expect(page).to have_content('Abundance: 2')
      expect(page).to have_content('Abundance: 3')
    end

    scenario 'removing both existing plant samples', js: true do
      within all('.plant_sample').first do
        click_link('Remove plant sample')
      end
      click_link('Remove plant sample')
      click_button('Update Biodiversity report')
      expect(page).to have_selector '.alert', text: 'Biodiversity report was successfully updated.'
      expect(page).to have_content(biodiversity_report.to_s)
      expect(page).to have_content('No plant samples')
    end

  end

end
