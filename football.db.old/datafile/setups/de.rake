################################
# football clubs n leagues

task :de => :importbuiltin do
  SportDb.read_setup( 'setups/all',  DE_INCLUDE_PATH )
end

task :de_2014_15 => :importbuiltin do
  SportDb.read_setup( 'setups/2014-15',  DE_INCLUDE_PATH )
end




task :de_recalc => :de do
  [['de.2012/13'],
   ['de.2013/14', 'de.2.2013/14'],
   ['de.2014/15', 'de.2.2014/15']].each do |event_key|
     recalc_standings( event_key, out_root: DE_INCLUDE_PATH )
  end
end

task :de_2014_15_recalc => :de_2014_15 do
  recalc_standings( ['de.2014/15', 'de.2.2014/15'], out_root: DE_INCLUDE_PATH )
end


task :test_de_recalc => :env  do

  recalc_standings( ['de.2014/15', 'de.2.2014/15'], out_root: DE_INCLUDE_PATH )

  ## debug verison - write to ./build/de-deutschland 
  ## recalc_standings( ['de.2014/15', 'de.2.2014/15'], out_root: './build/de-deutschland' )
end
