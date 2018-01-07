open Base
open OUnit2
open Printf

(* Test documents come from OpenOffice's test suite:
   https://www.openoffice.org/sc/testdocs/

   I downloaded the "XML" versions of each document, then converted them to
   CSV using OpenOffice. The tests then compare our input of the XLSX
   document to the CSV.

   Note: OpenOffice seems to round floats when exporting CSV, so I had to
   manually edit the CSV's to have the literal float values in the XLSX file. *)

let printer xlsx =
  Xlsx_parser.sexp_of_sheet xlsx
  |> Sexp.to_string_hum

let sort_sheets =
  List.sort ~cmp:(fun a b ->
    String.compare a.Xlsx_parser.name b.Xlsx_parser.name)

let make_test (skip, file_name, sheet_names) =
  let sheet_names = List.sort ~cmp:String.compare sheet_names in
  file_name >::
    fun _ ->
      skip_if (match skip with
      | `Skip -> true
      | `Run -> false)
        "not fixed yet";
      let expect =
        List.map sheet_names ~f:(fun sheet_name ->
          let rows =
            sprintf "test/files/%s_%s.csv" file_name sheet_name
            |> Csv.load ~strip:false
            |> Csv.to_array
            |> Array.map ~f:Array.to_list
            |> Array.to_list
          in
          { Xlsx_parser.name = sheet_name ; rows })
        |> sort_sheets
      in
      Xlsx_parser.read_file (sprintf "test/files/%s.xlsx" file_name)
      |> sort_sheets
      |> List.iter2_exn expect ~f:(fun expect actual ->
        assert_equal ~printer expect actual)

let () =
  [ `Run, "autofilter_import_xml_12", [ "Discrete"; "Top10"; "Custom"; "Advanced1"; "Advanced2" ]
  ; `Skip, "cellformat_import_xml_12", [ "Font"; "Number Format"; "Alignment"; "Protection"; "Border"; "Fill"; "Styles" ]
  ; `Skip, "cellnotes_import_xml_12", [ "Line"; "Fill"; "Visibility" ]
  ; `Run, "cells_import_xml_12", [ "Sheet1" ]
  ; `Skip, "chart_3dsettings_import_xml_12", [ "Rotation"; "Elevation"; "Perspective"; "Settings"; "SourceData" ]
  ; `Skip, "chart_axis_import_xml_12", [ "Axis Line"; "Axis Labels"; "Tick Marks"; "Gridlines"; "SourceData" ]
  ; `Skip, "chart_axis_scaling_import_xml_12", [ "Linear"; "Logarithmic"; "Category"; "Scatter"; "Date"; "Secondary"; "Series"; "SourceData" ]
  ; `Skip, "chart_bitmaps_import_xml_12", [ "General"; "Series 2D"; "Series 3D"; "SourceData" ]
  ; `Skip, "chart_charttype_area_import_xml_12", [ "Area 2D"; "Area 3D"; "SourceData" ]
  ; `Skip, "chart_charttype_bar_import_xml_12", [ "Bar 2D"; "Bar 3D"; "SourceData" ]
  ; `Skip, "chart_charttype_line_import_xml_12", [ "Line 2D"; "Line 3D"; "Stock 2D"; "SourceData" ]
  ; `Skip, "chart_charttype_pie_import_xml_12", [ "Pie 2D"; "Pie 3D"; "Doughnut 2D"; "PieOfPie 2D"; "BarOfPie 2D"; "SourceData" ]
  ; `Skip, "chart_charttype_radar_import_xml_12", [ "Radar 2D"; "SourceData" ]
  ; `Skip, "chart_charttype_scatter_import_xml_12", [ "Scatter 2D"; "Bubbles 2D"; "SourceData" ]
  ; `Skip, "chart_charttype_surface_import_xml_12", [ "Surface 2D"; "Surface 3D"; "SourceData" ]
  ; `Skip, "chart_embeddedshapes_import_xml_12", [ "Shape Types"; "Positioning"; "Source Data" ]
  ; `Skip, "chart_formatting_import_xml_12", [ "Styles"; "Color Cycling"; "Manual"; "SourceData" ]
  ; `Skip, "chart_positioning_import_xml_12", [ "Plot Area"; "Legend"; "Titles"; "Labels"; "SourceData" ]
  ; `Skip, "chart_series_import_xml_12", [ "Data Source"; "Formatting"; "Data Labels"; "SourceData" ]
  ; `Skip, "chart_sourcedata_missing_import_xml_12", [ "Missing"; "Hidden"; "SourceData" ]
  ; `Skip, "chart_title_import_xml_12", [ "Main Title"; "Axis Titles"; "Legend"; "Formatting"; "SourceData" ]
  ; `Skip, "condformat_import_xml_12", [ "Cell Conditions"; "Range Conditions"; "Font"; "Border"; "Fill"; "Number" ]
  ; `Skip, "datavalidation_import_xml_12", [ "Types"; "Formulas"; "Settings" ]
  ; `Skip, "drawing_import_xml_12", [ "Simple"; "Line"; "Fill"; "Color"; "Style"; "Shadow"; "Textbox"; "Chart"; "Group"; "AutoShape"; "Picture"; " Background"; "Right-To-Left" ]
  ; `Skip, "externallink_import_xml_12", [ "Sheet1"; "Sheet2"; "Sheet3"; "Sheet4"; "Sheet5"; "Sheet6" ]
  ; `Skip, "formcontrols_bitmaps_import_xml_12", [ "Picture"; "MousePointer" ]
  ; `Skip, "formcontrols_import_xml_12", [ "AxCmdButton"; "AxLabel"; "AxImage"; "AxToggle"; "AxCheckBox"; "AxOptButton"; "AxTextBox"; "AxListBox"; "AxComboBox"; "AxSpinButton"; "AxScrollBar" ]
  ; `Skip, "formcontrols_legacy_import_xml_12", [ "Legacy Controls" ]
  ; `Skip, "formula_import_xml_12", [ "Cell"; "Table"; "Param"; "Functions"; "Array"; "Shared"; "TableOp" ]
  ; `Skip, "hyperlink_import_xml_12", [ "Sheet1"; "Sheet2"; "Sheet'!" ]
  ; `Skip, "numberformat_import_xml_12", [ "Sheet1" ]
  ; `Skip, "oleobject_import_xml_12", [ "OLE"; "SourceData" ]
  ; `Skip, "pagesettings_import_xml_12", [ "Default"; "Changed 1"; "Changed 2"; "Header" ]
  ; `Skip, "pivottable_datasource_import_xml_12", [ "Internal"; "External"; "DataType"; "ExtCache"; "Data" ]
  ; `Skip, "pivottable_grouping_import_xml_12", [ "Discrete"; "Numeric"; "DateTime"; "Data" ]
  ; `Skip, "pivottable_layout_import_xml_12", [ "RowColDim"; "RowColSettings"; "ItemSettings"; "DataDim"; "DataSettings"; "PageDim"; "PageSettings"; "TableSettings"; "Data" ]
  ; `Skip, "scenarios_import_xml_12", [ "Ranges"; "Settings"; "Name"; "RefCheck" ]
  ; `Run, "sheetprotection_import_xml_12", [ "Sheet1"; "Sheet2"; "Sheet3"; "Sheet4" ]
  ; `Skip, "viewsettings_import_xml_12", [ "No Splits 1"; "No Splits 2"; "Frozen Vert 1"; "Frozen Vert 2"; "Frozen Hor 1"; "Frozen Hor 2"; "Frozen 1"; "Frozen 2"; "Split Vert 1"; "Split Vert 2"; "Split Hor 1"; "Split Hor 2"; "Split 1"; "Split 2"; "Split 3"; "Selection"; "Sheet Settings 1"; "Sheet Settings 2"; "Sheet Settings 3"; "Sheet Settings 4"; "Mirrored Sheet"; "Show Formulas" ]]
  |> List.map ~f:make_test
  |> test_list
  |> run_test_tt_main
