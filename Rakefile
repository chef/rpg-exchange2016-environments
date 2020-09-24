#!/usr/bin/env rake
# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'
require_relative 'test/integration/configuration/config'
require_relative 'tasks/check_json_results'
require 'aws-sdk-ec2'
require 'open3'
require 'winrm'
require 'winrm-fs'
require 'winrm-elevated'

INTEGRATION_DIR = File.join(File.dirname(__FILE__), 'test', 'integration')
TERRAFORM_DIR = File.join(INTEGRATION_DIR, 'build')
TF_VAR_FILE_NAME = 'exchange2016-rpg.tfvars.json'
TF_VAR_FILE = File.join(TERRAFORM_DIR, TF_VAR_FILE_NAME)
TF_PLAN_FILE = 'exchange2016-rpg.plan'
PROFILE_ATTRIBUTES = 'exchange2016-rpg-attributes.yaml'
REMEDIATION_PROFILE = '../compliance-remediation/test/CIS_Microsoft_Exchange_Server_2016_v_1_0_0_cookbook'
INSPEC_PROFILE = '../cis-exchange2016-benchmark'

# Rubocop
desc 'Run Rubocop lint checks'
task :rubocop do
  RuboCop::RakeTask.new
end

# lint the project
desc 'Run robocop linter'
task lint: [:rubocop]

# run tests
task default: [:lint, 'rpg:check']

