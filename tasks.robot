*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.PDF
Library    RPA.Tables
Library    RPA.Archive
Library    RPA.Windows
Library    RPA.Desktop
Library    RPA.FileSystem

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open the robot order website
    Accept cookies
    Download csv file
    Fill the form using the data from the CSV file
    Complete form
    Export as PDF
    Collect results
    Embed the robot screenshot to the receipt PDF file
    Close the browser
    Create zip package from PDF file

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Maximize Browser Window

Accept cookies
    Click Element    class=btn.btn-dark

Download csv file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    
Fill the form
    [Arguments]    ${get_order}
    Select From List By Value    head    ${get_order}[Head]
    RPA.Desktop.Press Keys    tab
    RPA.Desktop.Press Keys    down    ${get_order}[Body]
    RPA.Desktop.Press Keys    tab    ${get_order}[Legs]
    Input Text    address    ${get_order}[Address]
    Click Button    preview

Fill the form using the data from the CSV file
    ${get_orders}=    List Archive    orders.csv
    ${get_orders}=    Read table from CSV    orders.csv
    FOR    ${get_order}    IN    @{get_orders}
        Fill the form    ${get_order}
    END

Complete form
    Click Button    order

Export as PDF
    Wait Until Element Is Visible    id:receipt
    ${orders_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${orders_results_html}    ${OUTPUT_DIR}${/}receipt.pdf

Collect results
    RPA.Browser.Selenium.Screenshot    id=robot-preview-image    ${OUTPUT_DIR}${/}robot_created.png

Embed the robot screenshot to the receipt PDF file
    Open Pdf    ${OUTPUT_DIR}${/}receipt.pdf
    Add Watermark Image To Pdf    ${OUTPUT_DIR}${/}robot_created.png    ${OUTPUT_DIR}${/}receipt.pdf
    Close Pdf

Close the browser
    Close Browser

Create zip package from PDF file
    Archive Folder With Zip    output    all_saved.zip
