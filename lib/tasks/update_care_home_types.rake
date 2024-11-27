# lib/tasks/update_care_home_types.rake
namespace :care_home do
    desc "Update type_of_home to type_of_service for all CareHomes"
    task update_type_mappings: :environment do
      type_mapping = {
        "Adult Homes" => "Assisted Living / Sheltered",
        "Assisted Living" => "Assisted Living / Sheltered",
        "Continuing Care Retirement Communities" => "Extra Care",
        "Group Homes" => "Children's Home",
        "Home Health Care" => "Assisted Living / Sheltered", # removed, mapped to default
        "Hospice Homes" => "Hospice / EoL",
        "Independent Living" => "Semi Independent Living",
        "Memory Care Homes" => "Dementia Care Home",
        "Nursing Home" => "Nursing Home",
        "Residential Care Home" => "Residential Care Home",
        "Supported Living" => "Supported Living",
        nil => "Assisted Living / Sheltered", # catch nil or blank types and map to default
      }
  
      default_type = "Assisted Living / Sheltered"
  
      CareHome.find_each do |care_home|
        old_type = care_home.type_of_home
        new_type = type_mapping.fetch(old_type, default_type)
        care_home.update!(type_of_service: new_type)
      end
  
      puts "CareHome types updated successfully."
    end
  end
  