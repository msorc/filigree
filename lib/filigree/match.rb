# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Filigree
# Date:		2013/05/04
# Description:	Pattern matching for Ruby.

############
# Requires #
############

# Standard Library
require 'ostruct'
require 'singleton'

# Filigree

##########
# Errors #
##########

class MatchError < RuntimeError; end

###########
# Methods #
###########

def match(*objects, &block)
	me = MatchEnvironment.new
	
	me.instance_exec &block
	
	me.find_match objects
end

#######################
# Classes and Modules #
#######################

module Deconstructable
	def call(*pattern)
		DeconstructionPattern.new(self, pattern)
	end
end

class MatchEnvironment
	def initialize
		@patterns = Array.new
		@deferred = Array.new
	end
	
	def find_match(objects)
		@patterns.each do |pattern|
			
			env = OpenStruct.new 
			
			return pattern.(env, objects) if pattern.match?(objects, env)
		end
		
		# If we didn't find anything we raise a MatchError.
		raise MatchError
	end
	
	def with(*pattern, &block)
		guard = if pattern.last.is_a?(Proc) then pattern.pop end 
		
		@patterns << (mp = MatchPattern.new(pattern, guard, block))
		
		if block
			@deferred.each { |p| p.block = block }
			@deferred.clear
			
		else
			@deferred << mp
		end
	end
	alias :w :with
	
	#############
	# Callbacks #
	#############
	
	def method_missing(name, *args)
		if args.empty?
			if name == :_ then Wildcard.instance else MatchBinding.new(name) end
		else
			super(name, *args)
		end
	end
end

class BasicPattern
	def as(binding)
		binding.tap { binding.pattern = self }
	end
	
	def initialize(pattern)
		@pattern = pattern
	end
	
	def match?(objects, env)
		if objects.length == @pattern.length
			@pattern.zip(objects).each do |pattern, object|
				return false unless match_prime(pattern, object, env)
			end
			
			true
			
		else
			(@pattern.length == 1 and @pattern.first == Wildcard.instance)
		end
	end
	
	def match_prime(pattern, object, env)
		case pattern
		when Wildcard
			true
			
		when Regexp
			object.is_a?(String) and pattern.match(object)
			
		when DeconstructionPattern, MatchBinding
			pattern.match?(object, env)
			 
		else
			object == pattern
		end
	end
end

class DeconstructionPattern < BasicPattern
	attr_reader :klass
	
	def initialize(klass, pattern)
		super(pattern)
		
		@klass = klass
	end
	
	def match?(object, env)
		object.is_a?(@klass) and object.respond_to?(:deconstruct) and super(object.deconstruct(@pattern.length), env)
	end
end

class MatchPattern < BasicPattern
	attr_writer :block
	
	def initialize(pattern, guard, block)
		super(pattern)
		
		@guard = guard
		@block = block
	end
	
	def call(env, objects)
		if @block then env.instance_exec(&@block) else nil end
	end
	
	def match?(objects, env)
		super(objects, env) and (@guard.nil? or env.instance_exec(&@guard))
	end
end

class Wildcard
	include Singleton
end

class MatchBinding
	attr_accessor :name
	attr_accessor :pattern
	
	def initialize(name, pattern = nil)
		@name	= name
		@pattern	= pattern
	end
	
	def match?(object, env)
		(@pattern.nil? or @pattern.match?(object, env)).tap do |match|
			env.send("#{@name}=", object) if match
		end
	end
end

###################################
# Standard Library Deconstructors #
###################################

class Array
	extend Deconstructable
	
	def deconstruct(num_names)
		[*self.first(num_names - 1), self[(num_names - 1)..-1]]
	end
end
