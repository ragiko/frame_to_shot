require 'pp'

shots = []
File.open("./all.shot").each_line do |l|
    a = l.split(" ")
    shots << {
        video: a[0], 
        id: a[1].to_i,
        ss: a[2].to_f, 
        es: a[3].to_f, 
    }
end

res = []
File.open("./reslut.csv").each_line do |l|
    a = l.split(",")
    a = [a[0], a[1].to_f, a[2].to_f, a[3].delete("\n").to_f]
    res << a
end

shot = shots[0]
s = res.select do |x|
    (shot[:ss] <= x[1] and x[1] <= shot[:es]) or (shot[:ss] <= x[2] and x[2] <= shot[:es])
end

# 1. 多数決
# 2. 同じもの回数の場合重みで決定
parson_cnt = Hash.new(0)
s.map {|x| parson_cnt[x[0]] += 1}
max_val = parson_cnt.max{ |x, y| x[1] <=> y[1] }[1]
max_parsons = parson_cnt.select { |k, v| v == max_val }.keys
x = s.select {|x| max_parsons.include?(x[0])}

x = x.sort {|a, b|
     -1 * (a[3] <=> b[3])
}[0][0]

