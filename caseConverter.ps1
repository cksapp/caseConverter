<#PSScriptInfo
.VERSION 1.0

.GUID 3bb10ee7-38c1-41b9-88ea-16899164fc19

.AUTHOR CKSAPP (built with GitHub Copilot AI agent GPT-4.1 model)

.COMPANYNAME Kaseya

.PROJECTURI

.RELEASENOTES Initial release.
#>

<#
.SYNOPSIS
  Case Converter GUI for Windows (PowerShell/WPF)

.DESCRIPTION
  Modern PowerShell GUI for converting text between lowercase and uppercase.
  Supports multi-line input/output, easy copy button, and theme adaptation (light/dark).
  Theme defaults to system, but can be manually set in the settings menu.

.NOTES
  Script built primarily with the assistance of GitHub Copilot AI and the Copilot agent model.

.LINK
  https://github.com/features/copilot
#>
# Import WPF namespaces
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# Theme configuration
$themeConfig = @{
    Light = @{
        Background = [Windows.Media.Brushes]::WhiteSmoke
        Panel = [Windows.Media.Brushes]::White
        Border = [Windows.Media.Brushes]::Gainsboro
        Text = [Windows.Media.Brushes]::Black
    }
    Dark = @{
        Background = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(26,26,26))
        Panel = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(35,39,46))
        Border = New-Object Windows.Media.SolidColorBrush ([Windows.Media.Color]::FromRgb(68,71,90))
        Text = [Windows.Media.Brushes]::White
    }
}

# Detect system theme (Windows 10/11)
$theme = 'Light'
try {
    $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    $appsUseLightTheme = (Get-ItemProperty -Path $regPath -Name AppsUseLightTheme -ErrorAction SilentlyContinue).AppsUseLightTheme
    if ($appsUseLightTheme -eq 0) { $theme = 'Dark' }
} catch {}

# UI Creation
$window = New-Object System.Windows.Window
$window.Title = "Case Converter"
$window.Width = 600
$window.Height = 400
$window.Background = if ($theme -eq 'Dark') { $themeConfig.Dark.Background } else { $themeConfig.Light.Background }

$window.Add_SourceInitialized({
    $inputBox.Focus() | Out-Null
})

# Use a grid with star sizing for rows
$mainGrid = New-Object Windows.Controls.Grid
$mainGrid.Margin = '20'
$row0 = New-Object Windows.Controls.RowDefinition
$row0.Height = "Auto" # Theme controls
$row1 = New-Object Windows.Controls.RowDefinition
$row1.Height = "*"
$row2 = New-Object Windows.Controls.RowDefinition
$row2.Height = "Auto"
$row3 = New-Object Windows.Controls.RowDefinition
$row3.Height = "*"
$row4 = New-Object Windows.Controls.RowDefinition
$row4.Height = "Auto"
$mainGrid.RowDefinitions.Add($row0)
$mainGrid.RowDefinitions.Add($row1)
$mainGrid.RowDefinitions.Add($row2)
$mainGrid.RowDefinitions.Add($row3)
$mainGrid.RowDefinitions.Add($row4)
$window.Content = $mainGrid

# Settings menu (Menu control)
$settingsMenu = New-Object Windows.Controls.Menu
$settingsMenu.HorizontalAlignment = 'Left'
$settingsMenu.VerticalAlignment = 'Top'
$settingsMenu.Margin = '0,0,0,10'
$settingsMenu.FlowDirection = 'LeftToRight'
$settingsMenu.BorderThickness = 1
$settingsMenu.BorderBrush = $themeConfig.Light.Border
$settingsMenu.Effect = New-Object Windows.Media.Effects.DropShadowEffect -Property @{ ShadowDepth = 2; Color = ([Windows.Media.Colors]::Gray); Opacity = 0.18; BlurRadius = 4 }

# Settings menu item
$settingsItem = New-Object Windows.Controls.MenuItem
$settingsItem.Header = "Settings"
$null = $settingsMenu.Items.Add($settingsItem)

