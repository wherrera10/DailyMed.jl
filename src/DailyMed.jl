module DailyMed

export applicationnumbers, drugclasses, ndcs, rxcuis, spls, spls_setid, history, media, ncds, packaging, uniis

using HTTP
using EzXML

const BASEURL = "https://dailymed.nlm.nih.gov/dailymed/services/v2/"

const METATAGS = ["total_elements", "elements_per_page", "total_pages", "current_page",
    "current_url", "previous_page", "previous_page_url", "next_page", "next_page_url"]

"""
    dailymed(restfunc, extra)

Get and partially parse data from the url formed by `BASEURL * restfunc *`` expanded `extra` args
"""
function dailymed(restfunc, extra)
    url = BASEURL * restfunc
    if any(x -> x[2] != "", extra)
        url *= "?"
        for p in extra
            if p[2] != ""
                url *= (url[end] == '?' ? "&" : "") * "$(p[1])=$(p[2])"
            end
        end
    end
    try
        req = HTTP.request("GET", url)
        doc = parsexml(String(req.body)).root
        meta = findfirst("//metadata", doc)
        return doc, Dict(tag => nodecontent(findfirst(tag, meta)) for tag in METATAGS)
    catch y
        @warn y
        return parsexml("<root></root>"), Dict()
    end
end

"""
    applicationnumbers(; extra = [])

Returns a list of all NDA numbers.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "application_number", "marketing_category_code", "setid", "pagesize", "page"
"""
function applicationnumbers(; extra = [])
    doc, metadict = dailymed("applicationnumbers.xml", extra)
    return nodecontent.(findall("//application_number", doc)), metadict
end

"""
    drugclasses(; extra = [])

Returns a list of all drug classes associated with at least one SPL in the
Pharmacologic Class Indexing Files.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "drug_class_code", "drugclass_coding_system", "code_class_type",
"class_name", "unii_code", "pagesize", "page"
"""
function drugclasses(; extra = [])
    dctups = NamedTuple[]
    d, metadict = Dict(extra), Dict()
    while true
        doc, metadict = dailymed("drugclasses.xml", d)
        for dcl in findall("//drugclass", doc)
            push!(dctups, (name = nodecontent(findfirst("name", dcl)), code = nodecontent(findfirst("code", dcl))))
        end
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)
    end
    return dctups, metadict
end

"""
    drugnames(; extra = [])

Returns a list of all drug names.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "name_type", "manufacturer", "pagesize", "page"
"""
function drugnames(; extra = [])
    doc, metadict = dailymed("drugnames.xml", extra)
    return nodecontent.(findall("//drug_name", doc)), metadict
end

"""
    function ndcs(; extra = [])

Returns a list of all NDC codes.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"
"""
function ndcs(; extra = [])
    doc, metadict = dailymed("ndcs.xml", extra)
    return nodecontent.(findall("//ndc", doc)), metadict
end

"""
    function rxcuis(; extra = [])

Returns a list of all product-level RxCUIs.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "rxtty", "rxstring", "rxcui", "pagesize", "page"
"""
function rxcuis(; extra = [])
    dctups = NamedTuple[]
    doc, metadict = dailymed("rxcuis.xml", extra)
    for dcl in findall("//rxconcept", doc)
        push!(dctups, (rxcui = findfirst("rxcui", dcl),
            rxstring = findfirst("rxstring", dcl), rxtty = findfirst("rxtty", dcl)))
    end
    return dctups, metadict
end


"""
    function spls(; extra = [])

Returns a list of all SPLs.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "application_number", "boxed_warning", "dea_schedule_code", "doctype",
"drug_class_code", "drugclass_coding_system", "drug_name", "name_type", "labeler",
"manufacturer", "marketing_category_code", "ndc", "published_date",
"published_date_comparison", "rxcui", "setid", "unii_code", "pagesize", "page"
"""
function spls(; extra = [])
    dctups = NamedTuple[]
    doc, metadict = dailymed("spls.xml", extra)
    for dcl in findall("//spl", doc)
        push!(dctups, (setid = findfirst("setid", dcl),
            spl_version = findfirst("spl_version", dcl), title = findfirst("title", dcl),
            published_date = findfirst("published_date", dcl)))
    end
    return dctups, metadict
end

"""
    function function spls_setid(setid)

Returns an SPL document for specific SET ID.
"""
function spls_setid(setid)
    url = BASEURL * "spls/$(setid).xml"
    try
        req = HTTP.request("GET", url)
        return String(req.body)
    catch y
        return "<xml>$y</xml>"
    end
end

"""
    function history(setid; extra)

Returns version history for specific SET ID.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"
"""
function history(setid; extra)
    dctups = NamedTuple[]
    doc, metadict = dailymed("spls/$(setid)/history.xml", extra)
    for dcl in findall("//history_entry", doc)
        push!(dctups, (setid = findfirst("setid", dcl),
            spl_version = findfirst("spl_version", dcl), published_date = findfirst("published_date", dcl)))
    end
    return dctups, metadict
end

"""
    function media(setid; extra = [])

Returns links to all media for specific SET ID.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"
"""
function media(setid; extra)
    dctups = NamedTuple[]
    doc, metadict = dailymed("spls/$(setid)/media.xml", extra)
    for dcl in findall("//file", doc)
        push!(dctups, (name = findfirst("name", dcl),
            mime_type = findfirst("mime_type", dcl), url = findfirst("url", dcl)))
    end
    return dctups, metadict
end

"""
    function ndcs(setid; extra = [])

Returns all ndcs for specific SET ID.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"
"""
function ndcs(setid; extra = [])
    doc, metadict = dailymed("spls/$(setid)/ndcs.xml", extra)
    return nodecontent.(findall("//ndc", doc))
end

"""
    function packaging(setid; extra = [])

Return the XML string for the packaging of the item with the given setid.
The packaging XML is highlt variable in labeling nd may be deeply nested, so an array
or tuple is not computed, but instead the XML itself is returned.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"
"""
function packaging(setid; pagesize = 100, page = 1)
    url = BASEURL * "spls/$(setid)/packaging.xml?pagesize=$pagesize&page=$page"
    try
        req = HTTP.request("GET", url)
        return String(req.body)
    catch y
        return "<xml>$y</xml>"
    end
end

"""
    function uniis(; extra = [])

Returns a list of all UNIIs.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "active_moiety", "drug_class_code", "drug_class_coding_system",
"rxcui", "unii_code", "pagesize", "page"
"""
function uniis(; extra = [])
    dctups = NamedTuple[]
    doc, metadict = dailymed("uniis.xml", extra)
    for dcl in findall("//unii", doc)
        push!(dctups, (unii_code = findfirst("unii_code", dcl),
            active_moiety = findfirst("active_moiety", dcl)))
    end
    return dctups, metadict
end

end # module
