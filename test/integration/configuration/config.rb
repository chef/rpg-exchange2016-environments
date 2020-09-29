# frozen_string_literal: true

# Configuration helper for Exchange 2016 & Inspec
# - Terraform expects a JSON variable file
# - Inspec expects a YAML attribute file
# This allows to store all transient parameters in one place.
# If any of the @config keys are exported as environment variables in uppercase, these take precedence.
require 'json'
require 'yaml'

module Config
  # helper method for adding random strings
  def self.add_random_string(length = 15)
    (0...length).map { rand(65..90).chr }.join.downcase.to_s
  end

  # Config for terraform / inspec in the below hash
  @config = {
    # Generic AWS resource parameters
    aws_region: 'eu-north-1',
    aws_profile: 'partner-engineering',
    ssh_key_name: "ssh-key-#{add_random_string}",
    execute_script: 'scripts/break_exchange.ps1',
    setup_script: '../../../scripts/exchange_setup.ps1',
    remediation_profile: '', # set to copy across the remediation cookbook and run it
    inspec_profile: '', # set to a profile for target mode against host
    instance_password: 'ExchPW123!'
  }

  def self.config
    @config
  end

  # This method ensures any environment variables take precedence.
  def self.update_from_environment
    @config.each { |k, v| @config[k] = ENV[k.to_s.upcase] || v }
  end

  # Create JSON for terraform
  def self.store_json(file_name = 'aws-inspec.tfvars')
    update_from_environment
    File.open(File.join(File.dirname(__FILE__), '..', 'build', file_name), 'w') do |f|
      f.write(@config.to_json)
    end
  end

  # Create YAML for inspec
  def self.store_yaml(file_name = 'aws-inspec-attributes.yaml')
    update_from_environment
    File.open(File.join(File.dirname(__FILE__), '..', 'build', file_name), 'w') do |f|
      f.write(@config.to_yaml)
    end
  end

  def self.get_tf_output_vars(file_name = 'outputs.tf')
    # let's assume that all lines starting with 'output' contain the desired target name
    # (brittle but this way we don't need to preserve a list)
    outputs = []
    outputs_file = File.join(File.dirname(__FILE__), '..', 'build', file_name)
    File.read(outputs_file).lines.each do |line|
      next if !line.start_with?('output')
      outputs += [line.sub(/^output \"/, '').sub(/\" {\n/, '')]
    end
    outputs
  end

  def self.update_yaml(file_name = 'aws-inspec-attributes.yaml')
    build_dir = File.join(File.dirname(__FILE__), '..', 'build')
    contents = YAML.load_file(File.join(build_dir, file_name))
    outputs = get_tf_output_vars
    outputs.each do |tf|
      # also assuming single values here
      value = `cd #{build_dir} && terraform output #{tf}`.strip
      contents[tf.to_sym] = value
    end
    File.open(File.join(File.dirname(__FILE__), '..', 'build', file_name), 'w') do |f|
      f.write(contents.to_yaml)
    end
  end
end
