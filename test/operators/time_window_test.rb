require_relative '../helper'

describe ConceptQL::Operators::TimeWindow do
  it "should produce correct results" do
    criteria_ids(
      time_window: [
        { icd9: '412' },
        { start: '-2y', end: '-2y' }
      ]
    ).must_equal("condition_occurrence"=>[1712, 1829, 4359, 5751, 6083, 6902, 7865, 8397, 8618, 9882, 10196, 10443, 10865, 13016, 13741, 15149, 17041, 17772, 17774, 18412, 18555, 19736, 20005, 20037, 21006, 21619, 21627, 22875, 22933, 24437, 24471, 24707, 24721, 24989, 25309, 25417, 25875, 25888, 26766, 27388, 28177, 28188, 30831, 31387, 31542, 31792, 31877, 32104, 32463, 32981])

    criteria_ids(
      time_window: [
        { place_of_service_code: '21' },
        { start: '', end: 'start' }
      ]
    ).must_equal("visit_occurrence"=>[1, 8, 9, 10, 11, 507, 729, 730, 731, 732, 1125, 1155, 1265, 1325, 1389, 1390, 1585, 1586, 1683, 1791, 1879, 1880, 2207, 2208, 2209, 2352, 2353, 2354, 2704, 2705, 2808, 2936, 2937, 3079, 3080, 3081, 3185, 3186, 3187, 3188, 3189, 3359, 3376, 3699, 3700, 3802, 3830, 3846, 3847, 3996, 3997, 3998, 4146, 4245, 4364, 4376, 4377, 4378, 4379, 4380, 4575, 4576, 4795, 4796, 4797, 4857, 4858, 4859, 4860, 4861, 5001, 5002, 5212, 6309, 6310, 6640, 6641, 6642, 6784, 6833, 6834, 6879, 7002, 7003, 7325, 7396, 7464, 7824, 7832, 7952, 8108, 8127, 8349, 8350, 8556, 8557, 8708, 8806, 8851, 8852, 8972, 8973, 8974, 8975, 9242, 9449, 9450, 9901, 9948, 9949, 10046, 10181, 10182, 10303, 10304, 10407, 10474, 10766, 10793, 10794, 10795, 11071, 11139, 11555, 11615, 11781, 11782, 11783, 11784, 12005, 12019, 12020, 12157, 12158, 12198, 12324, 12325, 12326, 12531, 12606, 12663, 12664, 12665, 12666, 12667, 12668, 12669, 12670, 12889, 12890, 13037, 13321, 13322, 13323, 13324, 13325, 13606, 13903, 13972, 13973, 14151, 14152, 14153, 14204, 14344, 14345, 14441, 14442, 14920, 15011])

    criteria_ids(
      time_window: [
        { icd9: '412' },
        { start: '-2m-2d', end: '3d1y' }
      ]
    ).must_equal("condition_occurrence"=>[1712, 1829, 4359, 5751, 6083, 6902, 7865, 8397, 8618, 9882, 10196, 10443, 10865, 13016, 13741, 15149, 17041, 17772, 17774, 18412, 18555, 19736, 20005, 20037, 21006, 21619, 21627, 22875, 22933, 24437, 24471, 24707, 24721, 24989, 25309, 25417, 25875, 25888, 26766, 27388, 28177, 28188, 30831, 31387, 31542, 31792, 31877, 32104, 32463, 32981])

    criteria_ids(
      time_window: [
        { place_of_service_code: '21' },
        { start: 'end', end: 'start' }
      ]
    ).must_equal("visit_occurrence"=>[1, 8, 9, 10, 11, 507, 729, 730, 731, 732, 1125, 1155, 1265, 1325, 1389, 1390, 1585, 1586, 1683, 1791, 1879, 1880, 2207, 2208, 2209, 2352, 2353, 2354, 2704, 2705, 2808, 2936, 2937, 3079, 3080, 3081, 3185, 3186, 3187, 3188, 3189, 3359, 3376, 3699, 3700, 3802, 3830, 3846, 3847, 3996, 3997, 3998, 4146, 4245, 4364, 4376, 4377, 4378, 4379, 4380, 4575, 4576, 4795, 4796, 4797, 4857, 4858, 4859, 4860, 4861, 5001, 5002, 5212, 6309, 6310, 6640, 6641, 6642, 6784, 6833, 6834, 6879, 7002, 7003, 7325, 7396, 7464, 7824, 7832, 7952, 8108, 8127, 8349, 8350, 8556, 8557, 8708, 8806, 8851, 8852, 8972, 8973, 8974, 8975, 9242, 9449, 9450, 9901, 9948, 9949, 10046, 10181, 10182, 10303, 10304, 10407, 10474, 10766, 10793, 10794, 10795, 11071, 11139, 11555, 11615, 11781, 11782, 11783, 11784, 12005, 12019, 12020, 12157, 12158, 12198, 12324, 12325, 12326, 12531, 12606, 12663, 12664, 12665, 12666, 12667, 12668, 12669, 12670, 12889, 12890, 13037, 13321, 13322, 13323, 13324, 13325, 13606, 13903, 13972, 13973, 14151, 14152, 14153, 14204, 14344, 14345, 14441, 14442, 14920, 15011])
  end
end
