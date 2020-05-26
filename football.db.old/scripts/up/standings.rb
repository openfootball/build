# encoding: utf-8


## todo/fix: move to sportdb/lib/standings !!!!!!!!!!!!!!!
module SportDb
class Standings
   ## rename to setup_teams - why? why not??
  def setup( teams )   ## setup empty lines for all teams
    teams.each do |team|
      ## note: game.team1_name/team2_name is the same as team.name
     @lines[ team.name ] ||= StandingsLine.new( team.name )
    end
  end
end  # class Standings
end  # module SportDb



def recalc_standings( event_key_or_keys, opts={} )

  ### fix/todo:
  ##    for Standings.update
  ##   - allow no past games (include teams!! records nevertheless set to 0/0/0/0 )
  #       do NOT produce empty standings table without teams!!! fix!!!

  if event_key_or_keys.is_a?( Array )
    event_keys = event_key_or_keys
  else  ## assume it's a single key; wrap into array
    event_keys = [event_key_or_keys]
  end

  out_root = opts[:out_root] || './build'

  buf = ''
  ## note: for now assume all events have the same seasons - last event's season will get used
  segment = ''   ## season path segement e.g. 2014-15 etc.

  event_keys.each do |event_key|
    event = SportDb::Model::Event.find_by_key!( event_key )
    segment = event.season.title.tr('/', '-')  ## change 2014/15 to 2014-15

    ### if event has groups - calc group; otherwise calc standings for all games
    groups_count = event.groups.count
    if groups_count > 0
      event.groups.each do |group|
        standings = SportDb::Standings.new
        standings.update( group.games )

        buf << build_standings( standings )
        pp buf
      end
    else
      standings = SportDb::Standings.new
      standings.setup( event.teams )   ## setup empty (standings) lines for all teams
      standings.update( event.games )

      buf << build_standings( standings )
      pp buf
    end
  end


  ## todo/fix:
  ##    add flag matrix or results? to make adding matrices/results tables optional
  buf_results = ""
  event_keys.each do |event_key|
    buf_results << "```\n"
    buf_results << build_results_matrices( event_key )
    buf_results << "```\n"
    buf_results << "\n\n"
  end


  out_path = "#{out_root}/#{segment}/README.md"
  puts "out_path=>>#{out_path}<<, segment=>>#{segment}<<"

  ## make sure parent folders exist
  FileUtils.mkdir_p( File.dirname(out_path) ) unless Dir.exists?( File.dirname( out_path ))

  File.open( out_path, 'w' ) do |out|
    out.puts "\n\n"
    out.puts "### Standings\n"
    out.puts "\n"
    out.puts buf
    out.puts "\n"
    out.puts "\n"
    out.puts "---\n"
    out.puts "Pld = Matches; W = Matches won; D = Matches drawn; L = Matches lost; F = Goals for; A = Goals against; +/- = Goal differencence; Pts = Points\n"
    out.puts "\n"

    out.puts "### Results Tables\n"
    out.puts "\n"
    out.puts buf_results
  end
end



def build_standings( standings )
  buf = ""

  ## todo/fix: move ``` to out build_standings / rename to pretty_print_standings-why? why not??

  buf << "\n"
  buf << "```\n"
  buf << "                                        - Total -                  - Home -          - Away -     \n"
  buf << "                                 Pld   W  D  L   F:A   +/-  Pts   W  D  L   F:A     W  D  L   F:A\n"

  standings.to_a.each do |l|
    buf << '%2d. '  % l.rank
    buf << '%-28s  ' % l.team_name
    buf << '%2d  '     % l.played

    buf << '%2d ' % l.won
    buf << '%2d ' % l.drawn
    buf << '%2d ' % l.lost

    buf << '%3d:%-3d ' % [l.goals_for,l.goals_against]

    goals_diff = l.goals_for-l.goals_against
    if goals_diff > 0
      buf << '%3s  '  %  "+#{goals_diff}"
    elsif goals_diff < 0
      buf << '%3s  '  %  "#{goals_diff}"
    else ## assume 0
      buf << '     '
    end

    buf << '%3d  '       % l.pts


    buf << '%2d '      % l.home_won
    buf << '%2d '      % l.home_drawn
    buf << '%2d '      % l.home_lost
    buf << '%3d:%-3d  ' % [l.home_goals_for,l.home_goals_against]

    buf << '%2d '       % l.away_won
    buf << '%2d '       % l.away_drawn
    buf << '%2d '       % l.away_lost
    buf << '%3d:%-3d' % [l.away_goals_for,l.away_goals_against]

    buf << "\n"
  end

  buf << "```\n"
  buf << "\n"
  ### buf << "(Source: `#{File.basename(in_path_csv)}`)\n"
  buf << "\n"
end
