class PricingCalculatorController < ApplicationController
    include Wicked::Wizard

    # Define each main section as a step
    steps :service_details, :core_staffing, :hourly_rate, :number_of_managers,
            :recruitment_training, :service_user, :central_overheads, :summary

    # Show action for each step
    def show
        # Initialize session data if not already present
        session[:calculator_data] ||= {}

        # Set the instance variable for form to use
        @calculator_data = session[:calculator_data]
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
                core_cost_per_user_day: @core_cost_per_user_day,
                weekly_management_cost_per_user: @weekly_management_cost_per_user,
                total_cost_per_user_per_week: @total_cost_per_user_per_week
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
        :core_staff_day_rate, :day_hours, :staff_day,
        :core_staff_night_rate, :night_hours, :staff_night, :sleep_in_rate, :sleep_in_staff,
        :manager_count, :manager_salary, :manager_time_percent,
        :recruitment_training_budget, :staff_apportionment_percent,
        :additional_hourly_rate, :one_on_one_hours, :two_on_one_hours,
        :overheads
        )
    end

    # Calculation logic for totals displayed on the summary page
    def calculate_totals
        data = session[:calculator_data]

        # Example calculations (customize as needed)
        @core_cost_per_user_day = data[:core_staff_day_rate].to_f * data[:day_hours].to_f * data[:staff_day].to_f / data[:number_of_units].to_f
        @weekly_management_cost_per_user = (data[:manager_salary].to_f * (data[:manager_time_percent].to_f / 100)) / 52 / data[:number_of_units].to_f
        @total_cost_per_user_per_week = @core_cost_per_user_day + @weekly_management_cost_per_user + data[:overheads].to_f
    end
end
