require 'pp'
require './shot.rb'

# get shot deta
shots = Shot::shots

# get result deta
res = Shot::result("./data/result2.csv")

shots.each do |shot|
    # shotに挟まっているframeを取得
    pp shot
    s = Shot::select_frame_in_shot(res, shot)
    # frame中の人と重みを決定
    pp Shot::choice_parson_and_weight(s)
end

