using DailyMed
using EzXML
using Test

a, meta = applicationnumbers(extra = ["page" => "132"])
@test last(a) == "VMF006011"

a, meta = drugclasses()
@test first(first(a).name) == '4'

a, meta = drugnames(extra = ["page" => "930"])
@test first(a)[1:2] == "ZI"

a, meta = ndcs(extra = ["page" => "3600"])
@test last(a) == "W4215-S1393-01"

a, meta = spls(extra = ["rxcui" => "312962"])
first(a).title == "SIM"

a, meta = spls_setid("1efe378e-fee1-4ae9-8ea5-0fe2265fe2d8")
@test contains(a, "EDECRIN")

a, meta = history("9aa7140c-012c-4ea6-866d-4732e915dab6")
first(a).spl_version == "3"

a, meta = media("1efe378e-fee1-4ae9-8ea5-0fe2265fe2d8")
first(a).mime_type == "image/jpeg"

a, meta = ndcs("1efe378e-fee1-4ae9-8ea5-0fe2265fe2d8")
a == "42571"

a, meta = packaging("l51b031a0-bc40-4159-a434-d48c3eadd2ca")
@test contains(a, "aminolevulinic acid")

a, meta = uniis(extra = ["page" => "60"])
@test length(a) > 500
@test a[end - 1].active_moiety == "ZUCCHINI"
