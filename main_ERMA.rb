require 'openstudio'
require 'fileutils'
require 'pycall'

# This is the path to the OpenStudio CLI
# If you call this script using the CLI,
# it will just return the path to the thing you called.
cli = OpenStudio::getOpenStudioCLI

# Setup a directory for all of the output
output_dir_name = 'output_ERMA'
FileUtils.rm_rf(output_dir_name)
FileUtils.mkdir(output_dir_name)



# The osw defines the measures to run
osw = OpenStudio::WorkflowJSON.new('example.osw')
# By convention, the directory "measures" located adjacent to the osm
# is include in the measure path. We are going to copy the osw to a new
# location and don't want to also copy the entire measures directory, so
# we add the measure directory absolute path to the measure search path.
osw.addMeasurePath("#{osw.absoluteRootDir}/measures")



# puts osw.workflowSteps

# This example uses the built in OpenStudio example model, because it is convenient,
# but model files could be globbed from a directory and loaded.
model = OpenStudio::Model::exampleModel()
#model = OpenStudio::Model::Model.load('files/seb.osm').get

# For demonstration purposes, just give each model a unique name
# model_names = ['one', 'two', 'three']
list_models = ['576ESU_copy', '614_Cutterman', '614_Cutterman_2', 'N2', 'N23', 'N73', 'N96_2020', 'R2 copy', 'T1 copy']
list_models = ['576ESU_copy', 'R2 copy', 'T1 copy']
outage_types = ['Power_and_Heat', 'Heat_only']
outage_date = ['January 2', 'March 5']

# list_models = ['14_Hangar']
outage_types = ['Power_and_Heat']
#
#
list_models.each do |model_name|
  puts model_name
  model_path = '/run/in.osm'
  # Load model building by building
  model = OpenStudio::Model::Model.load("ERMA_Power_Outage/#{model_name}/#{model_path}").get
  outage_types.each do |outage_type|
    # Save the model to a unique location
    name_individual_simulation = "#{outage_type}_#{model_name}"
    # FileUtils.mkdir("#{output_dir_name}/#{name_individual_simulation}")
    model.save(OpenStudio::toPath("#{osw.absoluteRootDir}/#{output_dir_name}/#{name_individual_simulation}/#{name_individual_simulation}"), true)
    # Update the osw to point to the new model
    osw.setSeedFile("#{name_individual_simulation}.osm")
    # Set Weather file
    # osw.setWeatherFile("ERMA_Power_Outage/Kodiak_Airport_703500_TMY3.epw")
    # # Set measure arguments
    # measure = OpenStudio::MeasureStep.new("set_power_and_heat_off")
    # measure.setArgument("otg_date","June 1")
    # measure.setArgument("otg_hr","1")
    # measure.setArgument("otg_len","20")
    # measure.setArgument("outage_type",outage_type.gsub('_', ' '))
    # measure_type = OpenStudio::MeasureType.new("ModelMeasure")

    # meter_measure1 = OpenStudio::MeasureStep.new("AddMeter")
    # meter_measure1.setArgument("meter_name","Electricity:Facility")
    # meter_measure1.setArgument("reporting_frequency","hourly")
    # measure_type = OpenStudio::MeasureType.new("ModelMeasure")

    # meter_measure2 = OpenStudio::MeasureStep.new("AddMeter")
    # meter_measure2.setArgument("meter_name","NaturalGas:Facility")
    # meter_measure2.setArgument("reporting_frequency","hourly")
    # measure_type = OpenStudio::MeasureType.new("ReportingMeasure")

    # var_measure1 = OpenStudio::MeasureStep.new("AddOutputVariable")
    # var_measure1.setArgument("variable_name","Zone Mean Air Temperature")
    # var_measure1.setArgument("reporting_frequency","hourly")
    # var_measure1.setArgument("key_value","*")
    # measure_type = OpenStudio::MeasureType.new("ReportingMeasure")


    # osw.setWorkflowSteps([measure, meter_measure1, meter_measure2, var_measure1])

    

    # # Save the osw to a unique location
    # new_osw_path = OpenStudio::toPath("#{osw.absoluteRootDir}/#{output_dir_name}/#{name_individual_simulation}/#{name_individual_simulation}.osw")
    # osw.saveAs(new_osw_path)
    # # Run the workflow using the OpenStudio cli
    # `#{cli} run -w #{new_osw_path}`

    # #Copy ReadVarsESO
    # `cp ReadVarsESO "#{output_dir_name}/#{name_individual_simulation}/run/"`
    # # `#{output_dir_name}/#{name_individual_simulation}/run/ReadVarsESO`
    # # FileUtils.cp(weather_path + epw_file, "#{$strategy}/#{bld}/#{ct}/in.epw")
    # # FileUtils.cp("ReadVarsESO", "#{osw.absoluteRootDir}/#{output_dir_name}/#{name_individual_simulation}/run/")
    # `cd #{output_dir_name}/#{name_individual_simulation}/run/`
    # `ReadVarsESO`
    # `cd #{osw.absoluteRootDir}`
    # # FileUtils.cd("#{$strategy}/#{bld}/#{ct}/")
    # # `ReadVarsESO`
    # # FileUtils.cd("#{osw.absoluteRootDir}")

    # system("energyplus94 -w in.epw in.idf ")
    # system("ReadVarsESO")
  end
end
