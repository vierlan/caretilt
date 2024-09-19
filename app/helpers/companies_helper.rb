module CompaniesHelper
def format_company_name(company)
  company.name.titleize
end

def format_company_address(company)
  "#{company.address1}, #{company.address2}, #{company.city}, #{company.postcode}, ~ #{company.country}"
end

end
