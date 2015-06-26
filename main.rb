require 'pp'
require './shot.rb'

# get shot deta
shots = Shot::shots("./data/all.shot")

# get result deta
res = Shot::result("./data/result2.csv")

shots.each do |shot|
    # shotに挟まっているframeを取得
    s = Shot::select_frame_in_shot(res, shot)
    # frame中の人と重みを決定
    pw = Shot::choice_parson_and_weight(s)
    # TODO: 誰も見つからなかったとき
    if pw.nil?
        next
    end
    puts "#{shot[:video]} #{shot[:id]} #{pw[0]} #{pw[1]}"
end

