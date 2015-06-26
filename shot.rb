require 'pp'

def choice_parson_and_weight(candidate_list)
    if candidate_list.size == 0
        return ""
    end

    # 1. 多数決
    parson_cnt = Hash.new(0)
    candidate_list.map {|x| parson_cnt[x[0]] += 1}
    max_val = parson_cnt.max{ |x, y| x[1] <=> y[1] }[1]
    max_parsons = parson_cnt.select { |k, v| v == max_val }.keys
    candidate_list = candidate_list.select {|x| max_parsons.include?(x[0])}
    pp candidate_list

    # 2. 同じもの回数の場合重みで決定
    # グループ化して平均とって重みの最大のもの
    group_mean_weight = Hash.new() { |h,k| h[k] = [] }
    candidate_list.each do |x| 
        group_mean_weight[x[0]] << x[3]
    end 
    group_mean_weight.each do |k, v|
        group_mean_weight[k] = v.inject(0.0) {|sum, n| sum + n } / v.size
    end
    pp group_mean_weight

    x = group_mean_weight.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }[0]
    return x
end

# get shot deta
shots = []
File.open("./all.shot").each_line do |l|
    a = l.split(" ")
    shots << {
        video: a[0], 
        id: a[1].to_i,
        ss: a[2].to_f, 
    }
end

# get result deta
res = []
File.open("./result2.csv").each_line do |l|
    a = l.split(",")
    a = [a[0], a[1].to_f, a[2].to_f, a[3].delete("\n").to_f]
    res << a
end

shots.each do |shot|
    # shotに挟まっているframeを取得
    s = res.select do |x|
        (shot[:ss] <= x[1] and x[1] <= shot[:es]) or (shot[:ss] <= x[2] and x[2] <= shot[:es])
    end
    pp shot
    choice_parson_and_weight(s)
end


S_01FPVDB07010204_VIS_01FPVDB07010204_VIS_01
