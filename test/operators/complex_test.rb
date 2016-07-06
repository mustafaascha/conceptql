require_relative '../helper'

describe "complex combinations of operators" do
  it "should not fail due to out of order CTEs" do
    criteria_ids("complex/crit_out_of_order_ctes",
      ["during",
          {"left"=>["one_in_two_out",
                    ["icd9",
                     "428.0",
                     "428.9",
                     {"label"=>"Unspecific HF Dx"}]],
          "right"=>["time_window",
                    ["one_in_two_out",
                     ["icd9",
                      "428.1",
                      "428.20",
                      "428.21",
                      "428.22",
                      "428.23",
                      "428.40",
                      "428.41",
                      "428.42",
                      "428.43"]],
                      {"start"=>"-365d",
                       "end"=>"-1d",
                       "label"=>"Year look back period"}]}]
                )
  end

  it "should produce correct results" do
    criteria_ids("complex/crit_1",
      [:except, {:left=>[:during, {:left=>[:intersect, [:during, {:left=>[:visit_occurrence, [:cpt, "99201", "99202", "99203", "99204", "99205", "99212", "99213", "99214", "99215", "99218", "99219", "99220", "99281", "99282", "99283", "99284", "99285", "99381", "99382", "99383", "99384", "99385", "99386", "99387", "99391", "99392", "99393", "99394", "99395", "99396", "99397"]], :right=>[:during, {:left=>[:time_window, [:person, true], {:start=>"+2y", :end=>"+17y"}], :right=>[:date_range, {:start=>"2000-01-01", :end=>"2099-12-31"}]}]}], [:visit_occurrence, [:union, [:icd9, "034.0", "462"], [:icd10, "J02.0", "J02.9"]]]], :right=>[:time_window, [:intersect, [:rxnorm, "1013662", "1013665", "1043022", "1043027", "1043030", "105152", "105170", "105171", "108449", "1113012", "1148107", "1244762", "1249602", "1302650", "1302659", "1302664", "1302669", "1302674", "1373014", "141962", "141963", "142118", "1423080", "1483787", "197449", "197450", "197451", "197452", "197453", "197454", "197511", "197512", "197516", "197517", "197518", "197595", "197596"], [:drug_type_concept, 38000175, 38000176, 38000177, 38000179]], {:start=>"-3d", :end=>"start"}]}], :right=>[:during, {:left=>[:during, {:left=>[:visit_occurrence, [:cpt, "99201", "99202", "99203", "99204", "99205", "99212", "99213", "99214", "99215", "99218", "99219", "99220", "99281", "99282", "99283", "99284", "99285", "99381", "99382", "99383", "99384", "99385", "99386", "99387", "99391", "99392", "99393", "99394", "99395", "99396", "99397"]], :right=>[:during, {:left=>[:time_window, [:person, true], {:start=>"+2y", :end=>"+17y"}], :right=>[:date_range, {:start=>"2000-01-01", :end=>"2099-12-31"}]}]}], :right=>[:time_window, [:intersect, [:rxnorm, "1013662", "1013665", "1043022", "1043027", "1043030", "105152", "105170", "105171", "108449", "1113012", "1148107", "1244762", "1249602", "1302650", "1302659", "1302664", "1302669", "1302674", "1373014", "141962", "141963", "142118", "1423080", "1483787", "197449", "197450", "197451", "197452", "197453", "197454", "197511", "197512", "197516", "197517", "197518", "197595", "197596"], [:drug_type_concept, 38000175, 38000176, 38000177, 38000179]], {:start=>"0", :end=>"30d"}]}]}]
    )

    criteria_ids("complex/crit_2",
      [:during,
       {:left=>
         [:except,
          {:left=>[:icd9, "584"],
           :right=>
            [:after,
             {:left=>[:icd9, "584"],
              :right=>[:icd9, "V45.1", "V56.0", "V56.31", "V56.32", "V56.8"]}]}],
        :right=>
         [:time_window,
          [:icd9_procedure, "39.95", "54.98"],
          {:start=>"0", :end=>"60d"}]}]
    )

    criteria_ids("complex/crit_3",
      [:intersect,
       [:place_of_service_code, "21"],
       [:visit_occurrence, [:icd9, "410.00", "410.01"]],
       [:visit_occurrence,
        [:union,
         [:cpt, "0008T", "3142F", "43205", "43236", "76975", "91110", "91111"],
         [:hcpcs, "B4081", "B4082"],
         [:icd9_procedure, "42.22", "42.23", "44.13", "45.13", "52.21", "97.01"],
         [:loinc, "16125-7", "17780-8", "40820-3", "50320-1", "5177-1", "7901-2"]]]]
    )

    criteria_ids("complex/crit_4",
      [:intersect,
       [:visit_occurrence, [:icd9, "412"]],
       [:visit_occurrence, [:cpt, "99251"]]]
    )

    criteria_ids("complex/crit_5",
      [:intersect,
       [:visit_occurrence, [:icd9, "412"]],
       [:visit_occurrence, [:cpt, "99214"]]]
    )

    criteria_ids("complex/crit_6",
      [:during,
       {:left=>[:cpt, "99214"],
        :right=>[:time_window, [:icd9, "412"], {:start=>"-30d", :end=>"30d"}]}]
    )

    criteria_ids("complex/crit_7",
      [:intersect,
       [:icd9, "412"],
       [:complement, [:condition_type, :inpatient_header]]]
    )
  end
end