# Theme submenu (radio buttons for Light/Dark)
$themeMenuItem = New-Object Windows.Controls.MenuItem
$themeMenuItem.Header = "Theme"
$themeMenuItem.StaysOpenOnClick = $true
$themeMenuItem.HorizontalContentAlignment = 'Left'
$themeMenuItem.VerticalContentAlignment = 'Center'
$themeMenuItem.FlowDirection = 'LeftToRight'
$null = $settingsItem.Items.Add($themeMenuItem)

# Light/Dark radio buttons
$lightRadio = New-Object Windows.Controls.RadioButton
$lightRadio.Content = "Light"
$lightRadio.Margin = '0,0,0,5'
$lightRadio.IsChecked = ($theme -eq 'Light')
$darkRadio = New-Object Windows.Controls.RadioButton
$darkRadio.Content = "Dark"
$darkRadio.Margin = '0,0,0,5'
$darkRadio.IsChecked = ($theme -eq 'Dark')

# Add radio buttons to theme menu
$themeMenuPanel = New-Object Windows.Controls.StackPanel
$themeMenuPanel.Orientation = 'Vertical'
$null = $themeMenuPanel.Children.Add($lightRadio)
$null = $themeMenuPanel.Children.Add($darkRadio)
$null = $themeMenuItem.Items.Add($themeMenuPanel)


[Windows.Controls.Grid]::SetRow($settingsMenu, 0)
$null = $mainGrid.Children.Add($settingsMenu)

# Input TextBox (multi-line, resizable, modern)
$inputBox = New-Object Windows.Controls.TextBox
$inputBox.Margin = '0,0,0,14'
$inputBox.FontSize = 17
$inputBox.VerticalAlignment = 'Stretch'
$inputBox.HorizontalAlignment = 'Stretch'
$inputBox.AcceptsReturn = $true
$inputBox.TextWrapping = 'Wrap'
$inputBox.Padding = '10'
$inputBox.BorderThickness = 1
$inputBox.BorderBrush = $themeConfig[$theme].Border
$inputBox.Background = $themeConfig[$theme].Panel
$inputBox.Foreground = $themeConfig[$theme].Text
[Windows.Controls.Grid]::SetRow($inputBox, 1)
$null = $mainGrid.Children.Add($inputBox)

# Uppercase switch between input and output (modern)
$upperCheckBox = New-Object Windows.Controls.CheckBox
$upperCheckBox.Content = "Output UPPERCASE"
$upperCheckBox.Margin = '0,0,0,14'
$upperCheckBox.FontSize = 15
$upperCheckBox.VerticalAlignment = 'Center'
$upperCheckBox.Padding = '6,2,6,2'
if ($theme -eq 'Dark') {
    $upperCheckBox.Foreground = [Windows.Media.Brushes]::White
} else {
    $upperCheckBox.Foreground = [Windows.Media.Brushes]::Black
}
[Windows.Controls.Grid]::SetRow($upperCheckBox, 2)
$null = $mainGrid.Children.Add($upperCheckBox)

# Output TextBox (multi-line, read-only, resizable, modern)
$outputBox = New-Object Windows.Controls.TextBox
$outputBox.FontSize = 17
$outputBox.VerticalAlignment = 'Stretch'
$outputBox.HorizontalAlignment = 'Stretch'
$outputBox.IsReadOnly = $true
$outputBox.AcceptsReturn = $true
$outputBox.TextWrapping = 'Wrap'
$outputBox.Margin = '0,0,0,0'
$outputBox.Padding = '10'
$outputBox.BorderThickness = 1
$outputBox.BorderBrush = $themeConfig[$theme].Border
$outputBox.Background = $themeConfig[$theme].Panel
$outputBox.Foreground = $themeConfig[$theme].Text
[Windows.Controls.Grid]::SetRow($outputBox, 3)
$null = $mainGrid.Children.Add($outputBox)

