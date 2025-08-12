Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$videoExtensions = @("mkv", "mp4", "avi", "mov", "wmv", "flv", "webm")

function Remove-InvalidFileNameChars($name) {
    return ($name -replace '[<>:"/\\|?*]', '') -replace '\s+', ' '
}
function Remove-BracketTags($name) {
    return $name -replace '\[.*?\]', ''
}
function Get-InitialNumber($name) {
    if ($name -match '^(\d+)') { return [int]$matches[1] }
    return 0
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Renombrador de Series"
$form.Size = New-Object System.Drawing.Size(1100,750)
$form.MinimumSize = New-Object System.Drawing.Size(1100,750)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(245,245,245)
$form.ForeColor = [System.Drawing.Color]::FromArgb(30,30,30)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)

# Etiqueta y TextBox para carpeta
$labelFolder = New-Object System.Windows.Forms.Label
$labelFolder.Text = "Carpeta:"
$labelFolder.Location = New-Object System.Drawing.Point(10,22)
$labelFolder.AutoSize = $true
$form.Controls.Add($labelFolder)

$textFolder = New-Object System.Windows.Forms.TextBox
$textFolder.Size = New-Object System.Drawing.Size(600,28)
$textFolder.Location = New-Object System.Drawing.Point(80,18)
$textFolder.BackColor = [System.Drawing.Color]::White
$textFolder.ForeColor = [System.Drawing.Color]::FromArgb(30,30,30)
$textFolder.BorderStyle = "FixedSingle"
$textFolder.Anchor = "Top, Left, Right"
$form.Controls.Add($textFolder)

# Botón para buscar carpeta
$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Buscar..."
$btnBrowse.Location = New-Object System.Drawing.Point(690,16)
$btnBrowse.Size = New-Object System.Drawing.Size(100,30)
$btnBrowse.BackColor = [System.Drawing.Color]::FromArgb(0,122,204)
$btnBrowse.FlatStyle = "Flat"
$btnBrowse.ForeColor = [System.Drawing.Color]::White
$btnBrowse.FlatAppearance.BorderSize = 0
$btnBrowse.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnBrowse.Anchor = "Top, Right"
$btnBrowse.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $textFolder.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($btnBrowse)

# Etiqueta y TextBox para filtro
$labelFilter = New-Object System.Windows.Forms.Label
$labelFilter.Text = "Filtrar:"
$labelFilter.Location = New-Object System.Drawing.Point(800,22)
$labelFilter.AutoSize = $true
$labelFilter.Anchor = "Top, Right"
$form.Controls.Add($labelFilter)

$textFilter = New-Object System.Windows.Forms.TextBox
$textFilter.Size = New-Object System.Drawing.Size(190,28)
$textFilter.Location = New-Object System.Drawing.Point(850,18)
$textFilter.BackColor = [System.Drawing.Color]::White
$textFilter.ForeColor = [System.Drawing.Color]::FromArgb(30,30,30)
$textFilter.BorderStyle = "FixedSingle"
$textFilter.Anchor = "Top, Right"
$form.Controls.Add($textFilter)

# Etiqueta y TextBox para nombre de la serie
$labelName = New-Object System.Windows.Forms.Label
$labelName.Text = "Nombre de la serie:"
$labelName.Location = New-Object System.Drawing.Point(10,66)
$labelName.AutoSize = $true
$form.Controls.Add($labelName)

$textName = New-Object System.Windows.Forms.TextBox
$textName.Size = New-Object System.Drawing.Size(350,28)
$textName.Location = New-Object System.Drawing.Point(150,62)
$textName.BackColor = [System.Drawing.Color]::White
$textName.ForeColor = [System.Drawing.Color]::FromArgb(30,30,30)
$textName.BorderStyle = "FixedSingle"
$textName.Anchor = "Top, Left"
$form.Controls.Add($textName)

