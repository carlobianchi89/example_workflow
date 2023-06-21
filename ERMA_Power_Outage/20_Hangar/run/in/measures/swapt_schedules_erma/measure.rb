# load dependencies
require 'csv'
require 'json'
require 'openstudio'
require 'openstudio-standards'

# start the measure
class SwaptSchedulesERMA < OpenStudio::Ruleset::ModelUserScript
  # display name
  def name
    return "swapt_schedules_ERMA"
  end
  # description
  def description
    return "This measure changes original Prototype Buildings schedules with ACM schedules for the 179D project"
  end
  # modeler description
  def modeler_description
    return ""
  end
  # define the arguments that the user will input
  def arguments(_model)
    OpenStudio::Ruleset::OSArgumentVector.new
  end

  def create_sched_ruleset(standards, model, acm_schedule_set, schedule_name)
    rules = standards.model_find_objects(acm_schedule_set, 'name' => schedule_name)
    if rules.size.zero?
      OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Model', "Cannot find data for schedule: #{schedule_name}, will not be created.")
      return model.alwaysOnDiscreteSchedule
    end

    # Make a schedule ruleset
    sch_ruleset = OpenStudio::Model::ScheduleRuleset.new(model)
    sch_ruleset.setName(schedule_name.to_s)

    # Loop through the rules, making one for each row in the spreadsheet
    rules.each do |rule|
      day_types = rule['day_types']
      start_date = DateTime.parse(rule['start_date'])
      end_date = DateTime.parse(rule['end_date'])
      sch_type = rule['type']
      values = rule['values']

      # Day Type choices: Wkdy, Wknd, Mon, Tue, Wed, Thu, Fri, Sat, Sun, WntrDsn, SmrDsn, Hol
      # Default
      if day_types.include?('Default')
        day_sch = sch_ruleset.defaultDaySchedule
        day_sch.setName("#{schedule_name} Default")
        if sch_type == 'Constant'
          day_sch.addValue(OpenStudio::Time.new(0, 24, 0, 0), values[0])
        elsif sch_type == 'Hourly'
          (0..23).each do |i|
            next if values[i] == values[i + 1]

            day_sch.addValue(OpenStudio::Time.new(0, i + 1, 0, 0), values[i])
          end
        else
          OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Model',
                             "Schedule type: #{sch_type} is not recognized.  Valid choices are 'Constant' and 'Hourly'."
          )
        end
        # standards.model_add_vals_to_sch(model, day_sch, sch_type, values)
      end

      # Winter Design Day
      if day_types.include?('WntrDsn')
        day_sch = OpenStudio::Model::ScheduleDay.new(model)
        sch_ruleset.setWinterDesignDaySchedule(day_sch)
        day_sch = sch_ruleset.winterDesignDaySchedule
        day_sch.setName("#{schedule_name} Winter Design Day")
        if sch_type == 'Constant'
          day_sch.addValue(OpenStudio::Time.new(0, 24, 0, 0), values[0])
        elsif sch_type == 'Hourly'
          (0..23).each do |i|
            next if values[i] == values[i + 1]

            day_sch.addValue(OpenStudio::Time.new(0, i + 1, 0, 0), values[i])
          end
        else
          OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Model',
                             "Schedule type: #{sch_type} is not recognized.  Valid choices are 'Constant' and 'Hourly'."
          )
        end
        # standards.model_add_vals_to_sch(model, day_sch, sch_type, values)
      end

      # Summer Design Day
      if day_types.include?('SmrDsn')
        day_sch = OpenStudio::Model::ScheduleDay.new(model)
        sch_ruleset.setSummerDesignDaySchedule(day_sch)
        day_sch = sch_ruleset.summerDesignDaySchedule
        day_sch.setName("#{schedule_name} Summer Design Day")
        if sch_type == 'Constant'
          day_sch.addValue(OpenStudio::Time.new(0, 24, 0, 0), values[0])
        elsif sch_type == 'Hourly'
          (0..23).each do |i|
            next if values[i] == values[i + 1]

            day_sch.addValue(OpenStudio::Time.new(0, i + 1, 0, 0), values[i])
          end
        else
          OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Model',
                             "Schedule type: #{sch_type} is not recognized.  Valid choices are 'Constant' and 'Hourly'."
          )
        end
        # standards.model_add_vals_to_sch(model, day_sch, sch_type, values)
      end

      # Other days (weekdays, weekends, etc)
      next unless day_types.include?('Wknd') ||
        day_types.include?('Wkdy') ||
        day_types.include?('Sat') ||
        day_types.include?('Sun') ||
        day_types.include?('Mon') ||
        day_types.include?('Tue') ||
        day_types.include?('Wed') ||
        day_types.include?('Thu') ||
        day_types.include?('Fri')

      # Make the Rule
      sch_rule = OpenStudio::Model::ScheduleRule.new(sch_ruleset)
      day_sch = sch_rule.daySchedule
      day_sch.setName("#{schedule_name} #{day_types} Day")
      if sch_type == 'Constant'
        day_sch.addValue(OpenStudio::Time.new(0, 24, 0, 0), values[0])
      elsif sch_type == 'Hourly'
        (0..23).each do |i|
          next if values[i] == values[i + 1]

          day_sch.addValue(OpenStudio::Time.new(0, i + 1, 0, 0), values[i])
        end
      else
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Model',
                           "Schedule type: #{sch_type} is not recognized.  Valid choices are 'Constant' and 'Hourly'."
        )
      end
      # standards.model_add_vals_to_sch(model, day_sch, sch_type, values)

      # Set the dates when the rule applies
      sch_rule.setStartDate(OpenStudio::Date.new(OpenStudio::MonthOfYear.new(start_date.month.to_i), start_date.day.to_i))
      sch_rule.setEndDate(OpenStudio::Date.new(OpenStudio::MonthOfYear.new(end_date.month.to_i), end_date.day.to_i))

      # Set the days when the rule applies
      # Weekends
      if day_types.include?('Wknd')
        sch_rule.setApplySaturday(true)
        sch_rule.setApplySunday(true)
      end
      # Weekdays
      if day_types.include?('Wkdy')
        sch_rule.setApplyMonday(true)
        sch_rule.setApplyTuesday(true)
        sch_rule.setApplyWednesday(true)
        sch_rule.setApplyThursday(true)
        sch_rule.setApplyFriday(true)
      end
      # Individual Days
      sch_rule.setApplyMonday(true) if day_types.include?('Mon')
      sch_rule.setApplyTuesday(true) if day_types.include?('Tue')
      sch_rule.setApplyWednesday(true) if day_types.include?('Wed')
      sch_rule.setApplyThursday(true) if day_types.include?('Thu')
      sch_rule.setApplyFriday(true) if day_types.include?('Fri')
      sch_rule.setApplySaturday(true) if day_types.include?('Sat')
      sch_rule.setApplySunday(true) if day_types.include?('Sun')
    end
    sch_ruleset
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    return false unless runner.validateUserArguments(arguments(model), user_arguments)


    file_path = File.expand_path(File.dirname(__FILE__).to_s)
    puts file_path
    # # read in csv values
    # table = CSV.parse(File.read("cats.csv"), headers: true)
    # csv_values = CSV.read(file_path,{headers: false, converters: :float})
    # num_rows = csv_values.length

    

    # # Find building type
    # building_type = model.getBuilding.standardsBuildingType.get.strip
    # runner.registerInfo("building type = #{building_type}")

    # # ACM schedule mapping
    # if building_type == 'SchoolPrimary'
    #   acm_light_schedule_name = 'SchoolPrimary_Light_Sch'
    #   acm_occupancy_schedule_name = 'SchoolPrimary_Occ_Sch'
    #   acm_swh_schedule_name = 'SchoolPrimary_SWH_Sch'
    #   acm_infiltration_schedule_name = 'SchoolPrimary_Infil_Sch'
    #   acm_operations_schedule_name = 'SchoolPrimary_HVAC_Sch'
    #   acm_equipment_schedule_name = 'SchoolPrimary_Equip_Sch'
    #   acm_hvac_stpt_htg = 'SchoolPrimary_Heat_Sch'
    #   acm_hvac_stpt_clg = 'SchoolPrimary_Cool_Sch'
    # elsif building_type == 'Retail' # Fix the name here
    #   acm_light_schedule_name = 'Retail_Occ_Sch'
    #   acm_occupancy_schedule_name = 'Nonres_Occ_Sch'
    #   acm_swh_schedule_name = 'Retail_SWH_Sch'
    #   acm_infiltration_schedule_name = 'Retail_Infil_Sch'
    #   acm_operations_schedule_name = 'Retail_HVAC_Sch'
    #   acm_equipment_schedule_name = 'Retail_Equip_Sch'
    #   acm_hvac_stpt_htg = 'Retail_Heat_Sch'
    #   acm_hvac_stpt_clg = 'Retail_Cool_Sch'
    # elsif building_type == 'Residential' # Fix the name here
    #   acm_light_schedule_name = 'Res_Light_Sch'
    #   acm_occupancy_schedule_name = 'Res_Occ_Sch'
    #   acm_swh_schedule_name = 'Res_SWH_Sch'
    #   acm_infiltration_schedule_name = 'Res_Infil_Sch'
    #   acm_operations_schedule_name = 'Res_HVAC_Sch'
    #   acm_equipment_schedule_name = 'Res_Equip_Sch'
    #   acm_hvac_stpt_htg = 'Res_Heat_Sch'
    #   acm_hvac_stpt_clg = 'Res_Cool_Sch'
    # else
    #   acm_light_schedule_name = 'Nonres_Light_Sch'
    #   acm_occupancy_schedule_name = 'Nonres_Occ_Sch'
    #   acm_swh_schedule_name = 'Nonres_SWH_Sch'
    #   acm_infiltration_schedule_name = 'Nonres_Infil_Sch'
    #   acm_operations_schedule_name = 'Nonres_HVAC_Sch'
    #   acm_equipment_schedule_name = 'Nonres_Equip_Sch'
    #   acm_hvac_stpt_htg = 'Nonres_Heat_Sch'
    #   acm_hvac_stpt_clg = 'Nonres_Cool_Sch'
    # end
    # # ACM load mapping
    # if building_type == 'SchoolPrimary'
    #   spacetype = "schools"
    # elsif building_type == 'Retail'
    #   spacetype = "retail_and_wholesale_stores"
    # elsif building_type == 'Office'
    #   spacetype = "office_buildings"
    # elsif building_type == 'FullServiceRestaurant'
    #   spacetype = "restaurants"
    # elsif building_type == 'QuickServiceRestaurant'
    #   spacetype = "restaurants"
    # elsif building_type == 'SmallHotel'
    #   spacetype = "hotel"
    # elsif building_type == 'LargeHotel'
    #   spacetype = "hotel"
    # else
    #   spacetype = "all_others"
    # end
    # runner.registerInfo("space type for building type = #{spacetype}")

    # template = '90.1-2007'
    # standards = Standard.build(template.to_s)

    # acm_schedule_set_json = JSON.parse(File.read("#{File.dirname(__FILE__)}/resources/openstudio_standards_acm_schedule_seed.json"))
    # acm_schedule_set = acm_schedule_set_json['schedules']
    # acm_load_set = acm_schedule_set_json['loads']

    # #------- LIGHTS
    # count_lights = 0
    # sch_ruleset_light = create_sched_ruleset(standards, model, acm_schedule_set, acm_light_schedule_name)
    # # loop through all light objects
    # model.getLightss.sort.each do |lgts|
    #   # for each light object overwrite the light schedule
    #   lgts.setSchedule(sch_ruleset_light)
    #   count_lights += 1
    # end
    # runner.registerInfo("interior lighting - #{sch_ruleset_light.name} applied to #{count_lights} 'light' object(s).")

    # #------- OCCUPANCY
    # count_people = 0
    # sch_ruleset_occupancy = create_sched_ruleset(standards, model, acm_schedule_set, acm_occupancy_schedule_name)
    # model.getSpaces.sort.each do |space|
    #   space.spaceType.get.people.each do |people|
    #     # Swap occupancy schedule
    #     people.setNumberofPeopleSchedule(sch_ruleset_occupancy)
    #     count_people += 1
    #     # replace occupancy load
    #     peopledef = people.peopleDefinition
    #     density_internalload = (acm_load_set[spacetype]["people_per_1000sqft"]/92.903).round(3) # convert per_1000sqft to per_m2 
    #     fraction_sensible = (acm_load_set[spacetype]["sensible_heat_per_person"]/(acm_load_set[spacetype]["sensible_heat_per_person"]+acm_load_set[spacetype]["latent_heat_per_person"])).round(3)
    #     peopledef.setNumberOfPeopleCalculationMethod("People/Area", space.floorArea())
    #     peopledef.setPeopleperSpaceFloorArea(density_internalload)   
    #     peopledef.setSensibleHeatFraction(fraction_sensible)
    #     runner.registerInfo("occupancy - internal load update on object (#{peopledef.name}): PeopleperSpaceFloorArea = #{density_internalload} W/m2, SensibleHeatFraction = #{fraction_sensible}, calculation method = #{peopledef.numberofPeopleCalculationMethod}")
    #   end
    # end
    # runner.registerInfo("occupancy - #{sch_ruleset_occupancy.name} applied to #{count_people} 'people' object(s).")

    # #------- SWH
    # count_swh = 0
    # sch_ruleset_swh = create_sched_ruleset(standards, model, acm_schedule_set, acm_swh_schedule_name)
    # if model.getWaterUseEquipments.size > 0
    #   # assumptions
    #   water_heat_capacity_j_per_kg_c = 4182.0
    #   water_density_kg_per_m3 = 1000.0
    #   t_water_out_c = 60.0
    #   t_water_in_c = 10.0
    #   flow_fraction_peak = 1.0
    #   # calculating/applying peak flow rate
    #   floor_area_building_m2 = model.building.get.floorArea.round(3)
    #   floor_area_building_sqft = OpenStudio.convert(floor_area_building_m2, 'm^2', 'ft^2').get
    #   total_num_people_per_1000sqft_acm = acm_load_set[spacetype]['people_per_1000sqft']
    #   total_num_people_peak = (total_num_people_per_1000sqft_acm * (floor_area_building_sqft/1000.0)).round(3)
    #   density_internalload_btu_per_hr_person = (acm_load_set[spacetype]["hotwater_btu_per_hr_per_person"])
    #   density_internalload_btu_per_hr = ((acm_load_set[spacetype]["hotwater_btu_per_hr_per_person"])*total_num_people_peak).round(3)
    #   density_internalload_w = OpenStudio.convert(density_internalload_btu_per_hr, 'Btu/hr', 'W').get.round(3)
    #   peak_flow_rate_m3_per_s = (density_internalload_w / (flow_fraction_peak*water_heat_capacity_j_per_kg_c*(t_water_out_c-t_water_in_c)*water_density_kg_per_m3)).round(6)
    #   runner.registerInfo("water heating - building total floor area = #{floor_area_building_m2} m2")
    #   runner.registerInfo("water heating - ACM occupant load (#{spacetype}) = #{total_num_people_per_1000sqft_acm} people/1000sqft")
    #   runner.registerInfo("water heating - max number of people in building = #{total_num_people_peak} people")
    #   runner.registerInfo("water heating - ACM hot water load = #{density_internalload_btu_per_hr_person} Btu/hr-person")
    #   runner.registerInfo("water heating - ACM hot water load = #{density_internalload_btu_per_hr} Btu/hr")
    #   runner.registerInfo("water heating - ACM hot water load = #{density_internalload_w} W")
    #   runner.registerInfo("water heating - assuming constant water_heat_capacity_j_per_kg_c = #{water_heat_capacity_j_per_kg_c}")
    #   runner.registerInfo("water heating - assuming constant water_density_kg_per_m3 = #{water_density_kg_per_m3}")
    #   runner.registerInfo("water heating - assuming constant t_water_out_c = #{t_water_out_c}")
    #   runner.registerInfo("water heating - assuming constant t_water_in_c = #{t_water_in_c}")
    #   runner.registerInfo("water heating - assuming constant flow_fraction_peak = #{flow_fraction_peak}")
    #   runner.registerInfo("water heating - peak flow rate equivalent to ACM = #{peak_flow_rate_m3_per_s} m3/sec")
    #   model.getWaterUseEquipments.each do |wateruse_equipment|
    #     wateruse_equipment.setFlowRateFractionSchedule(sch_ruleset_swh)
    #     runner.registerInfo("water heating - #{sch_ruleset_swh.name} applied to 'water use equipment' object: #{wateruse_equipment.name}")
    #     wudef = wateruse_equipment.waterUseEquipmentDefinition
    #     peak_flow_rate_previous = wudef.peakFlowRate.round(6)
    #     wudef.setPeakFlowRate(peak_flow_rate_m3_per_s)
    #     runner.registerInfo("water heating - peak flow rate replaced from #{peak_flow_rate_previous} to #{peak_flow_rate_m3_per_s} m3/sec")
    #     count_swh += 1
    #   end
    # end

    # #------- EQUIPMENT
    # count_equip_elec = 0
    # sch_ruleset_equipment = create_sched_ruleset(standards, model, acm_schedule_set, acm_equipment_schedule_name)
    # model.getSpaces.sort.each do |space|
    #   if space.electricEquipment.size > 0
    #     runner.registerInfo("plug load - division criteria = space #{space.name}")
    #     space.electricEquipment.each do |ee|
    #       ee.setSchedule(sch_ruleset_equipment)
    #       runner.registerInfo("plug load - internal load update on object (#{ee.name}): schedule name = #{sch_ruleset_equipment.name}")
    #       ee = ee.electricEquipmentDefinition
    #       density_internalload = (acm_load_set[spacetype]["receptacle_load_w_per_sqft"]/92.903).round(3) # convert per_1000sqft to per_m2
    #       ee.setDesignLevelCalculationMethod("Watts/Area", space.floorArea, space.numberOfPeople)
    #       ee.setWattsperSpaceFloorArea(density_internalload)    
    #       runner.registerInfo("plug load - internal load update on object (#{ee.name}): WattsperSpaceFloorArea = #{density_internalload} W/m2, calculation method = #{ee.designLevelCalculationMethod}")
    #       count_equip_elec += 1
    #     end
    #   end
    # end
    # model.getSpaceTypes.sort.each do |space|
    #   if space.electricEquipment.size > 0
    #     runner.registerInfo("plug load - division criteria = space type (#{space.name})")
    #     space.electricEquipment.each do |ee|
    #       ee.setSchedule(sch_ruleset_equipment)
    #       runner.registerInfo("plug load - internal load update on object (#{ee.name}): schedule name = #{sch_ruleset_equipment.name}")
    #       ee = ee.electricEquipmentDefinition
    #       density_internalload = (acm_load_set[spacetype]["receptacle_load_w_per_sqft"]/92.903).round(3) # convert per_1000sqft to per_m2
    #       ee.setDesignLevelCalculationMethod("Watts/Area", space.floorArea, space.getNumberOfPeople(space.floorArea))
    #       ee.setWattsperSpaceFloorArea(density_internalload)
    #       runner.registerInfo("plug load - internal load update on object (#{ee.name}): WattsperSpaceFloorArea = #{density_internalload} W/m2, calculation method = #{ee.designLevelCalculationMethod}")
    #       count_equip_elec += 1
    #     end
    #   end
    # end

    # #------- INFILTRATION
    # count_infil = 0
    # sch_ruleset_infiltration = create_sched_ruleset(standards, model, acm_schedule_set, acm_infiltration_schedule_name)
    # model.getSpaceInfiltrationDesignFlowRates.each do |infil|
    #   infil.setSchedule(sch_ruleset_infiltration)
    #   count_infil += 1
    # end
    # model.getSpaceInfiltrationEffectiveLeakageAreas.each do |infil|
    #   infil.setSchedule(sch_ruleset_infiltration)
    #   count_infil += 1
    # end
    # model.getSpaceInfiltrationFlowCoefficients.each do |infil|
    #   infil.setSchedule(sch_ruleset_infiltration)
    #   count_infil += 1
    # end
    # runner.registerInfo("infiltration - #{sch_ruleset_infiltration.name} applied to #{count_infil} infiltration (design flow rate|effective leakage area|flow coefficient) object(s).")

    # #------- HVAC HTG/CLG SETPOINTS
    # heating_sch = create_sched_ruleset(standards, model, acm_schedule_set, acm_hvac_stpt_htg)
    # cooling_sch = create_sched_ruleset(standards, model, acm_schedule_set, acm_hvac_stpt_clg)
    # count_thermalzones = 0
    # selected_zones = model.getThermalZones
    # if heating_sch || cooling_sch
    #   selected_zones.each do |zone|
    #     thermostatSetpointDualSetpoint = zone.thermostatSetpointDualSetpoint
    #     if thermostatSetpointDualSetpoint.empty?
    #       runner.registerWarning("Cannot find existing thermostat for thermal zone '#{zone.name}', skipping.")
    #       next
    #     end
    #     thermostatSetpointDualSetpoint = thermostatSetpointDualSetpoint.get
    #     # make sure this thermostat is unique to this zone
    #     if thermostatSetpointDualSetpoint.getSources('OS_ThermalZone'.to_IddObjectType).size > 1
    #       oldThermostat = thermostatSetpointDualSetpoint
    #       thermostatSetpointDualSetpoint = OpenStudio::Model::ThermostatSetpointDualSetpoint.new(model)
    #       unless oldThermostat.heatingSetpointTemperatureSchedule.empty?
    #         thermostatSetpointDualSetpoint.setHeatingSetpointTemperatureSchedule(oldThermostat.heatingSetpointTemperatureSchedule.get)
    #       end
    #       unless oldThermostat.coolingSetpointTemperatureSchedule.empty?
    #         thermostatSetpointDualSetpoint.setCoolingSetpointTemperatureSchedule(oldThermostat.coolingSetpointTemperatureSchedule.get)
    #       end
    #       zone.setThermostatSetpointDualSetpoint(thermostatSetpointDualSetpoint)
    #     end
    #     if heating_sch && !thermostatSetpointDualSetpoint.setHeatingSetpointTemperatureSchedule(heating_sch)
    #       runner.registerError("Script Error - cannot set heating schedule for thermal zone '#{zone.name}'.")
    #       return false
    #     end
    #     if cooling_sch && !thermostatSetpointDualSetpoint.setCoolingSetpointTemperatureSchedule(cooling_sch)
    #       runner.registerError("Script Error - cannot set cooling schedule for thermal zone '#{zone.name}'.")
    #       return false
    #     end
    #     count_thermalzones += 1
    #   end
    # end
    # runner.registerInfo("HVAC - heating/cooling setpoints (#{heating_sch.name} and #{cooling_sch.name}) applied to #{count_thermalzones} thermal zones")

    # #------- HVAC AVAILABILITY
    # count_availability = 0
    # sch_ruleset_hvacavail = create_sched_ruleset(standards, model, acm_schedule_set, acm_operations_schedule_name)
    # # any better/efficient coding for these lines below?
    # if model.getAirLoopHVACs.size > 0
    #   runner.registerInfo("HVAC - found #{model.getAirLoopHVACs.size} AirLoopHVAC object(s)")
    #   model.getAirLoopHVACs.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACBaseboardConvectiveElectrics.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACBaseboardConvectiveElectrics.size} ZoneHVACBaseboardConvectiveElectric object(s)")
    #   model.getZoneHVACBaseboardConvectiveElectrics.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACBaseboardConvectiveWaters.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACBaseboardConvectiveWaters.size} ZoneHVACBaseboardConvectiveWater object(s)")
    #   model.getZoneHVACBaseboardConvectiveWaters.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACBaseboardRadiantConvectiveElectrics.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACBaseboardRadiantConvectiveElectrics.size} ZoneHVACBaseboardRadiantConvectiveElectric object(s)")
    #   model.getZoneHVACBaseboardRadiantConvectiveElectrics.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACBaseboardRadiantConvectiveWaters.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACBaseboardRadiantConvectiveWaters.size} ZoneHVACBaseboardRadiantConvectiveWater object(s)")
    #   model.getZoneHVACBaseboardRadiantConvectiveWaters.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACCoolingPanelRadiantConvectiveWaters.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACCoolingPanelRadiantConvectiveWaters.size} ZoneHVACCoolingPanelRadiantConvectiveWater object(s)")
    #   model.getZoneHVACCoolingPanelRadiantConvectiveWaters.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACDehumidifierDXs.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACDehumidifierDXs.size} ZoneHVACDehumidifierDX object(s)")
    #   model.getZoneHVACDehumidifierDXs.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACEnergyRecoveryVentilators.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACEnergyRecoveryVentilators.size} ZoneHVACEnergyRecoveryVentilator object(s)")
    #   model.getZoneHVACEnergyRecoveryVentilators.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACFourPipeFanCoils.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACFourPipeFanCoils.size} ZoneHVACFourPipeFanCoil object(s)")
    #   model.getZoneHVACFourPipeFanCoils.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACHighTemperatureRadiants.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACHighTemperatureRadiants.size} ZoneHVACHighTemperatureRadiant object(s)")
    #   model.getZoneHVACHighTemperatureRadiants.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACIdealLoadsAirSystems.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACIdealLoadsAirSystems.size} ZoneHVACIdealLoadsAirSystem object(s)")
    #   model.getZoneHVACIdealLoadsAirSystems.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACLowTemperatureRadiantElectrics.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACLowTemperatureRadiantElectrics.size} ZoneHVACLowTemperatureRadiantElectric object(s)")
    #   model.getZoneHVACLowTemperatureRadiantElectrics.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACLowTempRadiantConstFlows.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACLowTempRadiantConstFlows.size} ZoneHVACLowTempRadiantConstFlow object(s)")
    #   model.getZoneHVACLowTempRadiantConstFlows.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACLowTempRadiantVarFlows.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACLowTempRadiantVarFlows.size} ZoneHVACLowTempRadiantVarFlow object(s)")
    #   model.getZoneHVACLowTempRadiantVarFlows.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACPackagedTerminalAirConditioners.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACPackagedTerminalAirConditioners.size} ZoneHVACPackagedTerminalAirConditioner object(s)")
    #   model.getZoneHVACPackagedTerminalAirConditioners.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACPackagedTerminalHeatPumps.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACPackagedTerminalHeatPumps.size} ZoneHVACPackagedTerminalHeatPumps object(s)")
    #   model.getZoneHVACPackagedTerminalHeatPumps.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACUnitHeaters.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACUnitHeaters.size} ZoneHVACUnitHeater object(s)")
    #   model.getZoneHVACUnitHeaters.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACUnitVentilators.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACUnitVentilators.size} ZoneHVACUnitVentilator object(s)")
    #   model.getZoneHVACUnitVentilators.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end
    # if model.getZoneHVACWaterToAirHeatPumps.size > 0
    #   runner.registerInfo("HVAC - found #{model.getZoneHVACWaterToAirHeatPumps.size} ZoneHVACWaterToAirHeatPump object(s)")
    #   model.getZoneHVACWaterToAirHeatPumps.each do |sys|
    #     runner.registerInfo("HVAC - overriding availability schedule in '#{sys.name}' to #{sch_ruleset_hvacavail.name}")
    #     sys.setAvailabilitySchedule(sch_ruleset_hvacavail)
    #     count_availability += 1
    #   end
    # end

    # reporting final condition of model
    runner.registerFinalCondition("Swapped lights (#{count_lights} objects), occupancy (#{count_people} objects), SWH (#{count_swh} objects), electric equipment (#{count_equip_elec} objects), infiltration (#{count_infil} objects), htg/clg setpoint (#{count_thermalzones} objects), and HVAC availability (#{count_availability} objects) schedules in the model.")

    true
  end

end

# this allows the measure to be use by the application
SwaptSchedulesERMA.new.registerWithApplication
