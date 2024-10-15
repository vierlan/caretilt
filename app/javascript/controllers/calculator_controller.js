// app/javascript/controllers/calculator_controller.js

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    // Targets for the Total Beds/Flats calculation in service_details
    "totalBedsFlats", "numberOfUnits", "numberOfVacancies",

    // Day staffing fields and calculated targets in core_staffing
    "hourlyRate", "dayHours", "staffCount", "coreCost", "totalHours",

    // Night staffing fields and calculated targets in hourly_rate
    "nightRate", "nightHours", "staffNight", "sleepInRate", "coreCostNight", "totalHoursNight",

    // Manager-related fields and calculated targets in number_of_managers
    "managerCount", "managerSalary", "managerTimePercent", "weeklyManagementCost",

    // Recruitment and training fields in recruitment_training
    "trainingBudget", "apportionmentPercent", "weeklyTrainingCost",

    // Additional hourly cost fields in service_user
    "additionalHourlyRate", "oneOnOneHours", "twoOnOneHours", "totalAdditionalCost", "totalServiceUserCost", "totalAdditionalHours",
    "coreCostPerUserDay", "coreCostNight", "weeklyManagementCost", "weeklyTrainingCost",

    //Overheads
    "centralCharges", "surplus", "contingency", 
    "totalOverheads", "totalPackageCost", "totalHourlyRate",
    "hiddenTotalOverheads", "hiddenTotalPackageCost", "hiddenTotalHourlyRate",
    "totalServiceUserCost", "totalAdditionalHours", "totalHoursPerUser", "totalHoursNight",
    "totalAdditionalHoursForServiceUser" // Add this new target
  ];

  // Total Beds/Flats calculation
  updateTotal() {
    const numberOfUnits = parseInt(this.numberOfUnitsTarget.value) || 0;
    const numberOfVacancies = parseInt(this.numberOfVacanciesTarget.value) || 0;
    this.totalBedsFlatsTarget.value = numberOfUnits + numberOfVacancies;
    console.log("Updated Total Beds/Flats:", this.totalBedsFlatsTarget.value);
  }

  // Day staffing cost calculations in core_staffing
  updateCosts() {
    const hourlyRate = parseFloat(this.hourlyRateTarget.value) || 0;
    const dayHours = parseFloat(this.dayHoursTarget.value) || 0;
    const staffCount = parseInt(this.staffCountTarget.value) || 0;
    // Error coming from here?
    const totalBedsFlats = parseInt(this.totalBedsFlatsTarget.value);

    // console.log("Hourly Rate:", hourlyRate);
    // console.log("Day Hours:", dayHours);
    // console.log("Staff Count:", staffCount);
    // console.log("Total Beds/Flats:", totalBedsFlats);

    // Core Cost per Service User for Day Staffing
    const coreCost = (hourlyRate * dayHours * staffCount * 7) / totalBedsFlats;
    this.coreCostTarget.value = coreCost.toFixed(2);

    // Total Hours per Service User
    const totalHours = (dayHours * staffCount * 7) / totalBedsFlats;
    this.totalHoursTarget.value = totalHours.toFixed(2);
    // console.log('========')
    // console.log("Total hours per user:", totalHours);
    // console.log("Total Beds/Flats:", totalBedsFlats);
    // console.log("Total hours per user form:", this.totalHoursTarget.value);

  }

  // Night staffing cost calculations in hourly_rate
  updateNightCosts() {
    const nightRate = parseFloat(this.nightRateTarget.value) || 0;
    const nightHours = parseFloat(this.nightHoursTarget.value) || 0;
    const staffNight = parseInt(this.staffNightTarget.value) || 0;
    const sleepInRate = parseFloat(this.sleepInRateTarget.value) || 0;
    const totalBedsFlats = parseFloat(this.totalBedsFlatsTarget.value) || 1;

    console.log("NIight Rate:", nightRate);
    console.log("Night Hours:", nightHours);
    console.log("Staff Count:", staffNight);
    console.log("Sleep in Rate", sleepInRate);
    console.log("Total Beds/Flats:", totalBedsFlats);

    // Core Cost per Service User for Night Staffing
    const coreCostNight = ((nightRate * nightHours * staffNight * 7) + (sleepInRate * 7)) / totalBedsFlats;
    this.coreCostNightTarget.value = coreCostNight.toFixed(2);

    // Total Hours per Service User for Night Staffing
    const totalHoursNight = (nightHours * staffNight * 7) / totalBedsFlats;
    this.totalHoursNightTarget.value = totalHoursNight.toFixed(2);
  }

  // Manager-related cost calculations in number_of_managers
  updateManagerCosts() {
    const managerCount = parseInt(this.managerCountTarget.value) || 0;
    const managerSalary = parseFloat(this.managerSalaryTarget.value) || 0;
    const managerTimePercent = parseFloat(this.managerTimePercentTarget.value) || 0;
    const totalBedsFlats = parseFloat(this.totalBedsFlatsTarget.value) || 1;

    // Weekly Management Cost per Service User
    const weeklyManagementCost = (((managerSalary * managerCount * (managerTimePercent / 100)) / 52.14) / totalBedsFlats);
    this.weeklyManagementCostTarget.value = weeklyManagementCost.toFixed(2);
  }

  // Recruitment and training cost calculations in recruitment_training (Page 5)
  updateTrainingCosts() {
    const trainingBudget = parseFloat(this.trainingBudgetTarget.value) || 0;
    const apportionmentPercent = parseFloat(this.apportionmentPercentTarget.value) || 0;

    // Weekly Recruitment and Training per Service User
    const weeklyTrainingCost = (trainingBudget * (apportionmentPercent / 100)) / 52.14;
    this.weeklyTrainingCostTarget.value = weeklyTrainingCost.toFixed(2);
  }

   // Method to update total additional cost
   updateAdditionalCost() {
    const additionalHourlyRate = parseFloat(this.additionalHourlyRateTarget.value) || 0;
    const oneOnOneHours = parseInt(this.oneOnOneHoursTarget.value) || 0;
    const twoOnOneHours = parseInt(this.twoOnOneHoursTarget.value) || 0;

    // Calculate total additional cost
    const totalAdditionalCost = (oneOnOneHours * additionalHourlyRate) + (twoOnOneHours * additionalHourlyRate * 2);
    this.totalAdditionalCostTarget.value = totalAdditionalCost.toFixed(2);

      // Calculate and update total additional hours
      this.updateTotalAdditionalHours(oneOnOneHours, twoOnOneHours);

      // Update total service user cost per week
      this.updateTotalServiceUserCost();
  }

  // Method to update total additional hours
  updateTotalAdditionalHours(oneOnOneHours, twoOnOneHours) {
    const totalAdditionalHours = oneOnOneHours + twoOnOneHours;
    this.totalAdditionalHoursTarget.value = totalAdditionalHours;
  }

  // Method to update total service user cost per week
  updateTotalServiceUserCost() {
    // Retrieve hidden values
    const coreCostPerUserDay = parseFloat(this.coreCostPerUserDayTarget.value) || 0;
    const coreCostNight = parseFloat(this.coreCostNightTarget.value) || 0;
    const weeklyManagementCost = parseFloat(this.weeklyManagementCostTarget.value) || 0;
    const weeklyTrainingCost = parseFloat(this.weeklyTrainingCostTarget.value) || 0;
    const totalAdditionalCost = parseFloat(this.totalAdditionalCostTarget.value) || 0;

    // Calculate total service user cost per week
    const totalServiceUserCost = coreCostPerUserDay + coreCostNight + weeklyManagementCost + weeklyTrainingCost + totalAdditionalCost;
    this.totalServiceUserCostTarget.value = totalServiceUserCost.toFixed(2);
  }

   // Method to update central overheads calculations
   updateOverheads() {
    // Retrieve the base cost (Total Service User Cost per week)
    const baseCost = parseFloat(this.totalServiceUserCostTarget.value) || 0;

    // Retrieve percentages entered by the user
    const centralChargesPercent = parseFloat(this.centralChargesTarget.value) || 0;
    const surplusPercent = parseFloat(this.surplusTarget.value) || 0;
    const contingencyPercent = parseFloat(this.contingencyTarget.value) || 0;

    // Calculate visible fields based on percentages
    const totalOverheads = (baseCost * centralChargesPercent) / 100;
    const totalPackageCost = (baseCost * surplusPercent) / 100;
    const totalHourlyRate = (baseCost * contingencyPercent) / 100;

    // Update visible calculated fields
    this.totalOverheadsTarget.value = totalOverheads.toFixed(2);
    this.totalPackageCostTarget.value = totalPackageCost.toFixed(2);
    this.totalHourlyRateTarget.value = totalHourlyRate.toFixed(2);

    // Retrieve hidden or base values for final calculations
    const additionalHours = parseFloat(this.totalHoursNightTarget.value) || 0; // Updated variable here
    const hoursPerUser = parseFloat(this.totalHoursPerUserTarget.value) || 0;
    const totalAdditionalHoursForServiceUser = parseFloat(this.totalAdditionalHoursForServiceUserTarget.value) || 0;

    // Hidden Fields Calculation
    const totalOverheadsHidden = totalOverheads + totalPackageCost + totalHourlyRate;
    const totalPackageCostHidden = baseCost + totalOverheadsHidden;
    const totalHourlyRateHidden = totalPackageCostHidden / (additionalHours + hoursPerUser + totalAdditionalHoursForServiceUser);

    // Update hidden fields to store values for the summary page
    this.hiddenTotalOverheadsTarget.value = totalOverheadsHidden.toFixed(2);
    this.hiddenTotalPackageCostTarget.value = totalPackageCostHidden.toFixed(2);
    this.hiddenTotalHourlyRateTarget.value = totalHourlyRateHidden.toFixed(2);

    // Console logs for debugging
    console.log("Base Cost:", baseCost);
    console.log("Central Charges Percent:", centralChargesPercent);
    console.log("Surplus Percent:", surplusPercent);
    console.log("Contingency Percent:", contingencyPercent);
    console.log("Total Overheads (visible):", totalOverheads);
    console.log("Total Package Cost (visible):", totalPackageCost);
    console.log("Total Hourly Rate (visible):", totalHourlyRate);
    console.log("Additional Hours (total_hours_night):", additionalHours);
    console.log("Hours per User:", hoursPerUser);
    console.log("Total Additional Hours for Service User:", totalAdditionalHoursForServiceUser);
    console.log("Total Overheads (hidden):", totalOverheadsHidden);
    console.log("Total Package Cost (hidden):", totalPackageCostHidden);
    console.log("Total Hourly Rate (hidden):", totalHourlyRateHidden);
  
  
    // Update hidden fields to store values for the summary page
    this.hiddenTotalOverheadsTarget.value = totalOverheadsHidden.toFixed(2);
    this.hiddenTotalPackageCostTarget.value = totalPackageCostHidden.toFixed(2);
    this.hiddenTotalHourlyRateTarget.value = totalHourlyRateHidden.toFixed(2);
  }
}
