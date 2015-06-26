require 'pp'
require 'test/unit'
# test/上で続行
require './shot.rb'

class TestSample < Test::Unit::TestCase
  class << self
    # テスト群の実行前に呼ばれる．変な初期化トリックがいらなくなる
    def startup
    end

    # テスト群の実行後に呼ばれる
    def shutdown
    end
  end

  # 毎回テスト実行前に呼ばれる
  def setup
      @shot = {:video=>"FPVDB07010106_VIS_01", :id=>1, :ss=>0.56, :es=>19.92}
  end

  # テストがpassedになっている場合に，テスト実行後に呼ばれる．テスト後の状態確認とかに使える
  def cleanup
  end

  # 毎回テスト実行後に呼ばれる
  def teardown
  end

  ### test select_frame_in_shot!!

  # 誰もいないときは空の配列を返す
  def test_match_zero
    res = Shot::result("./data/zero_match.csv")
    s = Shot::select_frame_in_shot(res, @shot)
    assert_true(s.size == 0)
  end

  def test_match_two
    res = Shot::result("./data/two_match.csv")
    s = Shot::select_frame_in_shot(res, @shot)
    assert_true(s.size == 2)
  end

  # video idも考慮して一致フレームを探す
  def test_not_same_video
    res = Shot::result("./data/not_same_video.csv")
    s = Shot::select_frame_in_shot(res, @shot)
    assert_true(s.size == 0)
  end

  ### test choice_parson_and_weight!!

  # 一致したフレームの中で多数のものを取得
  def test_parson_majority
    res = Shot::result("./data/parson_majority.csv")
    s = Shot::select_frame_in_shot(res, @shot)

    pw = Shot::choice_parson_and_weight(s)
    assert_true(pw[0] == "face2") # is parson
  end

  # 一致したフレーム内で出てきた人が複数いた場合, 平均重みの大きいものを選択
  def test_parson_same_num
    res = Shot::result("./data/parson_same_num.csv")
    s = Shot::select_frame_in_shot(res, @shot)

    pw = Shot::choice_parson_and_weight(s)
    assert_true(pw[0] == "face2") # is parson
    assert_true(pw[1] == 0.22) # is mean weight
  end

  # 誰も出てこなかったときnilを返す
  def test_nobady
    res = Shot::result("./data/not_same_video.csv")
    s = Shot::select_frame_in_shot(res, @shot)
    pw = Shot::choice_parson_and_weight(s)
    assert_true(pw.nil?)
  end
end