# Etiqueta y TextBox para temporada
$labelSeason = New-Object System.Windows.Forms.Label
$labelSeason.Text = "Número de temporada:"
$labelSeason.Location = New-Object System.Drawing.Point(520,66)
$labelSeason.AutoSize = $true
$form.Controls.Add($labelSeason)

$textSeason = New-Object System.Windows.Forms.TextBox
$textSeason.Size = New-Object System.Drawing.Size(50,28)
$textSeason.Location = New-Object System.Drawing.Point(670,62)
$textSeason.BackColor = [System.Drawing.Color]::White
$textSeason.ForeColor = [System.Drawing.Color]::FromArgb(30,30,30)
$textSeason.BorderStyle = "FixedSingle"
$textSeason.Anchor = "Top, Left"
$form.Controls.Add($textSeason)

# Etiqueta y ComboBox para ordenar
$labelSort = New-Object System.Windows.Forms.Label
$labelSort.Text = "Ordenar por:"
$labelSort.Location = New-Object System.Drawing.Point(740,66)
$labelSort.AutoSize = $true
$form.Controls.Add($labelSort)

$comboSort = New-Object System.Windows.Forms.ComboBox
$comboSort.Items.AddRange(@(
    "Número inicial (ascendente)",
    "Número inicial (descendente)",
    "Nombre (ascendente)",
    "Nombre (descendente)"
))
$comboSort.SelectedIndex = 0
$comboSort.Location = New-Object System.Drawing.Point(820,62)
$comboSort.Size = New-Object System.Drawing.Size(220,28)
$comboSort.DropDownStyle = "DropDownList"
$comboSort.BackColor = [System.Drawing.Color]::White
$comboSort.ForeColor = [System.Drawing.Color]::FromArgb(30,30,30)
$comboSort.Anchor = "Top, Left, Right"
$form.Controls.Add($comboSort)

# ListView para previsualizar renombrado
$listView = New-Object System.Windows.Forms.ListView
$listView.View = "Details"
$listView.FullRowSelect = $true
$listView.GridLines = $true
$listView.Location = New-Object System.Drawing.Point(10,110)
$listView.BackColor = [System.Drawing.Color]::White
$listView.ForeColor = [System.Drawing.Color]::FromArgb(30,30,30)
$listView.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$listView.Anchor = "Top, Left, Right"
$form.Controls.Add($listView)

$listView.Columns.Add("Archivo actual", 520) | Out-Null
$listView.Columns.Add("Nuevo nombre", 520) | Out-Null

# Panel y botón para renombrar
$panelButtons = New-Object System.Windows.Forms.Panel
$panelButtons.Height = 50
$panelButtons.BackColor = [System.Drawing.Color]::FromArgb(245,245,245)
$panelButtons.Anchor = "Left, Right, Bottom"
$form.Controls.Add($panelButtons)

$btnRename = New-Object System.Windows.Forms.Button
$btnRename.Text = "Renombrar archivos"
$btnRename.Size = New-Object System.Drawing.Size(160,38)
$btnRename.BackColor = [System.Drawing.Color]::FromArgb(0,122,204)
$btnRename.FlatStyle = "Flat"
$btnRename.ForeColor = [System.Drawing.Color]::White
$btnRename.FlatAppearance.BorderSize = 0
$btnRename.Cursor = [System.Windows.Forms.Cursors]::Hand
$panelButtons.Controls.Add($btnRename)

# Ajustar layout al cambiar tamaño
function AdjustLayout {
    $margin = 10
    $listView.Top = 110
    $listView.Left = 10
    $listView.Width = $form.ClientSize.Width - 20
    $listView.Height = $form.ClientSize.Height - $panelButtons.Height - 110 - $margin

    $panelButtons.Top = $listView.Bottom + $margin
    $panelButtons.Left = 10
    $panelButtons.Width = $form.ClientSize.Width - 20
    $panelButtons.Height = 50

    $btnRename.Location = New-Object System.Drawing.Point(
        [math]::Round(($panelButtons.Width - $btnRename.Width) / 2), 6)

    $totalColWidth = $listView.ClientSize.Width - 4
    $col1Width = [math]::Round($totalColWidth / 2)
    $col2Width = $totalColWidth - $col1Width
    $listView.Columns[0].Width = $col1Width
    $listView.Columns[1].Width = $col2Width
}
$form.Add_Resize({ AdjustLayout })
AdjustLayout

