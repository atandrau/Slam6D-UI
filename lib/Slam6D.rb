class Slam6D < Struct.new(:options)  
  def runShow
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
      run("show -f riegl_txt ../dat/ui")
    end
  end
  
  def runIcp
    path = AppConfig["settings"]["slam6dPath"]
    `rm -fdr #{path}dat/ui`
    `mkdir #{path}dat/ui`
    
    icp = Icp.find(options[:icp_id])
    icp.pointclouds.each_with_index do |p, i|
      `cp #{p.complete_path} #{path}dat/ui/scan00#{i}.3d`
      `echo "0 0 0\n-0 0 -0\n" > #{path}dat/ui/scan00#{i}.pose`
    end
    
    output = run("slam6D --anim=1 -r 10 -d 500 -i 1000 ../dat/ui")
    run("show ../dat/ui")
    return output
  end
  
  protected
  
  def run(cmd)
    path = AppConfig["settings"]["slam6dPath"]
    `cd #{path}lib && ../bin/#{cmd}`
  end
end