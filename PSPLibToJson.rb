#!/usr/bin/env ruby
# Convert single mode PSPLib project to json representation
# Usage example: ./PSPLibToJson.rb j3047_9.sm

require 'json'

def jobDatas(n, nj); Array.new(n) { Array.new nj } end
def indexWithStart(lines, start); lines.index { |line| line.start_with? start } end
def ints(strs); strs.map { |s| s.to_i } end
def jsonify(hsh); JSON.pretty_generate hsh end 

def main(args)
	inputFilename = if args.length > 0 then args[0] else "example.sm" end
	outputFilename = inputFilename.sub '.sm', '.json'
	content = IO.read inputFilename
	lines = content.lines

	numJobs = content.match(/^jobs[^\d]+(\d+)/).captures.first.to_i
	numRes = content.match(/[^n]renewable[^\d]+(\d+)/).captures.first.to_i

	succs, jobs, durations = jobDatas 3, numJobs
	demands = Array.new(numJobs) { Array.new numRes }
	capacities = Array.new(numRes)

	precedenceOffset = 2 + (indexWithStart lines, "PRECEDENCE RELATIONS:")
	reqDurOffset = 3 + (indexWithStart lines, "REQUESTS/DURATIONS:")		
	(0..numJobs-1).each { |i|
		parts = lines[precedenceOffset+i].split
		jobs[i] = parts.first.to_i
		succs[i] = ints(parts.drop(3))

		parts = lines[reqDurOffset+i].split
		durations[i] = parts[2].to_i
		(0..numRes-1).each { |r|
			demands[i][r] = parts[3+r].to_i
		}
	}

	resCapOffset = 2 + (indexWithStart lines, "RESOURCEAVAILABILITIES:")
	capacities = ints lines[resCapOffset].split

	projHash = {jobs: jobs, durations: durations, succs: succs, demands: demands, capacities: capacities}

	IO.write outputFilename, (jsonify projHash)
end

main(ARGV)