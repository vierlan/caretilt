# app/helpers/navigation_helper.rb
module NavigationHelper
  def navigation_links(current_user)
    links = []

    # Common links for all users
    links << {
      name: 'My details',
      path: edit_user_registration_path,
      icon: 'user'
    }
    links << {
      name: current_user.local_authority.present? ? 'My Service Enquiries' : 'Service Enquiries',
      path: booking_enquiries_path,
      icon: 'enquiry'
    }

    case current_user.role
    when 'caretilt_master_user', 'caretilt_user'
      @company = current_user.company
      links << {
        name: 'Team Management',
        path: team_company_path(@company),
        icon: 'team'
      }
      links << {
        name: 'Subscription Packages',
        path: packages_path,
        icon: 'folder'
      }
      links << {
        name: 'Manage Care Providers',
        path: companies_path,
        icon: 'folder'
      }
      links << {
        name: 'Manage Local Authorities',
        path: local_authorities_path,
        icon: 'folder'
      }
      links << {
        name: 'Create post',
        path: new_blog_post_path,
        icon: 'blog'
      }
      links << {
        name: 'Company details',
        path: edit_company_path(current_user.company),
        icon: 'user'
      }
      links << {
        name: 'Care Home Search',
        path: care_homes_path,
        icon: 'home'
      }
    when 'care_provider_super_user'
      @company = current_user.company
      links << {
        name: 'Team Management',
        path: team_company_path(@company),
        icon: 'team'
      }
      links << {
        name: 'Subscription Packages',
        path: packages_path,
        icon: 'folder'
      }
      links << {
        name: 'Care Service Management',
        path: care_homes_path,
        icon: 'home'
      }
      links << {
        name: 'Company details',
        path: edit_company_path(current_user.company),
        icon: 'user'
      }
    when 'la_super_user'
      links << {
        name: 'Authority details',
        path: edit_local_authority_path(current_user.local_authority),
        icon: 'user'
      }
      links << {
        name: 'Subscription Packages',
        path: packages_path,
        icon: 'folder'
      }
      links << {
        name: 'Team Management',
        path: team_local_authority_path(current_user.local_authority),
        icon: 'team'
      }
      links << {
        name: 'Care Home Search',
        path: care_homes_path,
        icon: 'home'
      }
    when 'care_provider_user'
      links << {
        name: 'Care Service Management',
        path: care_homes_path,
        icon: 'home'
      }

    when 'la_user'
      links << {
        name: 'Care Home Search',
        path: care_homes_path,
        icon: 'home'
      }
    end
    links
  end

  def icon_for_path(icon)
    case icon
    when 'team'
      '<i class="fa-solid fa-users"></i>'
    when 'user'
      '<i class="fa-regular fa-user"></i>'
    when 'enquiry'
      '<i class="fa-solid fa-envelope"></i>'
    when 'home'
      '<i class="fa-solid fa-house-chimney"></i>'
    when 'folder'
      '<i class="fa-solid fa-folder-closed"></i>'
    when 'blog'
      '<i class="fa-regular fa-newspaper"></i>'
    else
      '<svg class="h-6 w-6 shrink-0 text-gray-700 group-hover:text-primary" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M12 14.25c2.485 0 4.5-2.015 4.5-4.5S14.485 5.25 12 5.25 7.5 7.265 7.5 9.75s2.015 4.5 4.5 4.5zm0 1.5c-3.315 0-6 2.685-6 6v.75h12v-.75c0-3.315-2.685-6-6-6z" /></svg>'.html_safe
    end
  end
end
