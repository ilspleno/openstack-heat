#!/bin/env ruby

require 'httparty'
require 'optparse'
require 'ostruct'
require 'json'
require 'pp'

class FreeNASAPI

	include HTTParty

	base_uri 'http://freenas01.thewoodruffs.org/api/v1.0'
	format :json

	def initialize(u,p)
		self.class.basic_auth u,p
		@user = u
		@pass = p
	end

	def authcredential
		self.class.get("/services/iscsi/authcredential/")
	end

	def create_zvol(name, size)
		parms = { "name"	=> "iSCSI/#{name}",
			  "volsize"	=> size
			}

		self.class.post("/storage/volume/tank/zvols/",
			body: parms.to_json,
			:headers => { 'Content-Type' => 'application/json', 
     				      'Accept'       => 'application/json'}
		)
	end

	def create_extent(name)

		parms = { "iscsi_target_extent_name"    =>  name, 
			  "iscsi_target_extent_type"	=> "Disk",
			  "iscsi_target_extent_disk"	=> "zvol/tank/iSCSI/#{name}"
			}	

		self.class.post("/services/iscsi/extent/", 
                	body: parms.to_json,
			:headers => { 'Content-Type' => 'application/json', 
     				      'Accept'       => 'application/json'}
		)
	end

	def create_auth_user(id,pass)
		
		# Get an unused group id
		groups = []
		auth = authcredential
		auth.each do |u|
			groups << u["iscsi_target_auth_tag"]
		end

		group_num = -1

		if auth.empty?
			group_num = 1
		else
			groups.sort.each_index do |x|

				if (groups[x+1].nil?) 
					group_num = groups[x] + 1
				end

				if (groups[x] + 1) != (groups[x+1])
					group_num = groups[x] + 1
					break
				end
					
			end
		end


		parms = { "iscsi_target_auth_tag"	=> group_num,
			  "iscsi_target_auth_user"	=> id,
			  "iscsi_target_auth_secret"	=> pass
			}

		self.class.post("/services/iscsi/authcredential/",
			body: parms.to_json,
			:headers => { 'Content-Type' => 'application/json',
                                      'Accept'       => 'application/json'},
			:basic_auth => { :username => @user, :password => @pass }
		)

	end

	def create_target(name)
		
		parms = { "iscsi_target_name" => name }
		self.class.post "/services/iscsi/target/",
			body: parms.to_json,
			:headers => { 'Content-Type' => 'application/json',
                                      'Accept'       => 'application/json'}


	end

	def create_target_group(tgt_id, auth_id)

		parms = { "iscsi_target"		=> tgt_id,
			  "iscsi_target_authgroup" 	=> auth_id,
			  "iscsi_target_authtype"	=> "CHAP",
			  "iscsi_target_portalgroup"	=> "1",
			  "iscsi_target_initiatorgroup"	=> "1"
			}

		self.class.post "/services/iscsi/targetgroup/",
			body: parms.to_json,
			:headers => { 'Content-Type' => 'application/json',
                                      'Accept'       => 'application/json'}
			  

	end

	def target_to_extent(tgt_id, extent_id)

		parms = { "iscsi_target"	=> tgt_id,
			  "iscsi_extent"	=> extent_id
			}

		self.class.post "/services/iscsi/targettoextent/",
			body: parms.to_json,
			:headers => { 'Content-Type' => 'application/json',
                                      'Accept'       => 'application/json'}

	end

	def get_zvol(name)

		zvols = self.class.get("/storage/volume/tank/zvols/")
		zvols.each do |x|
			if x["name"] == name
				return x
			end
		end
		return nil

	end

	def get_extent(name)
		extents = self.class.get("/services/iscsi/extent/")
		extents.each do |x|
			if x["iscsi_target_extent_name"] == name
				return x
			end
		end
		return nil

	end

	def get_target(name)

		targets = self.class.get("/services/iscsi/target/")
		targets.each do |x|
			if x["iscsi_target_name"] == name
				return x
			end
		end
		return nil

	end

	def get_target_extent(target, extent)

		tx = self.class.get("/services/iscsi/targettoextent/")	
		tx.each do |x|
			if (x["iscsi_target"] == target) and (x["iscsi_extent"] == extent)
				return x
			end
		end
		return nil
		

	end

	def get_volume(name)

		vols = self.class.get("/storage/volume/")
		puts "VOLUMES:"
		pp vols
		vols.each do |x|
			if x["vol_name"] == name
				return x
			end
		end
		return nil

	end

	def delete_target_to_extent(id)
		self.class.delete("/services/iscsi/targettoextent/#{id}/")
	end

	def delete_target(id)
		self.class.delete("/services/iscsi/target/#{id}/")
	end

	def delete_extent(id)
		self.class.delete("/services/iscsi/extent/#{id}/")
	end

	def delete_zvol(name)
		self.class.delete("/storage/volume/tank/zvols/iSCSI/#{name}/")

	end

	

	

