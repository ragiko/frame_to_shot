module Shot
    def self.shots(path)
        shots = []
        File.open(path).each_line do |l|
            a = l.split(" ")
            shots << {
                video: a[0], 
                id: a[1].to_i,
                ss: a[2].to_f, 
                es: a[3].to_f, 
            }
        end
        shots
    end

    def self.result(path)
        res = []
        File.open(path).each_line do |l|
            a = l.delete("\n").split(",")
            a = {
                video: a[0],
                parson: a[1],
                ss: a[2].to_f,
                es: a[3].to_f,
                weight: a[4].to_f
            }
            res << a
        end
        res
    end

    # shot内にあるframeを選択
    def self.select_frame_in_shot(res, shot)
        return res.select do |x|
            shot[:video] == x[:video] \
                and \
                ( (shot[:ss] <= x[:ss] and x[:ss] <= shot[:es]) \
                 or (shot[:ss] <= x[:es] and x[:es] <= shot[:es]) )
        end
    end

    # 候補からshot内の人と重みを選ぶ
    def self.choice_parson_and_weight(candidate_list)
        if candidate_list.size == 0
            return nil
        end

        # フォーマットを変換
        list = []
        candidate_list.each do |item|
            list <<  [
                item[:parson],
                item[:ss],
                item[:es],
                item[:weight],
            ]
        end

        # 1. 多数決
        parson_cnt = Hash.new(0)
        list.map {|x| parson_cnt[x[0]] += 1}
        max_val = parson_cnt.max{ |x, y| x[1] <=> y[1] }[1]
        max_parsons = parson_cnt.select { |k, v| v == max_val }.keys
        list = list.select {|x| max_parsons.include?(x[0])}

        # 2. 同じもの回数の場合重みで決定
        # グループ化して平均とって重みの最大のもの
        group_mean_weight = Hash.new() { |h,k| h[k] = [] }
        list.each do |x| 
            group_mean_weight[x[0]] << x[3]
        end 
        group_mean_weight.each do |k, v|
            group_mean_weight[k] = v.inject(0.0) {|sum, n| sum + n } / v.size
        end

        x = group_mean_weight.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }[0]
        return x
    end
end
