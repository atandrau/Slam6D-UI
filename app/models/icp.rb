class Icp < ActiveRecord::Base
  # has_and_belongs_to_many :pointclouds
  belongs_to :first_scan, :class_name => "Pointcloud"
  belongs_to :second_scan, :class_name => "Pointcloud"
  
  PARAMS = ["-a", "-d", "--epsICP", "-f", "-i", "-r"]
   
  def pointclouds
    pc = []
    pc << self.first_scan if self.first_scan
    pc << self.second_scan if self.second_scan
    pc
  end  
  
  # virtual attributes - parameters
  def get_parameter_value(parameter)
    matcher = self.parameters.match("(^|\\s)#{parameter}[\\s=](.+?)($|\\s)")
    return matcher[2] unless matcher.nil?
    return nil
  end
  
  def set_parameter_value(parameter, value)
    prev_value = get_parameter_value(parameter)
    if prev_value
      self.parameters.gsub!("#{parameter} #{prev_value}", "")
      self.parameters.gsub!("#{parameter}=#{prev_value}", "")
    end
    
    if !value.empty?
      new_parameter = "#{parameter}#{parameter[1] == '-' ? '=' : ' '}#{value}"
      self.parameters += " #{new_parameter}"
      self.parameters.gsub!("  ", " ")
    end
  end
  
  def param_a
    get_parameter_value("-a")
  end
  
  def param_a=(value)
    set_parameter_value("-a", value)
  end
  
  def param_d
    get_parameter_value("-d")
  end
  
  def param_d=(value)
    set_parameter_value("-d", value)
  end
  
  def param_r
    get_parameter_value("-r")
  end
  
  def param_r=(value)
    set_parameter_value("-r", value)
  end
  
  def param_i
    get_parameter_value("-i")
  end
  
  def param_i=(value)
    set_parameter_value("-i", value)
  end
  
  def param_epsICP
    get_parameter_value("--epsICP")
  end
  
  def param_epsICP=(value)
    set_parameter_value("--epsICP", value)
  end
end
