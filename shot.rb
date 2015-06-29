module Shot
    # all.shotのデータの取り込み
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

    # 田村先生からの結果を取り込み
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
        # 選択するものが存在しない場合
        if candidate_list.size == 0
            return nil
        end

        # フォーマットを変換
        # 当面動かすため
        list = []
        candidate_list.each do |item|
            list <<  [
                item[:parson],
                item[:ss],
                item[:es],
                item[:weight],
            ]
        end

        ### 1. 人物の登場回数による多数決 ###

        # 人物の登場回数をhashを用いて取得
        # ex) parson_cnt = {"ukai" => 2, "taguchi" => 2, "nakajima" => 1}
        parson_cnt = Hash.new(0)
        list.map {|x| parson_cnt[x[0]] += 1}

        # 最大の出現回数を取得
        # ex) max_val = 2
        max_val = parson_cnt.max{ |x, y| x[1] <=> y[1] }[1]

        # 出現頻度が最大の人物の名前の配列 
        # ex) max_parsons = ["ukai", "taguchi"]
        max_parsons = parson_cnt.select { |k, v| v == max_val }.keys
        
        # 候補から最大人物の名前が一致するフレームを取得
        list = list.select {|x| max_parsons.include?(x[0])}

        ### 2. 同じもの回数の場合重みで決定 ###

        # 人物に対してフレームをグループ化
        # ex) group_mean_weight = {"ukai" => [{frame1のhash}, {frame2のhash}, ...]}
        group_mean_weight = Hash.new() { |h,k| h[k] = [] }
        list.each do |x| 
            group_mean_weight[x[0]] << x[3]
        end 

        # グループ化したフレームの平均重みを算出
        # ex) group_mean_weight = {"ukai" => 1.5, "taguchi" => 2.0}
        group_mean_weight.each do |k, v|
            group_mean_weight[k] = v.inject(0.0) {|sum, n| sum + n } / v.size
        end

        # ソートして平均重みが最大のものを取得
        # ex) x = ["taguchi", 2.0]
        x = group_mean_weight.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }[0]
        return x
    end
end
