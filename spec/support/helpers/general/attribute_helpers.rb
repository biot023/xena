module GeneralHelpers
  
  class HaveA
    
    attr_accessor :attribute_name, :value_expected, :expected_value, :klass_or_obj
    
    def initialize( attribute_name, options={} )
      self.attribute_name = attribute_name
      self.value_expected = options.has_key?( :equalling )
      self.expected_value = options[:equalling]
    end
    
    def description
      if self.value_expected
        "have an attribute named #{ self.attribute_name } equalling #{ self.expected_value.inspect }"
      else
        "have an attribute named #{ self.attribute_name }"
      end
    end
    
    def matches?( klass_or_obj )
      self.klass_or_obj = klass_or_obj
      instance = self.klass_or_obj.is_a?( Class ) ? self.klass_or_obj.send( :new ) : self.klass_or_obj
      value = instance.send( self.attribute_name )
      self.value_expected ? self.expected_value == value : true
    rescue NoMethodError
      false
    end
    
    def failure_message
      if self.value_expected
        "#{ self.klass_or_obj } should have attribute named #{ self.attribute_name.inspect } equalling #{ self.expected_value.inspect }, but hasn't."
      else
        "#{ self.klass_or_obj } should have attribute named #{ self.attribute_name.inspect }, but hasn't."
      end
    end
    
    def negative_failure_message
      if self.value_expected
        "#{ self.klass_or_obj } should not have attribute named #{ self.attribute_name.inspect } equalling #{ self.expected_value.inspect }, but has."
      else
        "#{ self.klass_or_obj } should not have attribute named #{ self.attribute_name.inspect }, but has."
      end
    end
    
  end
  
  
  class HaveACollectionOf
    
    attr_accessor :attribute_name, :value_expected, :expected_value, :klass_or_obj
    
    def initialize( attribute_name, options={} )
      self.attribute_name = attribute_name
      self.value_expected = options.has_key?( :equalling )
      self.expected_value = options[:equalling]
    end
    
    def description
      if self.value_expected
        "have a collection named #{ self.attribute_name } equalling #{ self.expected_value.inspect }"
      else
        "have a collection named #{ self.attribute_name }"
      end
    end
    
    def matches?( klass_or_obj )
      self.klass_or_obj = klass_or_obj
      instance = self.klass_or_obj.is_a?( Class ) ? self.klass_or_obj.send( :new ) : self.klass_or_obj
      collection = instance.send( self.attribute_name )
      response_result = collection.respond_to?( :<< ) && collection.respond_to?( :size )
      value_result = self.value_expected ? collection == self.expected_value : true
      response_result && value_result
    rescue NoMethodError
      false
    end
    
    def failure_message
      if self.value_expected
        "#{ self.klass_or_obj } should have collection named #{ self.attribute_name.inspect } equalling #{ self.expected_value.inspect }, but hasn't."
      else
        "#{ self.klass_or_obj } should have collection named #{ self.attribute_name.inspect }, but hasn't."
      end
    end
    
    def negative_failure_message
      if self.value_expected
        "#{ self.klass_or_obj } should not have collection named #{self. attribute_name.inspect } equalling #{ self.expected_value.inspect }, but has."
      else
        "#{ self.klass_or_obj } should not have collection named #{ self.attribute_name.inspect }, but has."
      end
    end
    
  end
  
  
  def have_a( attribute_name, options={} )
    HaveA.new( attribute_name, options )
  end
  alias_method( :have_an, :have_a )
  
  def have_a_collection_of( attribute_name, options={} )
    HaveACollectionOf.new( attribute_name, options )
  end
  
end