namespace :rpg do
  task :tf_dir do
    Dir.chdir(TERRAFORM_DIR)
  end

  # run inspec check to verify that the profile is properly configured
  task :check do
    dir = File.join(File.dirname(__FILE__))
    sh("bundle exec inspec check #{dir}")
    # run inspec check on the sample profile to ensure all resources are loaded okay
    sh('bundle exec inspec check .')
  end

  def configure(variables_file, attributes_file)
    puts '----> Generating terraform and inspec variable files'
    Config.store_json(variables_file)
    Config.store_yaml(attributes_file)
    Config.config
  end

  task init_workspace: [:tf_dir] do
    puts '----> Initializing terraform workspace'
    # Initialize terraform workspace
    cmd = format('terraform init')
    sh(cmd)
  end

  # This is a standalone task for convenience that only updates configuration for InSpec and Terraform.
  task :configure do
    puts '----> Updating configuration settings'
    configure(TF_VAR_FILE_NAME, PROFILE_ATTRIBUTES)
  end

  task plan_integration_tests: %i[tf_dir init_workspace] do
    if File.exist?(TF_VAR_FILE)
      puts '----> Previous run not cleaned up - running cleanup...'
      Rake::Task['rpg:cleanup_integration_tests'].execute
    end
    configure(TF_VAR_FILE_NAME, PROFILE_ATTRIBUTES)
    puts '----> Generating the Plan'
    # Create the plan that can be applied to AWS
    cmd = format('terraform plan -var-file=%<var_file>s -out %<plan_file>s', var_file: TF_VAR_FILE_NAME, plan_file: TF_PLAN_FILE)
    sh(cmd)
  end

  task setup_integration_tests: %i[tf_dir plan_integration_tests] do
    puts '----> Applying the plan'
    # Apply the plan
    cmd = format('terraform apply %<plan_file>s', plan_file: TF_PLAN_FILE)
    sh(cmd)
    puts '----> Adding terraform outputs to InSpec variable file'
    Config.update_yaml(PROFILE_ATTRIBUTES)
    attributes = YAML.load_file(File.join(TERRAFORM_DIR, PROFILE_ATTRIBUTES))

    puts "----> Writing SSH key file #{attributes[:ssh_key_name]} for VM"
    File.open(File.join(File.dirname(__FILE__), attributes[:ssh_key_name]), 'w') do |f|
      f.write(attributes[:ssh_private_key_pem])
    end
    sh("chmod 400 #{File.join(File.dirname(__FILE__), 'ssh-key-*')}")

    Rake::Task['rpg:run_precursor_scripts'].execute

    puts '----> Allocating Elastic IP to Exchange Node'
    exch_public_ip = assign_elastic_ip
    attributes[:instance_ip] = {}
    attributes[:instance_ip] = exch_public_ip
    File.open(File.join(TERRAFORM_DIR, PROFILE_ATTRIBUTES), 'w') { |f| YAML.dump(attributes, f) }

    puts 'SUCCESS - Exchange Server Public IP - ' + exch_public_ip

    username = attributes[:domain_netbios_name] + '\\' + attributes[:instance_username]
    password = attributes[:instance_password]

    script_target = ENV['SETUP_SCRIPT'] || attributes[:setup_script]
    raise "Could not find script file: #{script_target}" unless File.exist?(script_target)

    puts '---> Installing Chef Client and Running Setup Script'
    counter = 0
    status = {}
    while counter < 20
      conn = winrm_connection(attributes[:instance_ip], attributes[:instance_username], attributes[:instance_password])
      file_manager = WinRM::FS::FileManager.new(conn)
      sleep(60)
      file_manager.upload(script_target, "C:/#{script_target}")
      sleep(60)
      conn.shell(:elevated) do |shell|
        shell.username = attributes[:domain_netbios_name] + '\\' + attributes[:instance_username]
        shell.password = attributes[:instance_password]
        output = shell.run("C:/#{script_target}") do |stdout, stderr|
          STDOUT.print stdout
          STDERR.print stderr
        end
        status = 'success' if output.exitcode.zero?
        puts "The script exited with exit code #{output.exitcode}"
      end
      break if status == 'success'

      sleep(10)
      counter += 1
    end

    counter = 0
    puts '---> Waiting for bootstrap to finish...'
    while counter < 20
      cmd = "inspec detect -t winrm://#{exch_public_ip} --user='#{username}' --password='#{password}'"
      stdout, stderr, status = Open3.capture3(cmd)
      puts stdout
      puts stderr
      break if status.success?

      sleep(10)
      counter += 1
    end
    puts 'Instances responding on WinRM...'
  end

  task :run_precursor_scripts do
    puts '----> Stopping unused instances'
    stop_unused_instances

    puts '----> Modifying security group to allow remote connection'
    modify_security_groups

    puts '----> Configuring route table of Exchange Server subnet to allow RDP connection'
    allow_traffic_on_exchange_node
  end

  def modify_security_groups
    ec2_client = Aws::EC2::Client.new(region: 'eu-north-1')
    exchange_vpc = ec2_client.describe_vpcs(filters: [{ name: 'tag:Name', values: ['exchange-stack*'] }])

    if exchange_vpc.vpcs.empty?
      puts 'FAILED - No VPC found in Exchange Stack'
    else
      vpc_id = exchange_vpc[0][0].vpc_id
      vpc_domainmembers_sgs = ec2_client.describe_security_groups(filters: [{
                                                                                name: 'vpc-id',
                                                                                values: [vpc_id] }, {
                                                                                name: 'group-name', values: ['exchange-stack-ADStack-*-DomainMembers*']
                                                                            }])
      sg_id = vpc_domainmembers_sgs.security_groups[0][:group_id]
      begin
        ec2_client.authorize_security_group_ingress({group_id: sg_id, ip_permissions: [{
                                                                                           ip_protocol: 'tcp',
                                                                                           from_port: 3389,
                                                                                           to_port: 3389,
                                                                                           ip_ranges: [{
                                                                                                           cidr_ip: '0.0.0.0/0'
                                                                                                       }]
                                                                                       }]
                                                    })
        ec2_client.authorize_security_group_ingress({group_id: sg_id, ip_permissions: [{
                                                                                           ip_protocol: 'tcp',
                                                                                           from_port: 5985,
                                                                                           to_port: 5985,
                                                                                           ip_ranges: [{
                                                                                                           cidr_ip: '0.0.0.0/0'
                                                                                                       }]
                                                                                       }]
                                                    })
        puts 'SUCCESS - RDP/WinRM traffic opened on Exchange Stack'
      rescue Aws::EC2::Errors::InvalidPermissionDuplicate
        puts 'SKIPPED - RDP/WinRM rule already exists on Exchange Stack'
      end
    end
  end

  def allow_traffic_on_exchange_node
    ec2_client = Aws::EC2::Client.new(region: 'eu-north-1')

    exchange_instance = ec2_client.describe_instances(filters: [{ name: 'tag:Name', values: ['ExchNodeMain'] }])

    exchange_subnet_id = exchange_instance.reservations[0].instances[0].subnet_id
    exchange_vpc_id = exchange_instance.reservations[0].instances[0].vpc_id

    exchange_igw = ec2_client.describe_internet_gateways(filters: [{
                                                                       name: 'attachment.vpc-id',
                                                                       values: [exchange_vpc_id]
                                                                   }])
    igw_id = exchange_igw.internet_gateways[0].internet_gateway_id

    exchange_route_tables = ec2_client.describe_route_tables(filters: [{
                                                                           name: 'association.subnet-id',
                                                                           values: [exchange_subnet_id]
                                                                       }])
    route_table_id = exchange_route_tables.route_tables[0].associations[0].route_table_id

    ec2_client.replace_route({ route_table_id: route_table_id, destination_cidr_block: '0.0.0.0/0', gateway_id: igw_id })

    puts 'SUCCESS - Route Table gateway modified on Exchange Node'
  end

  def release_elastic_ip
    ec2_client = Aws::EC2::Client.new(region: 'eu-north-1')
    attributes = YAML.load_file(File.join(TERRAFORM_DIR, PROFILE_ATTRIBUTES))

    puts '----> Releasing Exchange Elastic IP'

    ip = attributes[:instance_ip]

    unless ip.nil?
      begin
        elastic_ip = ec2_client.describe_addresses(public_ips: [ip])
        ec2_client.disassociate_address(public_ip: ip)

        ec2_client.release_address({ allocation_id: elastic_ip.addresses[0].allocation_id })
        puts 'SUCCESS - IP Released'
      rescue Aws::EC2::Errors::InvalidAddressNotFound
        puts "SKIPPED - Elastic IP #{ip} has already been released"
      end
    end
  end

  def assign_elastic_ip
    ec2_client = Aws::EC2::Client.new(region: 'eu-north-1')

    exchange_instance = ec2_client.describe_instances(filters: [{ name: 'tag:Name', values:['ExchNodeMain'] }])
    exchange_instance_id = exchange_instance.reservations[0].instances[0].instance_id

    puts 'Allocating the address for the instance...'
    elastic_ip = ec2_client.allocate_address({ domain: 'vpc' })

    puts 'Associating the address with the instance...'
    ec2_client.associate_address({ allocation_id: elastic_ip.allocation_id, instance_id: exchange_instance_id })

    elastic_ip.public_ip
  end

  def stop_unused_instances
    ec2 = Aws::EC2::Resource.new(region: 'eu-north-1')
    ec2.instances({ filters: [{ name: 'tag:Name', values: ['Stop*'] }] }).each do |instance|
      case instance.state.code
      when 48  # terminated
        puts "#{instance.id} is terminated, so you cannot stop it"
      when 64  # stopping
        puts "#{instance.id} is stopping, so it will be stopped in a bit"
      when 80  # stopped
        puts "#{instance.id} is already stopped"
      else
        instance.stop
      end
    end
  end

  def winrm_connection(ip, username, password)
    WinRM::Connection.new({
                            endpoint: "http://#{ip}:5985/wsman",
                            user: username,
                            password: password
                          })
  end

  task :run_script do
    attributes = YAML.load_file(File.join(TERRAFORM_DIR, PROFILE_ATTRIBUTES))
    script_target = ENV['EXE_SCRIPT'] || attributes[:execute_script]
    raise "Could not find script file: #{script_target}" unless File.exist?(script_target)

    counter = 0
    status = {}
    while counter < 20
      conn = winrm_connection(attributes[:instance_ip], attributes[:instance_username], attributes[:instance_password])
      file_manager = WinRM::FS::FileManager.new(conn)
      sleep(60)
      file_manager.upload(script_target, "C:/#{script_target}")
      sleep(60)
      conn.shell(:elevated) do |shell|
        shell.username =  attributes[:domain_netbios_name] + "\\" + attributes[:instance_username]
        shell.password = attributes[:instance_password]
        output = shell.run("C:/#{script_target}") do |stdout, stderr|
          STDOUT.print stdout
          STDERR.print stderr
        end
        status = 'success' if output.exitcode.zero?
        puts "The script exited with exit code #{output.exitcode}"
      end
    break if status == 'success'

    sleep(10)
    counter += 1
    end
  end

  task :run_scan do
    puts '----> Running InSpec tests'
    reporter_name_suffix = ENV['INSPEC_REPORT_NAME'] || 'inspec-output'
    attributes = YAML.load_file(File.join(TERRAFORM_DIR, PROFILE_ATTRIBUTES))
    # take profile target from env before checking attributes
    profile_target = INSPEC_PROFILE || attributes['inspec_profile']

    reporter_name = reporter_name_suffix.to_s
    cmd = 'bundle exec inspec exec %s -t winrm://%s@%s --password="%s" --input-file %s/build/%s --reporter cli json:results/%s.json html:%s.html --chef-license=accept-silent'
    cmd += '; rc=$?; if [ $rc -eq 0 ] || [ $rc -eq 101 ] || [ $rc -eq 100 ]; then exit 0; else exit 1; fi'
    cmd = format(cmd, profile_target, attributes[:instance_username], attributes[:instance_ip], attributes[:instance_password], INTEGRATION_DIR, PROFILE_ATTRIBUTES, reporter_name, reporter_name)
    sh(cmd)
  end

  task :run_remediation do
    attributes = YAML.load_file(File.join(TERRAFORM_DIR, PROFILE_ATTRIBUTES))
    remediation_target = REMEDIATION_PROFILE || attributes[:remediation_profile]
    raise "Could not find remediation profile: #{remediation_target}" unless remediation_target

    cookbook_run_list = "remediation_#{remediation_target.split('/').last.split('_cookbook')[0].downcase}"

    counter = 0
    status = {}
    while counter < 20
      conn = winrm_connection(attributes[:instance_ip], attributes[:instance_username], attributes[:instance_password])
      file_manager = WinRM::FS::FileManager.new(conn)
      sleep(10)
      puts '----> Copying remediation profile'
      file_manager.upload(remediation_target, 'C:/remediation')
      file_manager.upload("#{remediation_target}/cookbooks/remediation_cis_microsoft_exchange_server_2016_v_1_0_0/files/default/CIS_Microsoft_Exchange_Server_2016_v_1_0_0/", 'C:/remediation/cookbooks/remediation_cis_microsoft_exchange_server_2016_v_1_0_0/files/default/')
      sleep(10)
      conn.shell(:elevated) do |shell|
        shell.username = attributes[:instance_username]
        shell.password = attributes[:instance_password]
        output = shell.run("cd C:/remediation/cookbooks/#{cookbook_run_list}; chef-client -z -l info --chef-license accept-silent -o #{cookbook_run_list}") do |stdout, stderr|
          STDOUT.print stdout
          STDERR.print stderr
        end
        puts "The script exited with exit code #{output.exitcode}"
        status = 'success' if output.exitcode.zero?
        puts '----> Retrieving remediation outputs'
        file_manager.download('$env:TEMP/remediation_outputs.yaml', 'remediation_outputs.yaml')
      end
      break if status == 'success'

      sleep(10)
      counter += 1
    end
  end

  task cleanup_integration_tests: [:tf_dir] do
    puts '----> Cleanup'
    release_elastic_ip
    cmd = 'terraform destroy -force -var-file=%s '
    cmd += ' || true' if ENV['CLEANUP_TRAP_NON_ZERO_EXIT']
    cmd = format(cmd, TF_VAR_FILE_NAME)
    sh(cmd) if File.exist?(TF_VAR_FILE)
    sh("rm -f #{File.join(File.dirname(__FILE__), 'ssh-key-*')}")
  end

  task :full_test do
    Rake::Task['rpg:setup_integration_tests'].invoke
    Rake::Task['rpg:run_script'].invoke
    Rake::Task['rpg:run_scan'].invoke
    Rake::Task['rpg:run_remediation'].invoke
    Rake::Task['rpg:run_scan'].invoke
    Rake::Task['rpg:cleanup_integration_tests'].invoke
  end
end
