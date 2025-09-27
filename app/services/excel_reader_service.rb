require "roo"

class ExcelReaderService
  def initialize(file_path)
    @file_path = file_path
    @workbook = Roo::Spreadsheet.open(file_path)
  end

  def extract_policy_data
    policies = []

    # Process each sheet in the workbook
    @workbook.sheets.each do |sheet_name|
      sheet = @workbook.sheet(sheet_name)

      # Skip if sheet is empty
      next if sheet.last_row.nil? || sheet.last_row < 2

      # Assume first row contains headers
      headers = sheet.row(1).map(&:to_s).map(&:strip)

      # Process each data row
      (2..sheet.last_row).each do |row_num|
        row_data = sheet.row(row_num)

        # Skip empty rows
        next if row_data.all?(&:nil?)

        # Create policy record
        policy_record = {}
        headers.each_with_index do |header, index|
          policy_record[header.downcase.gsub(/\s+/, "_")] = row_data[index]&.to_s&.strip
        end

        # Add metadata
        policy_record["sheet_name"] = sheet_name
        policy_record["row_number"] = row_num

        policies << policy_record
      end
    end

    policies
  end

  def extract_text_content
    text_content = []

    @workbook.sheets.each do |sheet_name|
      sheet = @workbook.sheet(sheet_name)

      next if sheet.last_row.nil?

      # Extract all text content from the sheet
      sheet_text = []
      (1..sheet.last_row).each do |row_num|
        row_data = sheet.row(row_num)
        row_text = row_data.compact.map(&:to_s).join(" ")
        sheet_text << row_text unless row_text.strip.empty?
      end

      if sheet_text.any?
        text_content << {
          sheet_name: sheet_name,
          content: sheet_text.join("\n")
        }
      end
    end

    text_content
  end

  def get_sheet_names
    @workbook.sheets
  end

  def preview_sheet(sheet_name, max_rows = 10)
    sheet = @workbook.sheet(sheet_name)
    preview = []

    last_row = [sheet.last_row, max_rows].min
    (1..last_row).each do |row_num|
      preview << sheet.row(row_num)
    end

    preview
  end
end
