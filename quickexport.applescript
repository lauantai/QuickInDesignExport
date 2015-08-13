on alfred_script(q)

-- options
set exportSubFolderName to "exported"
set defaultPDFPreset to "" -- e.g. "[Press Quality]"
set jpegResolutions to {72, 150, 300}
set defaultJPGResolution to 72
-- end options

set pageRange to q as string

tell application id "com.adobe.InDesign"
    activate

    set pdfPageRange to pageRange
    set jpgPageRange to pageRange

    if (pageRange is equal to "") then
        set pdfPageRange to all pages
        set jpgPageRange to "All Pages"
    end if

    set pdfPresets to get the name of every PDF export preset
    if defaultPDFPreset = "" then
        set defaultPDFPreset to item 1 of pdfPresets
    end if
    set pdfPreset to (choose from list pdfPresets default items {defaultPDFPreset}) as string

    set jpegResolution to (choose from list jpegResolutions default items {defaultJPGResolution}) as integer

    repeat with thisDoc in (active document)
        set docName to get name of thisDoc
        tell thisDoc
            set docPath to (get file path)

            tell application "Finder"
                set exportFolder to (docPath as string) & exportSubFolderName
                if (exists folder exportFolder) = true then
                    set exportPath to folder exportFolder as string
                else
                    set exportPath to (make new folder at folder docPath with properties {name:exportSubFolderName}) as string
                end if
            end tell
        end tell

        tell PDF export preferences
            set page range to pdfPageRange
        end tell

        tell JPEG export preferences
            set export resolution to jpegResolution
            set Page String to jpgPageRange as string
            set JPEG export range to export range 
            set JPEG quality to maximum
            set JPEG color space to RGB
        end tell

        set pathPrefix to exportPath & (characters 1 thru -6 of docName)
        set pdfExportPath to pathPrefix & ".pdf"
        set jpegExportPath to pathPrefix & "_" & jpegResolution & "dpi.jpg"

        tell thisDoc
            export format PDF type to pdfExportPath using pdfPreset without showing options
            export format JPG to jpegExportPath without showing options
        end tell

        display notification with title "InDesign document exported" subtitle docName

        tell application "Finder"
            open exportPath
            set selection to {file pdfExportPath, file jpegExportPath}
        end tell
    end repeat
end tell

end alfred_script

on run q
    alfred_script(q)
end run

