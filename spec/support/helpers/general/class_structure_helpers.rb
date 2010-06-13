module GeneralHelpers
  
  class InheritFrom < Struct.new( :ancestor_class )
    
    def description
      "inherit from the class #{ self.ancestor_class }"
    end
    
    def matches?( klass )
      @klass = klass
      klass.ancestors.include?( self.ancestor_class )
    end
    
    def failure_message
      "#{ @klass } should inherit from #{ self.ancestor_class }, but doesn't."
    end
    
  end
  
  
  class IncludeModule < Struct.new( :module )
    
    def description
      "include module #{ self.module }"
    end
    
    def matches?( klass )
      @klass = klass
      @klass.included_modules.include?( self.module )
    end
    
    def failure_message
      "#{ @klass } should include module #{ self.module }, but doesn't."
    end
    
  end
  
  
  class HaveMethod < Struct.new( :method_name )
    
    def description
      "have method #{ self.method_name }"
    end
    
    def matches?( klass )
      @klass = klass
      klass.instance_methods.include?( self.method_name )
    end
    
    def failure_message
      "#{ @klass } should have method #{ self.method_name }, but doesn't."
    end
    
    def negative_failure_message
      "#{ @klass } should not have method #{ self.method_name }, but does."
    end
    
  end
  
  
  class HavePublicMethod < Struct.new( :method_name )
    
    def description
      "have public method #{ self.method_name }"
    end
    
    def matches?( klass )
      @klass = klass
      @klass.public_instance_methods.include?( self.method_name )
    end
    
    def failure_message
      "#{ @klass } should have public method #{ self.method_name }, but doesn't."
    end
    
    def negative_failure_message
      "#{ @klass } should not have public method #{ self.method_name }, but does."
    end
    
  end
  
  
  
  def inherit_from( ancestor_class )
    InheritFrom.new( ancestor_class )
  end
  
  def include_module( _module )
    IncludeModule.new( _module )
  end
  
  def have_method( method_name )
    HaveMethod.new( method_name )
  end
  
  def have_public_method( method_name )
    HavePublicMethod.new( method_name )
  end
  
end
