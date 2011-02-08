class Slam6D < Struct.new(:options)
  
  def run(cmd)
    path = AppConfig["settings"]["slam6dPath"]
    `cd #{path}lib && ../bin/#{cmd}`
  end
  
  def testOpen
    run("show ../dat/icp2")
  end
  
  def runShow
    scanDbPath = AppConfig["settings"]["scanDB"]
    path = AppConfig["settings"]["slam6dPath"]

    `rm -fdr #{path}dat/ui`
    `mkdir #{path}dat/ui`
    
    pointcloud = Pointcloud.find(options[:pointcloud_id])
    `cp #{pointcloud.path} #{path}dat/ui/scan000.3d`
    `echo "0 0 0\n-0 0 -0\n" > #{path}dat/ui/scan000.pose`
    `echo "1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 2\n" > #{path}dat/ui/scan000.frames`
    run("show ../dat/ui")
  end
  
end