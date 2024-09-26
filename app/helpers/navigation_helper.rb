# app/helpers/navigation_helper.rb
module NavigationHelper

  def navigation_links(current_user)
    links = []

    # Common links for all users

    links << { name: 'My details', path: edit_user_registration_path, svg: svg_for_path(root_path) }
    if current_user.role == 'caretilt_user'
      links << {
        name: 'Admin dashboard',
        path: companies_path,
        icon: 'team-members-icon-class' }
    end

    # Conditional links based on the user role or attributes
    #if current_user.admin?
    #  links << { name: 'Admin Dashboard', path: admin_root_path, icon: 'admin-icon-class' }
    #end

    if current_user.role == 'care_provider_super_user'
      links << { name: 'Dashboard', path: packages_index_path, svg: svg_for_path(checkout_pricing_path) }
      links << { name: 'Team Management', path: team_company_path(@company), svg: svg_for_path(team_company_path(@company)) }
      links << { name: 'Account', path: edit_company_path(current_user.company), svg: svg_for_path(edit_company_path(current_user.company)) }
    end

    if current_user.company.present?
      links << {
        name: 'Care Service Management',
        path: all_company_care_homes_path(@company),
        svg: svg_for_path(all_company_care_homes_path(@company))
      }
      links << {
        name: 'Booking Requests',
        path: booking_enquiries_path,
        svg: svg_for_path(booking_enquiries_path)
      }
    end

    #if current_user.local_authority.present?
    #  links << {
    #    name: 'Care Home Search',
    #    path: care_homes_path,
    #    svg: svg_for_path(care_homes_path)
    #  }
    #end
  end

  def svg_for_path(path)
    case path
    when all_company_care_homes_path(@company)
      '<svg class="h-6 w-6 shrink-0 text-gray-700 group-hover:text-primary" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75m-8.69-6.44l-2.12-2.12a1.5 1.5 0 00-1.061-.44H4.5A2.25 2.25 0 002.25 6v12a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9a2.25 2.25 0 00-2.25-2.25h-5.379a1.5 1.5 0 01-1.06-.44z" /></svg>'.html_safe
    when care_homes_path
      '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
      <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 21v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21m0 0h4.5V3.545M12.75 21h7.5V10.75M2.25 21h1.5m18 0h-18M2.25 9l4.5-1.636M18.75 3l-1.5.545m0 6.205 3 1m1.5.5-1.5-.5M6.75 7.364V3h-3v18m3-13.636 10.5-3.819" />
      </svg>'
    when booking_enquiries_path
      '<svg class="h-6 w-6 shrink-0 text-gray-700 group-hover:text-primary" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75m-8.69-6.44l-2.12-2.12a1.5 1.5 0 00-1.061-.44H4.5A2.25 2.25 0 002.25 6v12a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9a2.25 2.25 0 00-2.25-2.25h-5.379a1.5 1.5 0 01-1.06-.44z" />
      </svg>'
    else
      '<svg class="h-6 w-6 shrink-0 text-gray-700 group-hover:text-primary" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M12 14.25c2.485 0 4.5-2.015 4.5-4.5S14.485 5.25 12 5.25 7.5 7.265 7.5 9.75s2.015 4.5 4.5 4.5zm0 1.5c-3.315 0-6 2.685-6 6v.75h12v-.75c0-3.315-2.685-6-6-6z" /></svg>'.html_safe
    end
  end

end
