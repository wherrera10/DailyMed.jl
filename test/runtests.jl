using DailyMed
using EzXML
using Test

a, meta = applicationnumbers(extra = ["page" => "132"])
@test last(a) == "VMF006011"

a, meta = drugclasses()
@test first(first(a).name) == '4'

a, meta = drugnames(extra = ["page" => "930"])
@test first(a)[1:2] == "SU"

a, meta = ndcs(extra = ["page" => "3600"])
@test last(a) == "W4215-S1393-01"

a, meta = spls(extra = ["rxcui" => "312962"])
@test startswith(first(a).title, "SIM")

a, meta = spls_setid("1efe378e-fee1-4ae9-8ea5-0fe2265fe2d8")
@test contains(a, "EDECRIN")

a, meta = history("9aa7140c-012c-4ea6-866d-4732e915dab6")
@test first(a).spl_version == "3"

a, meta = media("1efe378e-fee1-4ae9-8ea5-0fe2265fe2d8")
@test first(a).mime_type == "image/jpeg"

a, meta = ndcs("1efe378e-fee1-4ae9-8ea5-0fe2265fe2d8")
@test "25010-210-27" in a

a, meta = packaging("650daa9f-aeec-49ce-95b9-5fa20b988afd")
@test contains(a, "aminolevulinic acid")

a, meta = uniis(extra = ["page" => "60"])
@test length(a) > 500
@test any(x -> x.active_moiety == "ZUCCHINI", a)

true
