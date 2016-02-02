require_relative '../helper'

describe ConceptQL::Operators::Intersect do
  it "should produce correct results" do
    criteria_ids(
      [:intersect, [:icd9, "412"], [:condition_type, :inpatient_header]]
    ).must_equal("condition_occurrence"=>[6083, 8618, 9882, 15149, 18412, 20005, 26766, 31877])

    criteria_ids(
      [:intersect, [:icd9, "412"], [:gender, "Male"]]
    ).must_equal("person"=>[1, 2, 4, 5, 6, 7, 8, 12, 14, 20, 21, 23, 25, 27, 28, 38, 40, 45, 51, 53, 55, 59, 60, 63, 65, 66, 68, 69, 70, 73, 78, 80, 82, 85, 90, 91, 92, 94, 95, 96, 99, 101, 106, 107, 108, 109, 110, 112, 113, 115, 117, 119, 120, 125, 127, 128, 129, 130, 131, 132, 138, 142, 143, 145, 146, 148, 149, 150, 152, 153, 154, 158, 161, 163, 164, 172, 174, 175, 177, 178, 181, 182, 183, 187, 189, 191, 192, 195, 198, 203, 205, 206, 207, 212, 215, 218, 222, 227, 229, 230, 231, 233, 238, 239, 244, 245, 246, 249, 251, 260, 262, 265, 266, 268, 270, 271, 273, 274, 275, 276, 279, 280, 285, 287, 288, 289], "condition_occurrence"=>[1712, 1829, 4359, 5751, 6083, 6902, 7865, 8397, 8618, 9882, 10196, 10443, 10865, 13016, 13741, 15149, 17041, 17772, 17774, 18412, 18555, 19736, 20005, 20037, 21006, 21619, 21627, 22875, 22933, 24437, 24471, 24707, 24721, 24989, 25309, 25417, 25875, 25888, 26766, 27388, 28177, 28188, 30831, 31387, 31542, 31792, 31877, 32104, 32463, 32981])

    criteria_ids(
      [:intersect,
       [:icd9, "412"],
       [:condition_type, :inpatient_header],
       [:gender, "Male"],
       [:race, "White"]]
    ).must_equal("person"=>[1, 2, 5, 7, 8, 12, 14, 20, 23, 25, 27, 28, 38, 40, 45, 51, 53, 55, 59, 60, 63, 65, 68, 78, 80, 82, 85, 90, 91, 92, 95, 96, 99, 101, 107, 108, 110, 112, 119, 120, 125, 127, 128, 130, 131, 132, 138, 142, 143, 145, 146, 149, 150, 152, 153, 154, 158, 161, 164, 172, 174, 175, 178, 181, 183, 187, 189, 191, 192, 195, 203, 205, 206, 207, 212, 215, 218, 222, 227, 229, 231, 233, 238, 239, 244, 245, 246, 249, 251, 262, 266, 268, 270, 271, 273, 274, 275, 276, 279, 280, 285, 287, 288, 289], "condition_occurrence"=>[6083, 8618, 9882, 15149, 18412, 20005, 26766, 31877])
  end
end