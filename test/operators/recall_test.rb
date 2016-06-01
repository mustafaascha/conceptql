require_relative '../helper'

describe ConceptQL::Operators::Recall do
  it "should raise error if attmping executing invalid recall" do
    proc do
      criteria_ids(
      ["after",
        {:left=>["during",
                 {:left=>["occurrence", 4, ["icd9", "203.0x", {"label"=>"Meyloma Dx"}]],
                  :right=>["time_window", ["first", ["recall", "Meyloma Dx"]], {"start"=>"0", "end"=>"90d"}]}],
         :right=>["union",
                  ["during",
                   {:left=>["time_window", ["recall", "Qualifying Meyloma Dx"], {"start"=>"-90d", "end"=>"0", "label"=>"Meyloma 90-day Lookback"}],
                    :right=>["cpt", "38220", "38221", "85102", "85095", "3155F", "85097", "88237", "88271", "88275", "88291", "88305", {"label"=>"Bone Marrow"}]}],
                  ["occurrence", 2, ["during",
                                     {:left=>["cpt", "84156", "84166", "86335", "84155", "84165", "86334", "83883", "81264", "82784", "82785", "82787", "82040", "82232", "77074", "77075", "83615", {"label"=>"Other Tests"}],
                                      :right=>["recall", "Meyloma 90-day Lookback"]}]]]}]
      )
    end.must_raise
  end

  it "should produce correct results" do
    criteria_ids(
      [:union,
       ["icd9", "412", {"label": "Heart Attack"}],
       ["recall", "Heart Attack"]]
    ).must_equal("condition_occurrence"=>[2151, 2428, 3995, 4545, 4710, 5069, 5263, 5582, 8725, 10403, 10590, 11135, 11228, 11589, 11800, 13234, 13893, 14604, 14702, 14854, 14859, 17103, 17593, 23234, 23411, 24627, 25492, 26245, 27343, 37521, 38787, 50019, 50933, 52644, 52675, 53214, 53216, 53251, 53630, 53733, 53801, 55383, 56352, 56634, 56970, 57089, 57705, 58271, 58448, 58596, 58610, 58623, 59732, 59760, 59785])

    criteria_ids(
      [:except,
       {left: ["icd9", "412", {"label": "Heart Attack"}],
        right: [ "recall", "Heart Attack"]}]
    ).must_equal({})

    criteria_ids(
      [:first,
        [
          :union,
          [:icd9, "412", label: "Codes"],
          [:recall, "Codes"]
        ]
      ]
    ).must_equal({"condition_occurrence"=>[2151, 2428, 3995, 4545, 5069, 5263, 5582, 8725, 11135, 11589, 11800, 13234, 14702, 14854, 14859, 17103, 23234, 23411, 24627, 25492, 26245, 37521, 38787, 50019, 52644, 52675, 53214, 53216, 53251, 53801, 55383, 56352, 56634, 57089, 57705, 58271, 58448, 58596, 58623, 59732, 59760, 59785]})
  end

  it "should handle nested recall operators" do
    ops = [
      ["recall", "HA"],
      [:union,
       ["icd9", "412"],
       ["recall", "Heart Attack"],
       {"label": "HA"}],
      ["icd9",
       "412",
       {"label": "Heart Attack"}]]
    ops.permutation do |op|
      criteria_ids(
        [:union, *op]
      ).must_equal("condition_occurrence"=>[2151, 2428, 3995, 4545, 4710, 5069, 5263, 5582, 8725, 10403, 10590, 11135, 11228, 11589, 11800, 13234, 13893, 14604, 14702, 14854, 14859, 17103, 17593, 23234, 23411, 24627, 25492, 26245, 27343, 37521, 38787, 50019, 50933, 52644, 52675, 53214, 53216, 53251, 53630, 53733, 53801, 55383, 56352, 56634, 56970, 57089, 57705, 58271, 58448, 58596, 58610, 58623, 59732, 59760, 59785])
    end
  end

  it "should handle errors when annotating" do
    query(
      [:except,
       {left: ["icd9", "412", {"label": 1}],
        right:[ "recall", "Heart Attack"]}]
    ).annotate.must_equal(
      ["except",
       {:left=>["icd9", "412", {label: 1,
        :annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}, :errors=>[["invalid label"]]}, :name=>"ICD-9 CM"}],
        :right=>["recall", "Heart Attack", {:annotation=>{:counts=>{:invalid=>{:rows=>0, :n=>0}},:errors=>[["no matching label", "Heart Attack"]]}}],
        :annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}}}]
    )

    query(
      [:union,
       ["icd9", "412", {"label": "Heart Attack"}],
       ["recall",
        "Heart Attack",
        ["icd9", "412"]]]
    ).annotate.must_equal(
      ["union",
       ["icd9", "412", {:annotation=>{:counts=>{:condition_occurrence=>{:rows=>55, :n=>42}}}, :label=>"Heart Attack", :name=>"ICD-9 CM"}],
       ["recall",
        ["icd9", "412", {:annotation=>{:counts=>{:condition_occurrence=>{:rows=>55, :n=>42}}}, :name=>"ICD-9 CM"}],
        "Heart Attack",
        {:annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}, :errors=>[["has upstreams"]]}}],
      {:annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}}}]
    )

    query(
      ["recall", "HA1"]
    ).annotate.must_equal(
      ["recall", "HA1", {:annotation=>{:counts=>{:invalid=>{:rows=>0, :n=>0}}, :errors=>[["no matching label", "HA1"]]}}]
    )

    query(
      [:recall]
    ).annotate.must_equal(
      ["recall", {:annotation=>{:counts=>{:invalid=>{:rows=>0, :n=>0}}, :errors=>[["has no arguments"]]}}]
    )

    query(
      [:recall, "foo", "bar"]
    ).annotate.must_equal(
      ["recall", "foo", "bar", {:annotation=>{:counts=>{:invalid=>{:rows=>0, :n=>0}}, :errors=>[["has multiple arguments"]]}}]
    )

    query(
      ["after",
        {:left=>["during",
                 {:left=>["occurrence", 4, ["icd9", "203.0x", {"label"=>"Meyloma Dx"}]],
                  :right=>["time_window", ["first", ["recall", "Meyloma Dx"]], {"start"=>"0", "end"=>"90d"}]}],
         :right=>["union",
                  ["during",
                   {:left=>["time_window", ["recall", "Qualifying Meyloma Dx"], {"start"=>"-90d", "end"=>"0", "label"=>"Meyloma 90-day Lookback"}],
                    :right=>["cpt", "38220", "38221", "85102", "85095", "3155F", "85097", "88237", "88271", "88275", "88291", "88305", {"label"=>"Bone Marrow"}]}],
                  ["occurrence", 2, ["during",
                                     {:left=>["cpt", "84156", "84166", "86335", "84155", "84165", "86334", "83883", "81264", "82784", "82785", "82787", "82040", "82232", "77074", "77075", "83615", {"label"=>"Other Tests"}],
                                      :right=>["recall", "Meyloma 90-day Lookback"]}]]]}]
    ).annotate.must_equal(
      ["after",
       {:left=>["during",
                {:left=>["occurrence", ["icd9", "203.0x", {:label=>"Meyloma Dx",
                                                           :annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}, :warnings=>[["invalid source code", "203.0x"]]}, :name=>"ICD-9 CM"}], 4, {:annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}}, :name=>"Nth Occurrence"}],
                :right=>["time_window",
                         ["first",
                          ["recall", "Meyloma Dx", {:annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}}}],
                          {:annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}}}],
                         {:start=>"0", :end=>"90d", :annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}}}], :annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}}}],
       :right=>["union",
                ["during",
                 {:left=>["time_window",
                          ["recall", "Qualifying Meyloma Dx", {:annotation=>{:counts=>{:invalid=>{:rows=>0, :n=>0}}, :errors=>[["no matching label", "Qualifying Meyloma Dx"]]}}],
                          {:start=>"-90d", :end=>"0", :label=>"Meyloma 90-day Lookback", :annotation=>{:counts=>{:invalid=>{:rows=>0, :n=>0}}}}],
                  :right=>["cpt", "38220", "38221", "85102", "85095", "3155F", "85097", "88237", "88271", "88275", "88291", "88305", {:label=>"Bone Marrow", :annotation=>{:counts=>{:procedure_occurrence=>{:rows=>0, :n=>0}}}, :name=>"CPT"}], :annotation=>{:counts=>{:invalid=>{:rows=>0, :n=>0}}}}],
                ["occurrence",
                 ["during", {:left=>["cpt", "84156", "84166", "86335", "84155", "84165", "86334", "83883", "81264", "82784", "82785", "82787", "82040", "82232", "77074", "77075", "83615", {:label=>"Other Tests", :annotation=>{:counts=>{:procedure_occurrence=>{:rows=>0, :n=>0}}}, :name=>"CPT"}],
                             :right=>["recall", "Meyloma 90-day Lookback", {:annotation=>{:counts=>{:invalid=>{:rows=>0, :n=>0}}}}], :annotation=>{:counts=>{:procedure_occurrence=>{:rows=>0, :n=>0}}}}],
                 2,
                 {:annotation=>{:counts=>{:procedure_occurrence=>{:rows=>0, :n=>0}}}, :name=>"Nth Occurrence"}],
                {:annotation=>{:counts=>{:invalid=>{:rows=>0, :n=>0}, :procedure_occurrence=>{:rows=>0, :n=>0}}}}],
       :annotation=>{:counts=>{:condition_occurrence=>{:rows=>0, :n=>0}}}}]
    )
  end
end
