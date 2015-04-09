#!/usr/bin/env ruby
# Convert single mode PSPLib project to json representation
# Usage example: ./PSPLibToJson.rb j3047_9.sm

require 'json'

def job_arrays(n, nj); Array.new(n) { Array.new nj } end
def ix_line_with_prefix(lines, start); lines.index { |line| line.start_with? start } end
def ints(strings); strings.map { |s| s.to_i } end
def pretty_json(hsh); JSON.pretty_generate hsh end

def main(args)
	input_filename = (args.length > 0) ? args[0] : 'example.sm'
	output_filename = input_filename.sub '.sm', '.json'
	content = IO.read input_filename
	lines = content.lines

	num_jobs = content.match(/^jobs[^\d]+(\d+)/).captures.first.to_i
	num_res = content.match(/[^n]renewable[^\d]+(\d+)/).captures.first.to_i

	successors, jobs, durations = job_arrays 3, num_jobs
	demands = Array.new(num_jobs) { Array.new num_res }

	precedence_offset = 2 + (ix_line_with_prefix lines, 'PRECEDENCE RELATIONS:')
	requirements_durations_offset = 3 + (ix_line_with_prefix lines, 'REQUESTS/DURATIONS:')
	(0..num_jobs-1).each { |i|
		parts = lines[precedence_offset+i].split
		jobs[i] = parts.first.to_i
		successors[i] = ints(parts.drop(3))

		parts = lines[requirements_durations_offset+i].split
		durations[i] = parts[2].to_i
		(0..num_res-1).each { |r|
			demands[i][r] = parts[3+r].to_i
		}
	}

	resource_capacities_offset = 2 + (ix_line_with_prefix lines, 'RESOURCEAVAILABILITIES:')
	capacities = ints lines[resource_capacities_offset].split

	project_hash = {jobs: jobs, durations: durations, succs: successors, demands: demands, capacities: capacities}

	IO.write output_filename, (pretty_json project_hash)
end

main(ARGV)