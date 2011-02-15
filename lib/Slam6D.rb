class Slam6D < Struct.new(:options)  
  def runShow(reflectance = false)
    path = AppConfig["settings"]["slam6dPath"]

    `rm -fdr #{path}dat/ui`
    `mkdir #{path}dat/ui`
    
    pointcloud = Pointcloud.find(options[:pointcloud_id])
    if pointcloud.format == "uos"
      `cp #{pointcloud.complete_path} #{path}dat/ui/scan000.3d`
      `echo "0 0 0\n-0 0 -0\n" > #{path}dat/ui/scan000.pose`
      `echo "1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 2\n" > #{path}dat/ui/scan000.frames`
      run("show ../dat/ui")
    elsif pointcloud.format == "xyzr"
      `cp #{pointcloud.complete_path} #{path}dat/ui/scan000.3d`
      `echo "0 0 0\n-0 0 -0\n" > #{path}dat/ui/scan000.pose`
      `echo "1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 2\n" > #{path}dat/ui/scan000.frames`
      run("show -f xyzr ../dat/ui")
    elsif pointcloud.format == "riegl_txt"
      `cp #{pointcloud.complete_path} #{path}dat/ui/scan000.txt`
      `echo "1 -0 0 0\n-0 1 -0 -0\n0 -0 1 0\n0 -0 0 1" > #{path}dat/ui/scan000.dat`
      `echo "1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 2\n" > #{path}dat/ui/scan000.frames`
      run("show -s 0 -e 0 -f riegl_txt #{reflectance ? "-R" : ""} ../dat/ui")
    end
  end
  
  def runIcp
    path = AppConfig["settings"]["slam6dPath"]
    `rm -fdr #{path}dat/ui`
    `mkdir #{path}dat/ui`
    
    icp = Icp.find(options[:icp_id])
    
    first_scan = icp.first_scan
    second_scan = icp.second_scan
    
    `cp #{first_scan.complete_path} #{path}dat/ui/scan000.3d`
    `cp #{second_scan.complete_path} #{path}dat/ui/scan001.3d`
    
    `echo "#{icp.first_scan_position}\n#{icp.first_scan_rotation}\n" > #{path}dat/ui/scan000.pose`
    `echo "#{icp.second_scan_position}\n#{icp.second_scan_rotation}\n" > #{path}dat/ui/scan001.pose`
    
    output = run("slam6D #{icp.parameters} --anim=1 ../dat/ui")
    run("show ../dat/ui")
    return output
  end
  
  protected
  
  def run(cmd, fake = false)
    path = AppConfig["settings"]["slam6dPath"]
    command = "cd #{path}lib && ../bin/#{cmd}"
    puts "command = #{command}"
    if fake
      return command
    else
      return `#{command}`
    end
  end
end