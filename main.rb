# This is the path to the OpenStudio CLI
# If you call this script using the CLI,
# it will just return the path to the thing you called.
cli = OpenStudio::getOpenStudioCLI

# Setup a directory for all of the output
output_dir_name = 'output'
FileUtils.rm_rf(output_dir_name) 
FileUtils.mkdir(output_dir_name)

# The osw defines the measures to run
osw = OpenStudio::WorkflowJSON.new('example.osw')
# By convention, the directory "measures" located adjacent to the osm
# is include in the measure path. We are going to copy the osw to a new
# location and don't want to also copy the entire measures directory, so
# we add the measure directory absolute path to the measure search path.
osw.addMeasurePath("#{osw.absoluteRootDir}/measures")

# This example uses the built in OpenStudio example model, because it is convenient,
# but model files could be globbed from a directory and loaded. 
model = OpenStudio::Model::exampleModel()
#model = OpenStudio::Model::Model.load('files/seb.osm').get

# For demonstration purposes, just give each model a unique name
model_names = ['one', 'two', 'three']

model_names.each do |name|
  puts name
  # Save the model to a unique location
  model.save(OpenStudio::toPath("#{output_dir_name}/#{name}/#{name}"), true)
  # Update the osw to point to the new model
  osw.setSeedFile("#{name}.osm")
  # Save the osw to a unique location
  new_osw_path = OpenStudio::toPath("#{output_dir_name}/#{name}/#{name}.osw")
  osw.saveAs(new_osw_path)
  # Run the workflow using the OpenStudio cli
  `#{cli} run -w #{new_osw_path}`
end


