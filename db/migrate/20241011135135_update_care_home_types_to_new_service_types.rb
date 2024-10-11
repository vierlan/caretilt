class UpdateCareHomeTypesToNewServiceTypes < ActiveRecord::Migration[7.2]
  def up
    # Step 1: Rename the column `type_of_home` to `type_of_service`
    rename_column :care_homes, :type_of_home, :type_of_service

    # Step 2: Define the valid types of services
    valid_types = [
      "Assisted Living / Sheltered",
      "Extra Care",
      "Children's Home",
      "Hospice / EoL",
      "Semi Independent Living",
      "Dementia Care Home",
      "Nursing Home",
      "Residential Care Home",
      "Supported Living",
      "Supported Housing",
      "IFA (fostering)"
    ]

    # Step 3: Update any invalid types to "Assisted Living / Sheltered"
    CareHome.where.not(type_of_service: valid_types).update_all(type_of_service: "Assisted Living / Sheltered")
  end

  def down
    # Optional: reverse the changes if needed, renaming column back to `type_of_home`
    rename_column :care_homes, :type_of_service, :type_of_home

    # Reverting invalid types back to nil (or another fallback)
    CareHome.where(type_of_home: "Assisted Living / Sheltered").update_all(type_of_home: nil)
  end
end
