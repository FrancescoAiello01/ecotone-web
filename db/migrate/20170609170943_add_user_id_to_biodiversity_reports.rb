class AddUserIdToBiodiversityReports < ActiveRecord::Migration[5.0]
  def change
    add_column :biodiversity_reports, :user_id, :integer
  end
end
