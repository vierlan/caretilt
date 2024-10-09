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
    "additionalHourlyRate", "oneOnOneHours", "twoOnOneHours", "totalAdditionalCost", "totalServiceUserCost"
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
    const totalBedsFlats = parseFloat(this.totalBedsFlatsTarget.value) || 1;

    console.log("Hourly Rate:", hourlyRate);
    console.log("Day Hours:", dayHours);
    console.log("Staff Count:", staffCount);
    console.log("Total Beds/Flats:", totalBedsFlats);

    // Core Cost per Service User for Day Staffing
    const coreCost = (hourlyRate * dayHours * staffCount * 7) / totalBedsFlats;
    this.coreCostTarget.value = coreCost.toFixed(2);

    // Total Hours per Service User
    const totalHours = (dayHours * staffCount) / totalBedsFlats;
    this.totalHoursTarget.value = totalHours.toFixed(2);
  }

  // Night staffing cost calculations in hourly_rate
  updateNightCosts() {
    const nightRate = parseFloat(this.nightRateTarget.value) || 0;
    const nightHours = parseFloat(this.nightHoursTarget.value) || 0;
    const staffNight = parseInt(this.staffNightTarget.value) || 0;
    const sleepInRate = parseFloat(this.sleepInRateTarget.value) || 0;
    const totalBedsFlats = parseFloat(this.totalBedsFlatsTarget.value) || 1;

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
    const weeklyManagementCost = (managerSalary * managerCount * (managerTimePercent / 100)) / 52.14 / totalBedsFlats;
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

  // Additional hourly costs calculation in service_user (Page 6)
  updateAdditionalCost() {
    const additionalHourlyRate = parseFloat(this.additionalHourlyRateTarget.value) || 0;
    const oneOnOneHours = parseInt(this.oneOnOneHoursTarget.value) || 0;
    const twoOnOneHours = parseInt(this.twoOnOneHoursTarget.value) || 0;

    // Total Additional Hourly Cost
    const totalAdditionalCost = (oneOnOneHours * additionalHourlyRate) + (twoOnOneHours * additionalHourlyRate * 2);
    this.totalAdditionalCostTarget.value = totalAdditionalCost.toFixed(2);

    // Update Total Service User Cost per Week after calculating additional costs
    this.updateTotalServiceUserCost();
  }

  // Calculate the Total Service User Cost per Week
  updateTotalServiceUserCost() {
    // Using `hasTarget` checks to ensure all values are available before calculation
    const coreCost = this.hasCoreCostTarget ? parseFloat(this.coreCostTarget.value) : 0;
    const coreCostNight = this.hasCoreCostNightTarget ? parseFloat(this.coreCostNightTarget.value) : 0;
    const weeklyManagementCost = this.hasWeeklyManagementCostTarget ? parseFloat(this.weeklyManagementCostTarget.value) : 0;
    const weeklyTrainingCost = this.hasWeeklyTrainingCostTarget ? parseFloat(this.weeklyTrainingCostTarget.value) : 0;
    const totalAdditionalCost = this.hasTotalAdditionalCostTarget ? parseFloat(this.totalAdditionalCostTarget.value) : 0;

    // Calculate the total service user cost if target is present
    if (this.hasTotalServiceUserCostTarget) {
      const totalServiceUserCost = coreCost + coreCostNight + weeklyManagementCost + weeklyTrainingCost + totalAdditionalCost;
      this.totalServiceUserCostTarget.value = totalServiceUserCost.toFixed(2);
    }
  }
}