end

class Options

	def self.parse(args)

		options = OpenStruct.new

		opt_parser = OptionParser.new do |opts|

			opts.banner = "Usage: freenas.rb [options]"
			opts.separator ""
			opts.separator "Specific options:"

			opts.on("-a", "--action ACTION", [:create, :delete],
				"Action to be performed (create, delete)") do |action|
				options.action = action
			end

			opts.on("-n", "--name DISK", "Name of disk to operate on") do |name|
				options.name = name
			end

			opts.on("-p", "--project NAME", "Name of project for this disk") do |project|
				options.project = project
			end

			opts.on("-s", "--size SIZE", "Size of disk") do |size|
				options.size = size
			end

		end	
		
		opt_parser.parse!(args)

		# Check for required parameters
		if options.action.nil?
			puts "Action not defined!"
			exit 1
		end

		if options.action == :create
			# Require both options
			if options.name.nil? || options.project.nil?
				puts "You must provide all options during creation!"
				exit 1
			end	

		end

		if (options.action == :delete) && (options.name.nil?)
			puts "You must provide a disk name to delete!"
			exit
		end

		options

	end

end

class FreeNAS


	def initialize(u,p)
		@username = u
		@password = p
		@fn = FreeNASAPI.new u,p
	end

	def genpass(p)
		(p + 'wibblewibblewibblewibblewibble')[0..16]
	end

	def contains_user?(user, arr)
		
		arr.each do |i|
			if i["iscsi_target_auth_user"] == user
				return i
			end
		end

		return nil
	end


	def create(name, size, project)
		
		# Create an auth user - See if user is already created
		auth = @fn.authcredential

		# Get User ID or nil	
		puts "Identifying user..."
		user_tag = contains_user? project, auth	
		if !user_tag
			user_tag = @fn.create_auth_user(project, genpass(project))
		end
		pp user_tag

		# Create zvol to hold extent
		puts "Creating zvol..."
		zvol = @fn.create_zvol("#{name}-#{project}", size)
		pp zvol

		# Create a new iscsi disk
		puts "Creating extent..."
		extent = @fn.create_extent("#{name}-#{project}")
		pp extent

		# Create target
		puts "Creating target..."
		tgt = @fn.create_target("#{name}-#{project}")
		pp tgt

		# Create target group
		puts "Creating target group..."
		tgt_group = @fn.create_target_group tgt["id"], user_tag["id"]
		pp tgt_group

		# Associate target to extent
		puts "Associating target to extent..."
		tgt_extent = @fn.target_to_extent tgt["id"], extent["id"]		
		pp tgt_extent
			
	end

	def delete(name, project)

		merge_name = "#{name}-#{project}"

		puts "Deleting iSCSI disk #{merge_name}"

		# Get the IDs for extent, target and target/extent association
		extent = @fn.get_extent(merge_name)
		target = @fn.get_target merge_name.downcase
		tgt_extent = @fn.get_target_extent(target["id"], extent["id"]) unless (target.nil? or extent.nil?)
		#zvol = @fn.get_zvol(merge_name)

		# Start deleting
		pp @fn.delete_target_to_extent tgt_extent["id"] unless tgt_extent.nil?
		pp @fn.delete_target target["id"] unless target.nil?
		pp @fn.delete_extent extent["id"] unless extent.nil?
		pp @fn.delete_zvol merge_name

	end

end

# Main

options = Options.parse(ARGV)
fn = FreeNAS.new "root","eagLi$"

if options.action == :create
	fn.create(options.name, options.size, options.project)
end

if options.action == :delete
	fn.delete(options.name, options.project)
end
