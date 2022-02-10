xquery version "3.1";

(:~
: This xquery consumes a edirom-specific mei work-file and returns the mei:classification,
: followed by the distinct category and priority references actually used.
: The query is supposed to run in the edition's database.
:
: @author Benjamin W.Bohl
: @version 1.0.0
: @date 2022-02-10
: @param mei-work.uri the uri to the mei-work-file as xs:string()
: @return node()
:)

declare namespace mei="http://www.music-encoding.org/ns/mei";

declare variable $mei-work := doc(request:get-parameter('mei-work.uri', 'xmldb:exist:///db/apps/Bargheer-Edition/works/edirom_work_2c574d8e-fbb7-44b6-bc73-f1b5715621e8.xml'));
declare variable $annots := $mei-work//mei:annot[@type="editorialComment"];
declare variable $categoryRefs := for $targets in $annots//mei:ptr[@type="categories"]/@target return tokenize($targets, ' ');
declare variable $categoryLabels := map:merge(
    for $item in $mei-work//mei:term[@classcode="ediromCategory"]
    return
        map:entry($item/@xml:id, $item/mei:name/text())
    );


element mei-work {
    attribute title {normalize-space($mei-work//mei:work/mei:titleStmt/mei:title)},
    attribute location {request:get-server-name()},
    $mei-work//mei:classification,
    element classification-used {
        for $dv in distinct-values($categoryRefs)
        return 
            element categoryLabel {
                attribute value {$dv},
                map:get($categoryLabels, substring-after($dv, '#'))
            }
    }
}