class PricingCalculatorController < ApplicationController

    skip_before_action :authenticate_user!

    include Wicked::Wizard

    # Define each main section as a step
    steps :service_details, :core_staffing, :hourly_rate, :number_of_managers,
            :recruitment_training, :service_user, :central_overheads, :summary

    # Define a title for each step
    def step_title
        {
        service_details: "Service Details",
        core_staffing: "Core Staffing",
        hourly_rate: "Hourly Rate",
        number_of_managers: "Manager Details",
        recruitment_training: "Recruitment & Training",
        service_user: "Service User Costs",
        central_overheads: "Central Overheads",
        summary: "Summary"
        }[step]
    end


    # Show action for each step
    def show
        # Initialize session data if not already present
        session[:calculator_data] ||= {}

        # Set the instance variable for form to use
        @calculator_data = session[:calculator_data]
        @step_title = step_title
        render_wizard
    end

    # Update action to save form data and move to the next step
    def update
        # Merge submitted data with existing session data
        session[:calculator_data] ||= {}
        session[:calculator_data].merge!(calculator_params)


        # If we're on the last step, calculate totals and send the email
        if step == :summary
            calculate_totals
            
            if params[:calculator][:email].present?
            # Send email with results
            CalculatorMailer.send_calculation(
                params[:calculator][:email],
                {
                    total_overheads: @total_overheads,
                    total_package_cost: @total_package_cost,
                    total_hourly_rate: @total_hourly_rate
                }
            ).deliver_now
            end
        end

        # Move to the next step
        redirect_to next_wizard_path
    end

    private

    # Define strong parameters for the calculator form
    def calculator_params
        params.require(:calculator).permit(
        :number_of_units, :number_of_vacancies, :total_beds_flats,
        :core_staff_day_rate, :day_hours, :staff_day, :core_cost_per_user, :total_hours_per_user,
        :core_staff_night_rate, :night_hours, :staff_night, :sleep_in_rate, :sleep_in_staff, :core_cost_night, :total_hours_night,
        :manager_count, :manager_salary, :manager_time_percent, :weekly_management_cost_per_user,
        :recruitment_training_budget, :staff_apportionment_percent, :weekly_training_cost_per_user,
        :additional_hourly_rate, :one_on_one_hours, :two_on_one_hours, :total_additional_cost, :total_service_user_cost, :total_additional_hours_for_servcice_user,
        :overheads, :central_overhead_rate, :surplus, :surplus_rate, :contingency, :contingency_rate,
        :total_additional_hours, :total_overheads, :total_package_cost, :total_hourly_rate, 
        :total_additional_hours_for_service_user, :core_cost_per_user_day,
        :email
        
        )
    end

    # Calculation logic for totals displayed on the summary page
    def calculate_totals
        data = session[:calculator_data]
      
        # Example calculations - ensure the required fields are in session data
        contingency_rate = data[:contingency_rate].to_f
        surplus_rate = data[:surplus_rate].to_f
        central_overhead_rate = data[:central_overhead_rate].to_f
        total_service_user_cost = data[:total_service_user_cost].to_f
        total_additional_hours = data[:total_additional_hours].to_f
        total_hours_per_user = data[:total_hours_per_user].to_f
      
        # Calculate Total Overheads as the sum of rates
        @total_overheads = contingency_rate + surplus_rate + central_overhead_rate
      
        # Calculate Total Package Cost
        @total_package_cost = @total_overheads + total_service_user_cost
      
        # Calculate Total Hourly Rate
        @total_hourly_rate = @total_package_cost / (total_additional_hours + total_hours_per_user)

        Rails.logger.debug "Contingency Rate: #{contingency_rate}"
        Rails.logger.debug "Surplus Rate: #{surplus_rate}"
        Rails.logger.debug "Central Overhead Rate: #{central_overhead_rate}"
        Rails.logger.debug "Total Service User Cost: #{total_service_user_cost}"
        Rails.logger.debug "Total Additional Hours: #{total_additional_hours}"
        Rails.logger.debug "Total Hours per User: #{total_hours_per_user}"
      
        # Store calculated values in session
        session[:calculator_data][:total_overheads] = @total_overheads
        session[:calculator_data][:total_package_cost] = @total_package_cost
        session[:calculator_data][:total_hourly_rate] = @total_hourly_rate
      end
end
