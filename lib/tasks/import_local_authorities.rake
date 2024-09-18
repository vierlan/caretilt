# lib/tasks/import_local_authorities.rake
namespace :local_authorities do
    desc "Import local authorities from CSV"
    task import: :environment do
      require 'csv'
  
      file_path = Rails.root.join('app/assets/uk_local_authorities_future.csv')
  
      CSV.foreach(file_path, headers: true) do |row|
        # Find or initialize the record by a unique field (e.g., local_authority_code)
        local_authority_data = LocalAuthorityData.find_or_initialize_by(local_authority_code: row['local-authority-code'])
  
        # Update the record's attributes
        local_authority_data.update(
          official_name: row['official-name'],
          nice_name: row['nice-name'],
        #   gss_code: row['gss-code'],
        #   start_date: row['start-date'],
        #   end_date: row['end-date'],
        #   replaced_by: row['replaced-by'],
        #   nation: row['nation'],
        #   region: row['region'],
        #   local_authority_type: row['local-authority-type'],
        #   local_authority_type_name: row['local-authority-type-name'],
        #   county_la: row['county-la'],
        #   combined_authority: row['combined-authority'],
        #   alt_names: row['alt-names'],
        #   former_gss_codes: row['former-gss-codes'],
        #   notes: row['notes'],
        #   current_authority: row['current-authority'] == 'yes', # Convert 'yes'/'no' to boolean
        #   bs_6879: row['BS-6879'],
        #   ecode: row['ecode'],
        #   even_older_register_and_code: row['even-older-register-and-code'],
        #   gov_uk_slug: row['gov-uk-slug'],
        #   area: row['area'],
        #   pop_2020: row['pop-2020'].to_i,
        #   x: row['x'].to_f,
        #   y: row['y'].to_f,
        #   long: row['long'].to_f,
        #   lat: row['lat'].to_f,
        #   powers: row['powers'],
        #   lower_or_unitary: row['lower-or-unitary'],
        #   mapit_area_code: row['mapit-area-code'],
        #   ofcom: row['ofcom'],
        #   old_ons_la_code: row['old-ons-la-code'],
        #   old_register_and_code: row['old-register-and-code'],
        #   open_council_data_id: row['open-council-data-id'],
        #   os_file: row['os-file'],
        #   os: row['os'],
        #   snac: row['snac'],
        #   wdtk_id: row['wdtk-id']
        )
      end
  
      puts "Local authorities data imported successfully!"
    end
  end
  