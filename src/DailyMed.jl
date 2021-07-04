module DailyMed

export applicationnumbers, drugclasses, drugnames, ndcs, rxcuis, spls, spls_setid, history, media, ncds, packaging, uniis

using HTTP
using EzXML
using RxNav

const BASEURL = "https://dailymed.nlm.nih.gov/dailymed/services/v2/"

const METATAGS = ["total_elements", "elements_per_page", "total_pages", "current_page",
    "current_url", "previous_page", "previous_page_url", "next_page", "next_page_url", "db_published_date"]

"""
    `allsetids(resource::String)`
    
Given a resource which is either an RxCUI id or the name of a drug, return a vector
of all of the DailyMed Set ID identifiers for the resouce. These can then be used for
the functions `history`, `media`, `ndcs`, or `packaging`.
"""
function allsetids(resource)
    rxcu = RxNav.is_in_rxcui_format(resource) ? resource : RxNav.rcui(resource)
    setids = [x.setid for x in first(spls(extra = ["rxcui" => rxcu]))]
    return setids
end

"""
    `dailymed(restfunc, extra)`

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
        metatags = Dict{String, String}()
        for tag in METATAGS
            if (x = findfirst(tag, meta)) != nothing
                metatags[tag] = nodecontent(x)
            end
        end
        return doc, metatags
    catch y
        # warn if it is likely to have been our error, just return if it was internal to REST code on server
        !contains(string(y), "Internal Server Error") && @warn y
        return parsexml("<root></root>"), Dict()
    end
end

"""
    `applicationnumbers(; extra = [])`

Returns a list of all NDA numbers.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "application_number", "marketing_category_code", "setid", "pagesize", "page"
"""
function applicationnumbers(; extra = [])
    appnums, d, metadict = String[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("applicationnumbers.xml", d)
        append!(appnums, nodecontent.(findall("//application_number", doc)))
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)
    end
    return appnums, metadict
end

"""
    `drugclasses(; extra = [])`

Returns a list of all drug classes associated with at least one SPL in the
Pharmacologic Class Indexing Files.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "drug_class_code", "drugclass_coding_system", "code_class_type",
"class_name", "unii_code", "pagesize", "page"
"""
function drugclasses(; extra = [])
    dctups, d, metadict = NamedTuple[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("drugclasses.xml", d)
        for dcl in findall("//drugclass", doc)
            push!(dctups, (name = nodecontent(findfirst("name", dcl)), 
                           code = nodecontent(findfirst("code", dcl))))
        end
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)
    end
    return dctups, metadict
end

"""
    `drugnames(; extra = [])`

Returns a list of all drug names. A <em>very large</em> string vector is returned, and the metadata

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "name_type", "manufacturer", "pagesize", "page"
"""
function drugnames(; extra = [])
    dnames, d, metadict = String[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("drugnames.xml", d)
        append!(dnames, nodecontent.(findall("//drug_name", doc)))
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage) 
    end
    return dnames, metadict
end

"""
    `function ndcs(; extra = [])`

Returns a list of all NDC codes.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize" or "page"
"""
function ndcs(; extra = [])
    codes, d, metadict = String[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("ndcs.xml", d)
        append!(codes, nodecontent.(findall("//ndc", doc)))
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)        
    end
    return codes, metadict
end

"""
    function rxcuis(; extra = [])

Returns a list of all product-level RxCUIs.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "rxtty", "rxstring", "rxcui", "pagesize", "page"
"""
function rxcuis(; extra = [])   
    dctups, d, metadict = NamedTuple[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("rxcuis.xml", d)
        for dcl in findall("//rxconcept", doc)
            push!(dctups, (rxcui = nodecontent(findfirst("rxcui", dcl)), 
                rxstring = nodecontent(findfirst("rxstring", dcl)),
                rxtty = nodecontent(findfirst("rxtty", dcl))))
        end
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)
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
    dctups, d, metadict = NamedTuple[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("spls.xml", d)
        for dcl in findall("//spl", doc)
            push!(dctups, (setid = nodecontent(findfirst("setid", dcl)),
                spl_version = nodecontent(findfirst("spl_version", dcl)),
                title = nodecontent(findfirst("title", dcl)),
                published_date = nodecontent(findfirst("published_date", dcl))))
        end
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)
    end
    return dctups, metadict
end

"""
    function function spls_setid(setid)

Returns an SPL document for specific SET ID.
"""
function spls_setid(setid)
    url, metadict = BASEURL * "spls/$setid.xml", Dict()
    try
        req = HTTP.request("GET", url)
        return String(req.body), metadict
    catch y
        return "<xml>$y</xml>", metadict
    end
end

"""
    function history(setid; extra)

Returns version history for specific SET ID.

extra is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"
"""
function history(setid; extra = [])
    dctups, d, metadict = NamedTuple[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("spls/$(setid)/history.xml", d)
        for dcl in findall("//history/history_entry", doc)
            push!(dctups, (spl_version = nodecontent(findfirst("spl_version", dcl)),
                           published_date = nodecontent(findfirst("published_date", dcl))))
        end
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)    
    end
    return dctups, metadict
end

"""
    function media(setid; extra = [])

Returns links to all media for specific SET ID.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"
"""
function media(setid; extra = [])
    dctups, d, metadict = NamedTuple[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("spls/$(setid)/media.xml", d)
        for dcl in findall("//file", doc)
            push!(dctups, (name = nodecontent(findfirst("name", dcl)),
                mime_type = nodecontent(findfirst("mime_type", dcl)),
                url = nodecontent(findfirst("url", dcl))))
        end
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)
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
    nds, d, metadict = String[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("spls/$setid/ndcs.xml", d)
        append!(nds, nodecontent.(findall("//ndcs/ndc", doc)))
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)
    end
    return nds, metadict
end

"""
    function packaging(setid; extra = [])

Return the XML string for the packaging of the item with the given setid.
The packaging XML is highly variable in labeling and may be deeply nested, so an array
or tuple is not computed, but instead the XML itself is returned.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "pagesize", "page"
"""
function packaging(setid; extra = [])
    allpages, d, metadict = "", Dict(extra), Dict()
    try
        while true
            doc, metadict = dailymed("spls/$setid/packaging.xml", d)
            allpages *= string(findfirst("//products", doc))  
            nextpage = tryparse(Int, get(metadict, "next_page", ""))
            nextpage == nothing && break
            d["page"] = string(nextpage)
        end
    catch y
        @warn y
    end
    return allpages, metadict
end

"""
    function uniis(; extra = [])

Returns a list of all UNIIs.

`extra` is optional. If provided it should be a `Dict` or list of string `Pair`s,
and can be "active_moiety", "drug_class_code", "drug_class_coding_system",
"rxcui", "unii_code", "pagesize", "page"
"""
function uniis(; extra = [])
    dctups, d, metadict = NamedTuple[], Dict(extra), Dict()
    while true
        doc, metadict = dailymed("uniis.xml", d)
        for dcl in findall("//unii", doc)
            push!(dctups, (unii_code = nodecontent(findfirst("unii_code", dcl)),
                active_moiety = nodecontent(findfirst("active_moiety", dcl))))
        end
        nextpage = tryparse(Int, get(metadict, "next_page", ""))
        nextpage == nothing && break
        d["page"] = string(nextpage)
    end
    return dctups, metadict
end

end # module
