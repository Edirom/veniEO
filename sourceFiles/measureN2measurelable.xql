xquery version "3.0";

(: nbeer, 2018-03-28
 : updated by Dennis Ried, 2022
 : generate, copy/update @n and @lable of <measure/>
 : This is to be used in oXygen XML editor with Saxon-EE.
 :)

declare namespace mei="http://www.music-encoding.org/ns/mei";

let $sourceURI := '/Users/pathToFile/edirom_source_.xml'

let $doc := doc($sourceURI)
let $mdivs := $doc//mei:mdiv

(: TODO: Does not work wor sources containig parts! :)
for $mdiv in $mdivs
    let $measures := $mdiv//mei:measure
    for $measure in $measures
        let $n := $measure/@n
        let $label := $measure/@label
        return
            if($label)
            then(replace value of node $label with $n)
            else(insert nodes (attribute label {$n}) as last into $measure)