# Add a new row for the copy button at the bottom
$copyRow = New-Object Windows.Controls.RowDefinition
$copyRow.Height = 'Auto'
$null = $mainGrid.RowDefinitions.Add($copyRow)

# Copy Button at the bottom, spanning the width
$copyButton = New-Object Windows.Controls.Button
$copyButton.Content = "Copy"
$copyButton.MinHeight = 28
$copyButton.MinWidth = 48
$copyButton.FontSize = 14
$copyButton.Padding = '6,0,6,0'
$copyButton.Margin = '0,10,0,0'
$copyButton.BorderThickness = 1
$copyButton.BorderBrush = $themeConfig[$theme].Border
$copyButton.Cursor = 'Hand'
$copyButton.VerticalAlignment = 'Center'
$copyButton.HorizontalAlignment = 'Stretch'
$copyButton.Background = $themeConfig[$theme].Panel
$copyButton.Foreground = $themeConfig[$theme].Text
$copyButton.Effect = New-Object Windows.Media.Effects.DropShadowEffect -Property @{
    ShadowDepth = 1
    Color = ([Windows.Media.Colors]::Gray)
    Opacity = 0.18
    BlurRadius = 3
}
[Windows.Controls.Grid]::SetRow($copyButton, 4)
$null = $mainGrid.Children.Add($copyButton)

# Add a new row for the status bar at the bottom
$statusRow = New-Object Windows.Controls.RowDefinition
$statusRow.Height = 'Auto'
$null = $mainGrid.RowDefinitions.Add($statusRow)

# Status bar
$statusBar = New-Object Windows.Controls.TextBlock
$statusBar.Text = "Ready"
$statusBar.FontSize = 13
$statusBar.Margin = '0,6,0,0'
$statusBar.HorizontalAlignment = 'Left'
$statusBar.VerticalAlignment = 'Bottom'
$statusBar.Foreground = $themeConfig[$theme].Text
[Windows.Controls.Grid]::SetRow($statusBar, 5)
$null = $mainGrid.Children.Add($statusBar)

# Clear Button (move to status bar row, right side)
$clearButton = New-Object Windows.Controls.Button
$clearButton.Content = "Clear"
$clearButton.MinHeight = 28
$clearButton.MinWidth = 60
$clearButton.FontSize = 14
$clearButton.Padding = '6,0,6,0'
$clearButton.Margin = '0,6,0,0'
$clearButton.BorderThickness = 1
$clearButton.BorderBrush = $themeConfig[$theme].Border
$clearButton.Cursor = 'Hand'
$clearButton.VerticalAlignment = 'Bottom'
$clearButton.HorizontalAlignment = 'Right'
$clearButton.Background = $themeConfig[$theme].Panel
$clearButton.Foreground = $themeConfig[$theme].Text
$clearButton.ToolTip = "Clear input and output boxes."
$clearButton.Effect = New-Object Windows.Media.Effects.DropShadowEffect -Property @{
    ShadowDepth = 1
    Color = ([Windows.Media.Colors]::Gray)
    Opacity = 0.18
    BlurRadius = 3
}
[Windows.Controls.Grid]::SetRow($clearButton, 5)
$null = $mainGrid.Children.Add($clearButton)

# Drag-and-drop support for text files
$inputBox.AllowDrop = $true
$inputBox.Add_Drop({
    $file = $_.Data.GetData("FileDrop")
    if ($file) { $inputBox.Text = Get-Content $file[0] -Raw }
})

# Clear button event
$clearButton.Add_Click({
    $inputBox.Text = ""
    $outputBox.Text = ""
    $statusBar.Text = "Cleared"
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(2)
    $timer.Add_Tick({
        param($sender, $e)
        $statusBar.Text = "Ready"
        $sender.Stop()
    })
    $timer.Start()
})