# Función para actualizar lista automáticamente
function Invoke-Preview {
    $listView.Items.Clear()
    $folderPath = $textFolder.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($folderPath) -or -not (Test-Path $folderPath)) {
        return
    }

    $seriesName = Remove-InvalidFileNameChars $textName.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($seriesName)) {
        return
    }
    $seasonNumber = $textSeason.Text.Trim()
    if (-not [int]::TryParse($seasonNumber, [ref]0)) {
        $seasonNumber = "01"
    }
    $seasonNumber = "{0:D2}" -f [int]$seasonNumber

    $filterText = $textFilter.Text.ToLower()

    $files = Get-ChildItem -LiteralPath $folderPath -File | Where-Object {
        $ext = $_.Extension.TrimStart('.').ToLower()
        ($videoExtensions -contains $ext) -and
        ([string]::IsNullOrWhiteSpace($filterText) -or $_.Name.ToLower().Contains($filterText))
    }

    switch ($comboSort.SelectedIndex) {
        0 { $files = $files | Sort-Object @{Expression={ Get-InitialNumber $_.BaseName }}, Ascending }
        1 { $files = $files | Sort-Object @{Expression={ Get-InitialNumber $_.BaseName }}, Descending }
        2 { $files = $files | Sort-Object BaseName }
        3 { $files = $files | Sort-Object BaseName -Descending }
    }

    $counter = 1
    foreach ($file in $files) {
        $oldName = $file.Name
        $baseName = Remove-BracketTags $file.BaseName
        $ext = $file.Extension
        $episodePadded = "{0:D2}" -f $counter
        $newBaseName = "$seriesName S$seasonNumber`E$episodePadded"
        $newName = $newBaseName + $ext

        $item = New-Object System.Windows.Forms.ListViewItem($oldName)
        $item.SubItems.Add($newName) | Out-Null
        $listView.Items.Add($item) | Out-Null
        $counter++
    }
}

# Conectar eventos para actualizar lista
$textFolder.Add_TextChanged({ Invoke-Preview })
$textName.Add_TextChanged({ Invoke-Preview })
$textSeason.Add_TextChanged({ Invoke-Preview })
$textFilter.Add_TextChanged({ Invoke-Preview })
$comboSort.Add_SelectedIndexChanged({ Invoke-Preview })
$btnBrowse.Add_Click({
    Invoke-Preview
})

# Evento botón renombrar
$btnRename.Add_Click({
    if ($listView.Items.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No hay archivos para renombrar.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $result = [System.Windows.Forms.MessageBox]::Show("¿Estás seguro que quieres renombrar los archivos según la lista?", "Confirmar renombrado", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    $folderPath = $textFolder.Text.Trim()
    foreach ($item in $listView.Items) {
        $oldName = $item.SubItems[0].Text
        $newName = $item.SubItems[1].Text
        $oldPath = Join-Path -Path $folderPath -ChildPath $oldName
        $newPath = Join-Path -Path $folderPath -ChildPath $newName

        if (Test-Path $newPath) {
            [System.Windows.Forms.MessageBox]::Show("El archivo destino ya existe: $newName", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            continue
        }

        try {
            Rename-Item -LiteralPath $oldPath -NewName $newName -ErrorAction Stop
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error renombrando $oldName`n$($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }

    [System.Windows.Forms.MessageBox]::Show("Renombrado completado.", "Información", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Invoke-Preview
})

# Mostrar formulario
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
$form.ShowDialog()
