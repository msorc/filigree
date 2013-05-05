# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Filigree
# Date:		2013/4/19
# Description:	An implementation of an AbstractClass module.

############
# Requires #
############

# Standard Library

# Filigree

##########
# Errors #
##########

# An error representing an erroneous instantiation of an abstract class.
class AbstractClassError  < RuntimeError
	def initialize(class_name)
		super "Instantiating abstract class #{class_name} is not allowed."
	end
end

# An error representing a call to an unimplemented abstract method.
class AbstractMethodError < RuntimeError
	def initialize(method_name, abstract_class_name)
		super "Abstract method #{method_name}, defined in #{abstract_class_name}, must be overridden by a subclass."
	end
end

#######################
# Classes and Modules #
#######################

# A module the implements the abstract class and abstract method patterns.
module AbstractClass
	
	##################
	# Module Methods #
	##################
	
	def self.extended(klass)
		klass.install_icvars
	end
	
	####################
	# Instance Methods #
	####################
	
	def abstract_class
		@abstract_class
	end
	
	def abstract_method(name)
		abstract_class_name = @abstract_class
		
		define_method name do
			raise AbstractMethodError.new name, abstract_class_name
		end
	end
	
	def install_icvars
		@abstract_class = self
	end
	
	def new(*args)
		if @abstract_class == self
			raise AbstractClassError, self.name
		else
			super
		end
	end
end