# Update Copy button event to show status
$copyButton.Add_Click({
    if ([string]::IsNullOrWhiteSpace($outputBox.Text)) {
        $statusBar.Text = "Nothing to copy"
        $copyButton.Content = "Copy"
        $timerStatus = New-Object System.Windows.Threading.DispatcherTimer
        $timerStatus.Interval = [TimeSpan]::FromSeconds(2)
        $timerStatus.Add_Tick({
            param($sender, $e)
            $statusBar.Text = "Ready"
            $sender.Stop()
        })
        $timerStatus.Start()
        return
    }
    try {
        if (-not [string]::IsNullOrWhiteSpace($outputBox.Text)) {
            [Windows.Clipboard]::SetText($outputBox.Text)
            $copyButton.Content = "Copied!"
            $statusBar.Text = "Copied!"
        }
    } catch {
        $copyButton.Content = "Copy Failed"
        $statusBar.Text = "Copy Failed"
    }
    $timerButton = New-Object System.Windows.Threading.DispatcherTimer
    $timerButton.Interval = [TimeSpan]::FromSeconds(0.5)
    $timerButton.Add_Tick({
        param($sender, $e)
        $copyButton.Content = "Copy"
        $sender.Stop()
    })
    $timerButton.Start()
    $timerStatus = New-Object System.Windows.Threading.DispatcherTimer
    $timerStatus.Interval = [TimeSpan]::FromSeconds(2)
    $timerStatus.Add_Tick({
        param($sender, $e)
        $statusBar.Text = "Ready"
        $sender.Stop()
    })
    $timerStatus.Start()
})

# Conversion function (multi-line support)
function Convert-Case {
    param([string]$text, [bool]$toUpper)
    if ($toUpper) {
        return $text.ToUpperInvariant()
    } else {
        return $text.ToLowerInvariant()
    }
}

# Update output function
function Update-Output {
    $outputBox.Text = Convert-Case $inputBox.Text $upperCheckBox.IsChecked
}

# Convert on input change
$inputBox.Add_TextChanged({ Update-Output })
# Convert on checkbox change
$upperCheckBox.Add_Checked({ Update-Output })
$upperCheckBox.Add_Unchecked({ Update-Output })

# Set initial theme
function Set-Theme {
    param([string]$themeName)
    $selectedTheme = $themeConfig[$themeName]

    $window.Background = $selectedTheme.Background
    $inputBox.Background = $selectedTheme.Panel
    $inputBox.Foreground = $selectedTheme.Text
    $inputBox.BorderBrush = $selectedTheme.Border
    $upperCheckBox.Foreground = $selectedTheme.Text
    $outputBox.Background = $selectedTheme.Panel
    $outputBox.Foreground = $selectedTheme.Text
    $outputBox.BorderBrush = $selectedTheme.Border
    $copyButton.Background = $selectedTheme.Panel
    $copyButton.Foreground = $selectedTheme.Text
    $clearButton.Background = $selectedTheme.Panel
    $clearButton.Foreground = $selectedTheme.Text
    $statusBar.Foreground = $selectedTheme.Text
    # Always use Light theme for settings menu and radio buttons for readability
    $settingsMenu.BorderBrush = $themeConfig.Light.Border
    $lightRadio.Foreground = $themeConfig.Light.Text
    $darkRadio.Foreground = $themeConfig.Light.Text
}

Set-Theme $theme

# Light/Dark radio button events
$lightRadio.Add_Checked({
    Set-Theme 'Light'
    $settingsItem.IsSubmenuOpen = $false # Close menu after selection
})
$darkRadio.Add_Checked({
    Set-Theme 'Dark'
    $settingsItem.IsSubmenuOpen = $false # Close menu after selection
})

# Add tooltips for accessibility
$inputBox.ToolTip = "Enter text to convert."
$upperCheckBox.ToolTip = "Toggle output between UPPERCASE and lowercase."
$outputBox.ToolTip = "Converted output."
$copyButton.ToolTip = "Copy output to clipboard."

[void]$window.ShowDialog()
