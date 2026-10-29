Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class DarkWindowTitle {
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    public static extern int SetCurrentProcessExplicitAppUserModelID(string id);
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attribute, ref int value, int size);
}
'@
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
public class AnimatedSwitch : Control {
    bool state; float pos; Timer timer = new Timer();
    public bool Checked { get { return state; } set { if (state != value) { state = value; timer.Start(); } } }
    public AnimatedSwitch() { DoubleBuffered = true; Size = new Size(50, 26); Cursor = Cursors.Hand; timer.Interval = 15; timer.Tick += (s,e) => { float target = state ? 1 : 0; pos += (target-pos)*0.3f; if (Math.Abs(target-pos)<0.02f) { pos=target; timer.Stop(); } Invalidate(); }; }
    protected override void OnClick(EventArgs e) { base.OnClick(e); }
    protected override void OnPaint(PaintEventArgs e) { base.OnPaint(e); e.Graphics.SmoothingMode = SmoothingMode.AntiAlias; int h=Height-2, w=Width-2; using (var path = new GraphicsPath()) { path.AddArc(1,1,h,h,90,180); path.AddArc(w-h+1,1,h,h,270,180); path.CloseFigure(); using(var b = new SolidBrush(state ? Color.FromArgb(0,203,199) : Color.FromArgb(85,94,108))) e.Graphics.FillPath(b,path); } float d=h-6; using(var b = new SolidBrush(Color.White)) e.Graphics.FillEllipse(b,4+pos*(w-h),4,d,d); }
    protected override void Dispose(bool disposing) { if (disposing) timer.Dispose(); base.Dispose(disposing); }
}
'@
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
public class ModernButton : Control {
 public bool Accent {get;set;}
 public ModernButton() { SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer, true); Cursor = Cursors.Hand; TabStop = true; AccessibleRole = AccessibleRole.PushButton; }
 protected override void OnResize(EventArgs e) { base.OnResize(e); if (Width<21 || Height<21) return; int r=10,w=Width,h=Height; using(var p=new GraphicsPath()){p.AddArc(0,0,r*2,r*2,180,90);p.AddArc(w-r*2,0,r*2,r*2,270,90);p.AddArc(w-r*2,h-r*2,r*2,r*2,0,90);p.AddArc(0,h-r*2,r*2,r*2,90,90);p.CloseFigure();Region=new Region(p);} }
 protected override void OnPaintBackground(PaintEventArgs e) { e.Graphics.Clear(Parent != null ? Parent.BackColor : SystemColors.Control); }
 protected override void OnPaint(PaintEventArgs e) { e.Graphics.SmoothingMode = SmoothingMode.AntiAlias; int r=10,w=Width-1,h=Height-1; using(var p=new GraphicsPath()) { p.AddArc(0,0,r*2,r*2,180,90); p.AddArc(w-r*2,0,r*2,r*2,270,90); p.AddArc(w-r*2,h-r*2,r*2,r*2,0,90); p.AddArc(0,h-r*2,r*2,r*2,90,90); p.CloseFigure(); if (Accent) { using(var b=new LinearGradientBrush(ClientRectangle, Color.FromArgb(58,130,238), Color.FromArgb(116,90,220), 0f)) e.Graphics.FillPath(b,p); } else { using(var b=new SolidBrush(BackColor)) e.Graphics.FillPath(b,p); } } TextRenderer.DrawText(e.Graphics,Text,Font,ClientRectangle,ForeColor,TextFormatFlags.HorizontalCenter|TextFormatFlags.VerticalCenter|TextFormatFlags.EndEllipsis); }
}
public class LineIcon : Control {
 public string Kind {get;set;}
 public LineIcon() { DoubleBuffered=true; Cursor=Cursors.Hand; Size=new Size(34,34); }
 protected override void OnPaint(PaintEventArgs e) { base.OnPaint(e); var g=e.Graphics; g.SmoothingMode=SmoothingMode.AntiAlias; using(var pen=new Pen(ForeColor,1.8f)) { pen.StartCap=pen.EndCap=LineCap.Round; float cx=Width/2f,cy=Height/2f;
  if (Kind=="sun") { g.DrawEllipse(pen,cx-4.5f,cy-4.5f,9,9); for(int i=0;i<8;i++){ double a=i*Math.PI/4; g.DrawLine(pen,cx+(float)Math.Cos(a)*7.5f,cy+(float)Math.Sin(a)*7.5f,cx+(float)Math.Cos(a)*10,cy+(float)Math.Sin(a)*10); } }
  else if (Kind=="moon") { using(var path=new GraphicsPath()){ path.AddBezier(cx+3,cy-9,cx-11,cy-9,cx-11,cy+9,cx+3,cy+9); path.AddBezier(cx+3,cy+9,cx-2,cy+7,cx-3,cy-5,cx+3,cy-9); path.CloseFigure(); g.DrawPath(pen,path); } }
  else { g.DrawEllipse(pen,cx-6,cy-6,12,12); g.DrawEllipse(pen,cx-2,cy-2,4,4); for(int i=0;i<8;i++){ double a=i*Math.PI/4; g.DrawLine(pen,cx+(float)Math.Cos(a)*7,cy+(float)Math.Sin(a)*7,cx+(float)Math.Cos(a)*9,cy+(float)Math.Sin(a)*9); } }
 } }
}
'@
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
public class GameRows : ListView {
 public int VisibleRowWidth { get; set; }
 public System.Collections.Generic.Dictionary<string, Image> GameIcons = new System.Collections.Generic.Dictionary<string, Image>(StringComparer.OrdinalIgnoreCase);
 public GameRows() { OwnerDraw=true; DoubleBuffered=true; }
 protected override void WndProc(ref Message m) { if (m.Msg == 0x020A && Items.Count > 0) { int delta = (short)(((long)m.WParam >> 16) & 0xffff); int top = TopItem == null ? 0 : TopItem.Index; int visible = Math.Max(1, ClientSize.Height / 52); int next = Math.Max(0, Math.Min(top + (delta < 0 ? 1 : -1), Math.Max(0, Items.Count - visible))); TopItem = Items[next]; OnMouseWheel(new MouseEventArgs(MouseButtons.None, 0, 0, 0, delta)); Invalidate(); return; } base.WndProc(ref m); }
 protected override void OnDrawColumnHeader(DrawListViewColumnHeaderEventArgs e) { }
 protected override void OnDrawSubItem(DrawListViewSubItemEventArgs e) { }
 protected override void OnDrawItem(DrawListViewItemEventArgs e) {
   var g=e.Graphics; g.SmoothingMode=SmoothingMode.AntiAlias; var b=new Rectangle(0,e.Bounds.Y,Math.Max(20,VisibleRowWidth),e.Bounds.Height);
   using(var fill=new SolidBrush(BackColor)) g.FillRectangle(fill,b);
   if(e.Item.Selected) { var c=BackColor.GetBrightness()>0.5f ? Color.FromArgb(226,236,251) : Color.FromArgb(32,59,92); using(var path=new GraphicsPath()){ int d=14,x=b.X+1,y=b.Y+2,w=b.Width-3,h=b.Height-4; path.AddArc(x,y,d,d,180,90); path.AddArc(x+w-d,y,d,d,270,90); path.AddArc(x+w-d,y+h-d,d,d,0,90); path.AddArc(x,y+h-d,d,d,90,90); path.CloseFigure(); using(var fill=new SolidBrush(c)) g.FillPath(fill,path); using(var border=new Pen(Color.FromArgb(72,139,222),1.3f)) g.DrawPath(border,path); } }
   Image img; if(e.Item.Tag is string && GameIcons.TryGetValue((string)e.Item.Tag, out img)) { float x=b.X+4, y=b.Y+(b.Height-44)/2f; using(var bmp=new Bitmap(44,44)) { using(var ig=Graphics.FromImage(bmp)) { ig.InterpolationMode=InterpolationMode.HighQualityBicubic; ig.DrawImage(img,0,0,44,44); } using(var clip=new GraphicsPath()) { float d=14; clip.AddArc(x,y,d,d,180,90); clip.AddArc(x+44-d,y,d,d,270,90); clip.AddArc(x+44-d,y+44-d,d,d,0,90); clip.AddArc(x,y+44-d,d,d,90,90); clip.CloseFigure(); using(var texture=new TextureBrush(bmp,WrapMode.Clamp)) { texture.TranslateTransform(x,y); g.FillPath(texture,clip); } } } }
   using(var title=new Font("Segoe UI Semibold",10.5f)) using(var sub=new Font("Segoe UI",8.5f)) {
    TextRenderer.DrawText(g,e.Item.Text,title,new Rectangle(b.X+62,b.Y+5,Math.Max(1,b.Width-120),23),ForeColor,TextFormatFlags.EndEllipsis | TextFormatFlags.VerticalCenter);
    TextRenderer.DrawText(g,"Added to watch list",sub,new Rectangle(b.X+62,b.Y+27,Math.Max(1,b.Width-120),18),Color.FromArgb(130,153,186),TextFormatFlags.EndEllipsis | TextFormatFlags.VerticalCenter);
   }

 }
}
public class StatusBadge : Control {
 bool value; public bool Checked { get { return value; } set { this.value=value; Invalidate(); } }
 public StatusBadge() { DoubleBuffered=true; Cursor=Cursors.Hand; Size=new Size(92,34); }
 protected override void OnPaint(PaintEventArgs e) { var g=e.Graphics; g.SmoothingMode=SmoothingMode.AntiAlias; var color=value?Color.FromArgb(0,221,183):Color.FromArgb(140,157,180); using(var path=new GraphicsPath()) { int d=Height-2; path.AddArc(1,1,d,d,90,180); path.AddArc(Width-d-1,1,d,d,270,180); path.CloseFigure(); using(var pen=new Pen(color,1.4f)) g.DrawPath(pen,path); } using(var b=new SolidBrush(color)) g.FillEllipse(b,12,Height/2-6,12,12); TextRenderer.DrawText(g,value?"Active":"Off",Font,new Rectangle(28,0,Width-31,Height),color,TextFormatFlags.HorizontalCenter|TextFormatFlags.VerticalCenter); }
}
public class PulseLine : Control {
 public PulseLine(){DoubleBuffered=true; Size=new Size(105,38);}
 protected override void OnPaint(PaintEventArgs e){var g=e.Graphics;g.SmoothingMode=SmoothingMode.AntiAlias; using(var p=new Pen(Color.FromArgb(0,145,190),1.6f)) using(var path=new GraphicsPath()){float y=Height/2f;path.AddBezier(0,y,20,y,25,y,30,y+4);path.AddBezier(30,y+4,42,y+15,43,y+16,49,y-9);path.AddBezier(49,y-9,55,y-25,60,y+8,67,y);path.AddBezier(67,y,72,y-3,76,y,Width,y);g.DrawPath(p,path);}}
}
'@
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;
public class GameMenuRenderer : ToolStripProfessionalRenderer {
 protected override void OnRenderToolStripBorder(ToolStripRenderEventArgs e) { var g=e.Graphics; g.SmoothingMode=SmoothingMode.AntiAlias; int w=e.ToolStrip.Width-1,h=e.ToolStrip.Height-1,d=18; using(var path=new GraphicsPath()){path.AddArc(0,0,d,d,180,90);path.AddArc(w-d,0,d,d,270,90);path.AddArc(w-d,h-d,d,d,0,90);path.AddArc(0,h-d,d,d,90,90);path.CloseFigure();using(var pen=new Pen(e.ToolStrip.BackColor.GetBrightness()>0.5f ? Color.FromArgb(198,211,226) : Color.FromArgb(77,100,135)))g.DrawPath(pen,path);} }
 protected override void OnRenderMenuItemBackground(ToolStripItemRenderEventArgs e) {
  if (!e.Item.Selected) return;
  var g=e.Graphics; g.SmoothingMode=SmoothingMode.AntiAlias; int x=4,y=3,w=e.Item.Width-8,h=e.Item.Height-6,d=14;
  using(var path=new GraphicsPath()){ path.AddArc(x,y,d,d,180,90); path.AddArc(x+w-d,y,d,d,270,90); path.AddArc(x+w-d,y+h-d,d,d,0,90); path.AddArc(x,y+h-d,d,d,90,90); path.CloseFigure(); using(var brush=new SolidBrush(e.ToolStrip.BackColor.GetBrightness()>0.5f ? Color.FromArgb(230,237,246) : Color.FromArgb(46,66,96))) g.FillPath(brush,path); }
 }
}
'@
Add-Type -ReferencedAssemblies System.Windows.Forms,System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public static class NativeGameScroll { [DllImport("user32.dll")] public static extern bool ShowScrollBar(IntPtr hWnd, int wBar, bool bShow); }
public class SlimScroll : Control {
 int total,shown,value; bool dragging; int offset;
 public event EventHandler ValueChanged;
 public int Total { get {return total;} set {total=Math.Max(0,value); this.value=Math.Min(this.value,Math.Max(0,total-shown)); Invalidate();} }
 public int Shown { get {return shown;} set {shown=Math.Max(1,value); this.value=Math.Min(this.value,Math.Max(0,total-shown)); Invalidate();} }
 public int Value { get{return value;} set{int v=Math.Max(0,Math.Min(value,Math.Max(0,total-shown))); if(this.value!=v){this.value=v; Invalidate(); if(ValueChanged!=null) ValueChanged(this,EventArgs.Empty);}} }
 public Color Track {get;set;} public Color Thumb {get;set;}
 public SlimScroll(){DoubleBuffered=true; Width=12; Track=Color.FromArgb(19,35,56); Thumb=Color.FromArgb(88,114,149);}
 int ThumbHeight {get{return total<=0?Height:Math.Max(25,(int)((float)Height*Math.Min(total,shown)/total));}}
 int ThumbY {get {int max=Math.Max(0,total-shown),range=Math.Max(0,Height-ThumbHeight);return max==0?0:(int)((float)value*range/max);}}
 protected override void OnPaint(PaintEventArgs e){base.OnPaint(e);var g=e.Graphics;g.SmoothingMode=SmoothingMode.AntiAlias;using(var brush=new SolidBrush(Track))g.FillRectangle(brush,0,0,Width,Height); if(total<=shown)return; int h=ThumbHeight;using(var p=new GraphicsPath()){int x=3,y=ThumbY,d=6;p.AddArc(x,y,d,d,180,180);p.AddArc(x,y+h-d,d,d,0,180);p.CloseFigure();using(var brush=new SolidBrush(Thumb))g.FillPath(brush,p);}}
 protected override void OnMouseDown(MouseEventArgs e){base.OnMouseDown(e); if(total<=shown)return; int y=ThumbY,h=ThumbHeight;if(e.Y>=y && e.Y<y+h){dragging=true;offset=e.Y-y;Capture=true;}else{Value += e.Y<y ? -shown : shown;}}
 protected override void OnMouseMove(MouseEventArgs e){base.OnMouseMove(e);if(!dragging)return; int range=Height-ThumbHeight; if(range>0)Value=(int)Math.Round((double)(e.Y-offset)*(total-shown)/range);}
 protected override void OnMouseUp(MouseEventArgs e){base.OnMouseUp(e);dragging=false;Capture=false;}
}
'@
$created = $false
$mutex = New-Object System.Threading.Mutex($true, 'Local\NexusGameWatcher', [ref]$created)
if (-not $created) { [System.Windows.Forms.MessageBox]::Show('The app is already running. Open it from the system tray.') | Out-Null; exit }
$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$dataDirectory = Join-Path $env:LOCALAPPDATA 'NexusGuard'
New-Item -ItemType Directory -Path $dataDirectory -Force | Out-Null
$applicationPath = $env:NEXUS_GUARD_APP_PATH
if (-not $applicationPath) { $applicationPath = Join-Path $base 'Nexus Guard.exe' }
$configPath = Join-Path $dataDirectory 'games.txt'
if (-not (Test-Path -LiteralPath $configPath)) { Set-Content -LiteralPath $configPath -Value 'cs2.exe' -Encoding UTF8 }
$launcher = Join-Path $base 'Start-Hidden.vbs'
$startupLink = Join-Path ([Environment]::GetFolderPath('Startup')) 'Nexus Guard.lnk'
$nexusPath = Join-Path $env:ProgramFiles 'Nexus\Nexus.exe'
try {
 $registryKeys = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
 $installed = Get-ItemProperty $registryKeys -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match '^Nexus( version)?( |$)' -and $_.InstallLocation } | Select-Object -First 1
 if ($installed) { $candidateNexus = Join-Path $installed.InstallLocation 'Nexus.exe'; if (Test-Path -LiteralPath $candidateNexus) { $nexusPath = $candidateNexus } }
} catch { }
function Stop-Nexus {
    $service = Get-Service -Name 'NexusService' -ErrorAction SilentlyContinue
    if ($service -and $service.Status -ne 'Stopped') { Stop-Service -Name 'NexusService' -ErrorAction Stop; $service.WaitForStatus('Stopped', [TimeSpan]::FromSeconds(10)) }
    $installDir = [IO.Path]::GetDirectoryName($nexusPath).TrimEnd('\') + '\'
    foreach ($process in @(Get-CimInstance Win32_Process -ErrorAction Stop | Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($installDir, [StringComparison]::OrdinalIgnoreCase) })) { & taskkill.exe /F /PID $process.ProcessId 2>$null | Out-Null }
}
function Start-Nexus {
    $service = Get-Service -Name 'NexusService' -ErrorAction SilentlyContinue
    if ($service) { if ($service.Status -ne 'Running') { Start-Service -Name 'NexusService' -ErrorAction Stop } }
    else { Start-Process -FilePath $nexusPath -WindowStyle Minimized }
}
$script:pausedNexus = $false
$script:quitting = $false
$script:monitoring = $true
$settingsPath = Join-Path $dataDirectory 'settings.json'
$script:settings = @{ MinimizeToTray = $true; CloseToTray = $true; StartHidden = $false; Dark = $true; PollSeconds = 3 }
try { if (Test-Path $settingsPath) { $saved = Get-Content -Raw $settingsPath | ConvertFrom-Json; foreach ($key in @($script:settings.Keys)) { if ($null -ne $saved.$key) { $script:settings[$key] = $saved.$key } } } } catch { }
function Save-Settings { $script:settings | ConvertTo-Json | Set-Content -LiteralPath $settingsPath -Encoding UTF8 }
$resumeMarker = Join-Path $dataDirectory 'resume-nexus.tmp'
if (Test-Path $resumeMarker) { $script:pausedNexus = $true; Remove-Item $resumeMarker -ErrorAction SilentlyContinue }
[void][DarkWindowTitle]::SetCurrentProcessExplicitAppUserModelID('NexusGameWatcher.Desktop.App')
$form = New-Object Windows.Forms.Form
$form.ShowInTaskbar = $true
$form.Text = 'Nexus Guard'
$form.Size = New-Object Drawing.Size(760, 626)
$form.MinimumSize = New-Object Drawing.Size(700, 586)
$form.StartPosition = 'CenterScreen'
$form.Add_HandleCreated({
    $dark = 1
    $result = [DarkWindowTitle]::DwmSetWindowAttribute($form.Handle, 20, [ref]$dark, 4)
    if ($result -ne 0) { [void][DarkWindowTitle]::DwmSetWindowAttribute($form.Handle, 19, [ref]$dark, 4) }
})
$form.BackColor = [Drawing.Color]::FromArgb(5, 15, 32)
$form.Font = New-Object Drawing.Font('Segoe UI', 10.5)
$form.Icon = New-Object Drawing.Icon (Join-Path $base 'Nexus-Watcher.ico')
$form.ForeColor = [Drawing.Color]::FromArgb(235, 238, 245)
$brand = New-Object Windows.Forms.Label
$brand.Text = 'NEXUS GUARD'; $brand.Font = New-Object Drawing.Font('Segoe UI Semibold', 9); $brand.ForeColor = [Drawing.Color]::FromArgb(0, 228, 228); $brand.Location = New-Object Drawing.Point(26, 22); $brand.AutoSize = $true
$title = New-Object Windows.Forms.Label
$title.Text = 'Game monitoring'; $title.Font = New-Object Drawing.Font('Segoe UI Semibold', 22); $title.Location = New-Object Drawing.Point(24, 51); $title.AutoSize = $true
$subtitle = New-Object Windows.Forms.Label
$subtitle.Text = 'Nexus pauses while a listed game is running.'; $subtitle.ForeColor = [Drawing.Color]::FromArgb(157, 170, 188); $subtitle.Location = New-Object Drawing.Point(28, 100); $subtitle.AutoSize = $true
$label = New-Object Windows.Forms.Label
$label.Text = 'YOUR GAMES'; $label.Font = New-Object Drawing.Font('Segoe UI Semibold', 9); $label.ForeColor = [Drawing.Color]::FromArgb(157, 170, 188); $label.Location = New-Object Drawing.Point(30, 258); $label.AutoSize = $true
$list = New-Object GameRows
$list.Location = New-Object Drawing.Point(12, 10); $list.Size = New-Object Drawing.Size(652, 118); $list.Anchor = 'Top,Bottom,Left,Right'; $list.View = 'Details'; $list.HeaderStyle = 'None'; $list.FullRowSelect = $true; $list.MultiSelect = $true; $list.HideSelection = $false; $list.Add_SelectedIndexChanged({ $list.Invalidate() })
[void]$list.Columns.Add('Game', 650)
$list.Add_Resize({ if ($list.Columns.Count -gt 0 -and $gamePanel) { $list.Columns[0].Width = [Math]::Max(1, $gamePanel.ClientSize.Width - 32); $list.Invalidate() } })
$list.Columns[0].Width = [Math]::Max(1, $gamePanel.ClientSize.Width - 32)
$gameIcons = New-Object Windows.Forms.ImageList; $gameIcons.ImageSize = New-Object Drawing.Size(52,52); $gameIcons.ColorDepth = 'Depth32Bit'; $list.SmallImageList = $gameIcons
function Add-GameItem([string]$path) {
 if (@($list.Items | Where-Object { $_.Tag -eq $path -or ((-not [IO.Path]::IsPathRooted([string]$_.Tag)) -and [IO.Path]::GetFileName([string]$_.Tag) -ieq [IO.Path]::GetFileName($path)) }).Count) { return }
 $resolved = $path
 if ($path -ieq 'cs2.exe') {
  $live = Get-Process -Name cs2 -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($live -and $live.Path) { $resolved = $live.Path }
  else { try { $steamRoot = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath; $libraries = @($steamRoot); $vdf = Join-Path $steamRoot 'steamapps\libraryfolders.vdf'; if (Test-Path $vdf) { foreach ($line in Get-Content $vdf) { if ($line -match '"path"\s+"([^"]+)"') { $libraries += $matches[1].Replace('\\','\') } } }; foreach ($root in $libraries) { if ($root) { $candidate = Join-Path $root 'steamapps\common\Counter-Strike Global Offensive\game\bin\win64\cs2.exe'; if (Test-Path $candidate) { $resolved = $candidate; break } } } } catch { } }
 }
 $filename = [IO.Path]::GetFileNameWithoutExtension($path)
 $display = $filename
 if ($filename -ieq 'cs2') { $display = 'Counter-Strike 2' }
 elseif (Test-Path -LiteralPath $resolved) { try { $v = (Get-Item -LiteralPath $resolved).VersionInfo; if ($v.ProductName -and $v.ProductName -notmatch '^(Unity|Unreal Engine|BootstrapPackagedGame)$') { $display = $v.ProductName } elseif ($v.FileDescription -and $v.FileDescription -notmatch '^(Unity|Unreal Engine|BootstrapPackagedGame)$') { $display = $v.FileDescription } } catch { } }
 $key = 'game' + $gameIcons.Images.Count
 try { if (Test-Path -LiteralPath $resolved) { $ico = [Drawing.Icon]::ExtractAssociatedIcon($resolved); if ($ico) { $gameIcons.Images.Add($key, $ico); $list.GameIcons[$path] = $ico.ToBitmap() } } } catch { }
 $item = New-Object Windows.Forms.ListViewItem($display); $item.Tag = $path; $item.ToolTipText = $path
 if ($gameIcons.Images.ContainsKey($key)) { $item.ImageKey = $key }
 [void]$list.Items.Add($item)
}
$scrollBar = New-Object SlimScroll
$scrollBar.Location = New-Object Drawing.Point(664,10); $scrollBar.Size = New-Object Drawing.Size(12,118); $scrollBar.Anchor = 'Top,Bottom,Right'; $scrollBar.Visible = $false
function Update-GameScroll {
 if (-not $list.IsHandleCreated) { return }
 $scrollBar.Total = $list.Items.Count; $scrollBar.Shown = [Math]::Max(1,[Math]::Floor($list.ClientSize.Height / 52)); $scrollBar.Visible = $scrollBar.Total -gt $scrollBar.Shown
 if ($list.TopItem) { $scrollBar.Value = $list.TopItem.Index }
 [void][NativeGameScroll]::ShowScrollBar($list.Handle, 0, $false)
}
$scrollBar.Add_ValueChanged({ if ($list.Items.Count -gt $scrollBar.Value) { $list.TopItem = $list.Items[$scrollBar.Value]; $list.Invalidate(); [void][NativeGameScroll]::ShowScrollBar($list.Handle,0,$false) } })
$list.Add_HandleCreated({ Update-GameScroll }); $list.Add_Resize({ Update-GameScroll }); $list.Add_MouseWheel({ $list.BeginInvoke([Action]{ Update-GameScroll }) | Out-Null })
$gamePanel = New-Object Windows.Forms.Panel
$gamePanel.Location = New-Object Drawing.Point(28, 286); $gamePanel.Size = New-Object Drawing.Size(688, 138); $gamePanel.Anchor = 'Top,Bottom,Left,Right'; $gamePanel.BackColor = [Drawing.Color]::FromArgb(15,32,56); $gamePanel.Controls.Add($list); $gamePanel.Controls.Add($scrollBar); $scrollBar.BringToFront()
$list.Anchor = 'Top,Bottom,Left'; $list.VisibleRowWidth = [Math]::Max(20, $gamePanel.ClientSize.Width - 38); $list.Width = $gamePanel.ClientSize.Width + 24; $gamePanel.Add_Resize({ $list.VisibleRowWidth = [Math]::Max(20, $gamePanel.ClientSize.Width - 38); $list.Width = $gamePanel.ClientSize.Width + 24; $list.Invalidate(); Update-GameScroll })
$list.ShowItemToolTips = $true
if (Test-Path $configPath) { Get-Content $configPath | ForEach-Object { $line = $_.Trim(); if ($line -and -not $line.StartsWith('#')) { Add-GameItem $line } } }
function Save-Games { $values = @($list.Items | ForEach-Object { [string]$_.Tag }); if ($values.Count -eq 0) { Set-Content -LiteralPath $configPath -Value '' -Encoding UTF8 } else { Set-Content -LiteralPath $configPath -Value $values -Encoding UTF8 } }
$add = New-Object ModernButton
$add.Accent = $true
$add.Text = '+  Add a game'; $add.Location = New-Object Drawing.Point(28, 438); $add.Size = New-Object Drawing.Size(170, 42); $add.Anchor = 'Bottom,Left'
function Resolve-GameFile([string]$path) {
 $extension = [IO.Path]::GetExtension($path).ToLowerInvariant()
 if ($extension -eq '.lnk') {
  $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($path)
  $target = [Environment]::ExpandEnvironmentVariables($shortcut.TargetPath)
  if ([IO.Path]::GetExtension($target) -ine '.exe' -or -not (Test-Path -LiteralPath $target -PathType Leaf)) { throw 'This shortcut does not point directly to an available .exe file.' }
  return $target
 }
 if ($extension -eq '.url') {
  $urlLine = Get-Content -LiteralPath $path | Where-Object { $_ -match '^URL=' } | Select-Object -First 1
  if (-not $urlLine) { throw 'This shortcut has no executable destination.' }
  $uri = $null; if (-not [Uri]::TryCreate($urlLine.Substring(4), [UriKind]::Absolute, [ref]$uri) -or -not $uri.IsFile) { throw 'This Internet or game-launcher shortcut does not contain the game executable. Select the game .exe instead.' }
  $target = $uri.LocalPath
  if ([IO.Path]::GetExtension($target) -ine '.exe' -or -not (Test-Path -LiteralPath $target -PathType Leaf)) { throw 'This shortcut does not point to an available .exe file.' }
  return $target
 }
 if ($extension -ne '.exe' -or -not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'Select an existing .exe file or a shortcut to one.' }
 return $path
}
$add.Add_Click({
 $dialog = New-Object Windows.Forms.OpenFileDialog
 $dialog.Filter = 'Games and shortcuts (*.exe;*.lnk;*.url)|*.exe;*.lnk;*.url|Programs (*.exe)|*.exe|Shortcuts (*.lnk;*.url)|*.lnk;*.url'; $dialog.Multiselect = $true; $dialog.DereferenceLinks = $false
 if ($dialog.ShowDialog() -eq 'OK') {
  $errors = New-Object 'System.Collections.Generic.List[string]'
  foreach ($file in $dialog.FileNames) { try { $target = Resolve-GameFile $file; Add-GameItem $target } catch { $errors.Add(([IO.Path]::GetFileName($file) + ': ' + $_.Exception.Message)) } }
  Save-Games; Update-GameScroll
  if ($errors.Count) { [Windows.Forms.MessageBox]::Show($form, ($errors -join "`r`n`r`n"), 'Some files could not be added', [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information) | Out-Null }
 }
 $dialog.Dispose()
})
$remove = New-Object ModernButton
$remove.Text = 'Remove selected'; $remove.Location = New-Object Drawing.Point(210, 438); $remove.Size = New-Object Drawing.Size(170, 42); $remove.Anchor = 'Bottom,Left'
function Confirm-RemoveGames($selected) {
 $rowsShown = [Math]::Min(4, [Math]::Max(1, $selected.Count)); $rowsHeight = 58 * $rowsShown
 $dialog = New-Object Windows.Forms.Form; $dialog.Text = 'Remove games'; $dialog.ClientSize = New-Object Drawing.Size(440, (175 + $rowsHeight)); $dialog.StartPosition = 'CenterParent'; $dialog.FormBorderStyle = 'FixedDialog'; $dialog.MinimizeBox = $false; $dialog.MaximizeBox = $false; $dialog.ShowInTaskbar = $false; $dialog.Font = New-Object Drawing.Font('Segoe UI', 10); $dialog.Icon = $form.Icon
 $darkMode = [bool]$themeSwitch.Checked
 if ($darkMode) { $dialog.BackColor = [Drawing.Color]::FromArgb(5,15,32); $dialog.ForeColor = [Drawing.Color]::FromArgb(235,241,250); $surface = [Drawing.Color]::FromArgb(15,32,56); $muted = [Drawing.Color]::FromArgb(145,165,195) }
 else { $dialog.BackColor = [Drawing.Color]::FromArgb(246,248,251); $dialog.ForeColor = [Drawing.Color]::FromArgb(27,39,54); $surface = [Drawing.Color]::White; $muted = [Drawing.Color]::FromArgb(82,100,120) }
 $dialog.Add_HandleCreated({ $v = if ($darkMode) { 1 } else { 0 }; [void][DarkWindowTitle]::DwmSetWindowAttribute($dialog.Handle,20,[ref]$v,4) })
 $heading = New-Object Windows.Forms.Label; $heading.Text = if ($selected.Count -eq 1) { 'Remove game?' } else { 'Remove games?' }; $heading.Font = New-Object Drawing.Font('Segoe UI Semibold',16); $heading.AutoSize = $true; $heading.Location = New-Object Drawing.Point(24,19)
 $desc = New-Object Windows.Forms.Label; $desc.Text = 'Nexus Guard will stop watching:'; $desc.ForeColor = $muted; $desc.AutoSize = $true; $desc.Location = New-Object Drawing.Point(27,55)
 $rows = New-Object Windows.Forms.FlowLayoutPanel; $rows.Location = New-Object Drawing.Point(25,88); $rows.Size = New-Object Drawing.Size(390,$rowsHeight); $rows.FlowDirection = 'TopDown'; $rows.WrapContents = $false; $rows.AutoScroll = $true
 foreach ($item in $selected) {
  $row = New-Object Windows.Forms.Panel; $row.Size = New-Object Drawing.Size(374,54); $row.Margin = New-Object Windows.Forms.Padding(0,0,0,4); $row.BackColor = $surface; Set-Rounded $row 9
  $image = New-Object Windows.Forms.PictureBox; $image.Location = New-Object Drawing.Point(12,9); $image.Size = New-Object Drawing.Size(36,36); $image.SizeMode = 'Zoom'; if ($list.GameIcons.ContainsKey([string]$item.Tag)) { $image.Image = $list.GameIcons[[string]$item.Tag] }
  $name = New-Object Windows.Forms.Label; $name.Text = $item.Text; $name.Font = New-Object Drawing.Font('Segoe UI Semibold',10); $name.ForeColor = $dialog.ForeColor; $name.Location = New-Object Drawing.Point(60,16); $name.Size = New-Object Drawing.Size(295,24); $name.AutoEllipsis = $true
  $row.Controls.AddRange(@($image,$name)); $rows.Controls.Add($row)
 }
 $btnY = 112 + $rowsHeight
 $cancel = New-Object ModernButton; $cancel.Text = 'Cancel'; $cancel.Location = New-Object Drawing.Point(182,$btnY); $cancel.Size = New-Object Drawing.Size(108,40); $cancel.BackColor = $surface; $cancel.ForeColor = $dialog.ForeColor; $cancel.Add_Click({ $dialog.DialogResult = [Windows.Forms.DialogResult]::Cancel; $dialog.Close() })
 $confirm = New-Object ModernButton; $confirm.Text = 'Remove'; $confirm.Location = New-Object Drawing.Point(302,$btnY); $confirm.Size = New-Object Drawing.Size(112,40); $confirm.BackColor = [Drawing.Color]::FromArgb(177,63,77); $confirm.ForeColor = [Drawing.Color]::White; $confirm.Font = New-Object Drawing.Font('Segoe UI Semibold',10); $confirm.Add_Click({ $dialog.DialogResult = [Windows.Forms.DialogResult]::Yes; $dialog.Close() })
 $dialog.Controls.AddRange(@($heading,$desc,$rows,$cancel,$confirm)); $result = $dialog.ShowDialog($form); $dialog.Dispose(); return ($result -eq [Windows.Forms.DialogResult]::Yes)
}
$remove.Add_Click({
 $selected = @($list.SelectedItems | ForEach-Object { $_ })
 if ($selected.Count -eq 0) { [Windows.Forms.MessageBox]::Show($form, 'Select one or more games first. Hold Ctrl to select multiple games.', 'Remove games') | Out-Null; return }
 if (Confirm-RemoveGames $selected) { foreach ($item in $selected) { $list.Items.Remove($item) }; Save-Games; Update-GameScroll }
})
$startup = New-Object Windows.Forms.CheckBox
$startup.Text = 'Start automatically with Windows'; $startup.Location = New-Object Drawing.Point(28, 400); $startup.AutoSize = $true; $startup.Anchor = 'Bottom,Left'; $startup.Checked = Test-Path $startupLink
$startup.Add_CheckedChanged({ try { if ($startup.Checked) { $ws = New-Object -ComObject WScript.Shell; $shortcut = $ws.CreateShortcut($startupLink); $shortcut.TargetPath = $applicationPath; $shortcut.Arguments = ''; $shortcut.WorkingDirectory = Split-Path -Parent $applicationPath; $shortcut.IconLocation = $applicationPath; $shortcut.Save() } else { Remove-Item -LiteralPath $startupLink -ErrorAction Stop } } catch { [Windows.Forms.MessageBox]::Show("Could not change startup setting: $_") | Out-Null } })
$status = New-Object Windows.Forms.Label
$status.Location = New-Object Drawing.Point(30, 555); $status.AutoSize = $true; $status.Anchor = 'Bottom,Left'; $status.Text = 'Watching for games...'
$cpuLabel = New-Object Windows.Forms.Label
$cpuLabel.Text = 'CPU: measuring...'; $cpuLabel.Location = New-Object Drawing.Point(310, 555); $cpuLabel.AutoSize = $true; $cpuLabel.Anchor = 'Bottom,Left'; $cpuLabel.ForeColor = [Drawing.Color]::FromArgb(145,165,195)
$script:cpuProcess = [Diagnostics.Process]::GetCurrentProcess(); $script:cpuLast = $script:cpuProcess.TotalProcessorTime.TotalSeconds; $script:cpuClock = [Diagnostics.Stopwatch]::StartNew(); $script:cpuLastTime = 0.0
$nexusCard = New-Object Windows.Forms.Panel
$nexusCard.Location = New-Object Drawing.Point(28, 150); $nexusCard.Size = New-Object Drawing.Size(688, 76); $nexusCard.Anchor = 'Top,Left,Right'; $nexusCard.BackColor = [Drawing.Color]::FromArgb(13, 35, 61)
$nexusImage = New-Object Windows.Forms.PictureBox
$nexusImage.Location = New-Object Drawing.Point(16, 16); $nexusImage.Size = New-Object Drawing.Size(44, 44); $nexusImage.SizeMode = 'Zoom'
try { $appIcon = [Drawing.Icon]::ExtractAssociatedIcon($nexusPath); if ($appIcon) { $nexusImage.Image = $appIcon.ToBitmap() } } catch { }
$nexusName = New-Object Windows.Forms.Label
$nexusName.Text = 'Hello Nexus'; $nexusName.Font = New-Object Drawing.Font('Segoe UI Semibold', 14); $nexusName.ForeColor = [Drawing.Color]::FromArgb(227, 234, 242); $nexusName.Location = New-Object Drawing.Point(76, 12); $nexusName.AutoSize = $true
$nexusStatus = New-Object Windows.Forms.Label
$nexusStatus.Location = New-Object Drawing.Point(78, 43); $nexusStatus.AutoSize = $true; $nexusStatus.ForeColor = if ($themeSwitch.Checked) { [Drawing.Color]::FromArgb(157,170,188) } else { [Drawing.Color]::FromArgb(88,103,120) }; $nexusStatus.Text = 'Checking...'
$nexusExtra = New-Object Windows.Forms.Label
$nexusExtra.Text = '|    Ready'; $nexusExtra.Location = New-Object Drawing.Point(165,43); $nexusExtra.AutoSize = $true; $nexusExtra.ForeColor = [Drawing.Color]::FromArgb(145,165,195)
$pulse = New-Object PulseLine; $pulse.Location = New-Object Drawing.Point(452,19); $pulse.Anchor = 'Top,Right'; $pulse.BackColor = $nexusCard.BackColor
$nexusCard.Controls.AddRange(@($nexusImage,$nexusName,$nexusStatus,$nexusExtra,$pulse))
$nexusButton = New-Object StatusBadge
$nexusButton.Location = New-Object Drawing.Point(594, 21); $nexusButton.BackColor = $nexusCard.BackColor; $nexusButton.Size = New-Object Drawing.Size(84, 34); $nexusButton.Anchor = 'Top,Right'
$nexusToggleLabel = New-Object Windows.Forms.Label
$nexusToggleLabel.Text = ''; $nexusToggleLabel.Font = New-Object Drawing.Font('Segoe UI', 9, [Drawing.FontStyle]::Bold); $nexusToggleLabel.Location = New-Object Drawing.Point(578, 178); $nexusToggleLabel.AutoSize = $true; $nexusToggleLabel.Anchor = 'Top,Right'
$themeLabel = New-Object LineIcon
$themeLabel.Kind = 'moon'; $themeLabel.Location = New-Object Drawing.Point(685, 543); $themeLabel.ForeColor = [Drawing.Color]::FromArgb(155,170,188); $themeLabel.Anchor = 'Bottom,Right'
$themeSwitch = New-Object AnimatedSwitch
$themeSwitch.Checked = [bool]$script:settings.Dark; $themeSwitch.Location = New-Object Drawing.Point(627, 547); $themeSwitch.Size = New-Object Drawing.Size(50, 26); $themeSwitch.Anchor = 'Bottom,Right'
$darkLabel = New-Object LineIcon
$darkLabel.Kind = 'sun'; $darkLabel.Location = New-Object Drawing.Point(585, 543); $darkLabel.ForeColor = [Drawing.Color]::FromArgb(155,170,188); $darkLabel.Anchor = 'Bottom,Right'
function Apply-Theme {
 if (-not $themeSwitch.Checked) {
  $form.BackColor = [Drawing.Color]::FromArgb(246,248,251); $form.ForeColor = [Drawing.Color]::FromArgb(27,39,54)
  $gamePanel.BackColor = [Drawing.Color]::White; $scrollBar.Track = [Drawing.Color]::White; $scrollBar.Thumb = [Drawing.Color]::FromArgb(154,171,193); $scrollBar.Invalidate(); $list.BackColor = [Drawing.Color]::White; $list.ForeColor = $form.ForeColor; $nexusCard.BackColor = [Drawing.Color]::FromArgb(233,240,243)
  $add.BackColor = [Drawing.Color]::FromArgb(0,132,124); $add.ForeColor = [Drawing.Color]::White;$remove.BackColor = [Drawing.Color]::FromArgb(226,232,240); $remove.ForeColor = [Drawing.Color]::FromArgb(35,51,70);$brand.ForeColor = [Drawing.Color]::FromArgb(0,117,110); $status.ForeColor = [Drawing.Color]::FromArgb(0,117,110)
  $menu.BackColor = [Drawing.Color]::White; $menu.ForeColor = $form.ForeColor
  $settingsButton.ForeColor = [Drawing.Color]::FromArgb(80,96,112); $themeLabel.ForeColor = $settingsButton.ForeColor; $darkLabel.ForeColor = $settingsButton.ForeColor
  $pulse.BackColor = $nexusCard.BackColor; $nexusButton.BackColor = $nexusCard.BackColor; $nexusName.ForeColor = $form.ForeColor; $subtitle.ForeColor = [Drawing.Color]::FromArgb(77,92,110); $label.ForeColor = $subtitle.ForeColor
 } else {
  $form.BackColor = [Drawing.Color]::FromArgb(5,15,32); $form.ForeColor = [Drawing.Color]::FromArgb(235,238,245)
  $gamePanel.BackColor = [Drawing.Color]::FromArgb(15,32,56); $scrollBar.Track = [Drawing.Color]::FromArgb(15,32,56); $scrollBar.Thumb = [Drawing.Color]::FromArgb(82,111,148); $scrollBar.Invalidate(); $list.BackColor = [Drawing.Color]::FromArgb(15,32,56); $list.ForeColor = $form.ForeColor; $nexusCard.BackColor = [Drawing.Color]::FromArgb(13,35,61)
  $pulse.BackColor = $nexusCard.BackColor; $nexusButton.BackColor = $nexusCard.BackColor; $nexusName.ForeColor = [Drawing.Color]::FromArgb(227,234,242); $subtitle.ForeColor = [Drawing.Color]::FromArgb(157,170,188); $label.ForeColor = $subtitle.ForeColor
  $add.BackColor = [Drawing.Color]::FromArgb(0,203,199); $add.ForeColor = [Drawing.Color]::White;$remove.BackColor = [Drawing.Color]::FromArgb(29,45,71); $remove.ForeColor = [Drawing.Color]::FromArgb(228,237,250);$brand.ForeColor = [Drawing.Color]::FromArgb(68,212,199); $status.ForeColor = [Drawing.Color]::FromArgb(68,212,199)
  $menu.BackColor = [Drawing.Color]::FromArgb(39,43,53); $menu.ForeColor = [Drawing.Color]::White
  $settingsButton.ForeColor = [Drawing.Color]::FromArgb(155,170,188); $themeLabel.ForeColor = $settingsButton.ForeColor; $darkLabel.ForeColor = $settingsButton.ForeColor
 }
 if ($themeSwitch.Checked) { $themeLabel.ForeColor = [Drawing.Color]::FromArgb(0,220,215); $darkLabel.ForeColor = [Drawing.Color]::FromArgb(120,137,158) } else { $darkLabel.ForeColor = [Drawing.Color]::FromArgb(192,128,16); $themeLabel.ForeColor = [Drawing.Color]::FromArgb(115,129,145) }; $themeLabel.Invalidate(); $darkLabel.Invalidate()
 $dark = if ($themeSwitch.Checked) { 1 } else { 0 }; [void][DarkWindowTitle]::DwmSetWindowAttribute($form.Handle, 20, [ref]$dark, 4)
}
function Set-Theme([bool]$dark) { $themeSwitch.Checked = $dark; $script:settings.Dark = $dark; Save-Settings; Apply-Theme }
$themeSwitch.Add_Click({ Set-Theme (-not $themeSwitch.Checked) })
$themeLabel.Add_Click({ Set-Theme $true })
$darkLabel.Add_Click({ Set-Theme $false })
function Toggle-Nexus {
 try {
  $processes = @(Get-Process -Name 'Nexus','nexus-overlay' -ErrorAction SilentlyContinue)
  if ($processes.Count) { Stop-Nexus; $script:pausedNexus = $false }
  elseif (Test-Path -LiteralPath $nexusPath) { Start-Nexus; $script:pausedNexus = $false }
  else { [Windows.Forms.MessageBox]::Show('Nexus was not found at the configured location.') | Out-Null }
  Update-NexusControl
 } catch { [Windows.Forms.MessageBox]::Show('Could not change Nexus status: ' + $_.Exception.Message) | Out-Null }
}
function Update-NexusControl {
 if (Get-Process -Name 'Nexus' -ErrorAction SilentlyContinue) { $nexusButton.Checked = $true; if ($nexusMenuItem) { $nexusMenuItem.Text = 'Close Nexus' } }
 else { $nexusButton.Checked = $false; if ($nexusMenuItem) { $nexusMenuItem.Text = 'Open Nexus' } }
}
$nexusButton.Add_Click({ Toggle-Nexus })
$list.BackColor = [Drawing.Color]::FromArgb(15, 32, 56)
$list.ForeColor = [Drawing.Color]::FromArgb(235, 238, 245)
$list.BorderStyle = 'None'; $list.GridLines = $false
$list.Font = New-Object Drawing.Font('Segoe UI', 11)
$status.ForeColor = [Drawing.Color]::FromArgb(68, 212, 199)
foreach ($button in @($add, $remove)) { $button.BackColor = [Drawing.Color]::FromArgb(54, 62, 77); $button.ForeColor = [Drawing.Color]::White;}
$add.BackColor = [Drawing.Color]::FromArgb(0, 203, 199); $add.ForeColor = [Drawing.Color]::White; $add.Font = New-Object Drawing.Font('Segoe UI', 10, [Drawing.FontStyle]::Bold)
function Set-Rounded([Windows.Forms.Control]$control, [int]$radius) {
 if ($control.Width -lt 2 -or $control.Height -lt 2) { return }; $d = $radius * 2; $w = $control.Width; $h = $control.Height; $path = New-Object Drawing.Drawing2D.GraphicsPath; $path.AddArc(0,0,$d,$d,180,90); $path.AddArc($w-$d,0,$d,$d,270,90); $path.AddArc($w-$d,$h-$d,$d,$d,0,90); $path.AddArc(0,$h-$d,$d,$d,90,90); $path.CloseFigure(); $control.Region = New-Object Drawing.Region($path); $path.Dispose()
}
Set-Rounded $nexusCard 12; Set-Rounded $gamePanel 12
$nexusCard.Add_Resize({ Set-Rounded $nexusCard 12 }); $gamePanel.Add_Resize({ Set-Rounded $gamePanel 12 })
$form.Controls.AddRange(@($brand,$title,$subtitle,$label,$gamePanel,$add,$remove,$status,$cpuLabel,$nexusCard,$nexusToggleLabel,$themeSwitch,$themeLabel,$darkLabel))
$nexusCard.Controls.Add($nexusButton); $nexusButton.BringToFront()
$settingsButton = New-Object LineIcon
$settingsButton.Kind = 'settings'; $settingsButton.Location = New-Object Drawing.Point(684, 18); $settingsButton.Anchor = 'Top,Right'; $settingsButton.ForeColor = [Drawing.Color]::FromArgb(155,170,188)
$form.Controls.Add($settingsButton)
$settingsButton.Add_Click({
 $dlg = New-Object Windows.Forms.Form
 $dlg.Text = 'Settings'; $dlg.ClientSize = New-Object Drawing.Size(500, 552); $dlg.StartPosition = 'CenterParent'; $dlg.FormBorderStyle = 'FixedDialog'; $dlg.MaximizeBox = $false; $dlg.MinimizeBox = $false; $dlg.Font = New-Object Drawing.Font('Segoe UI', 10); $dlg.Icon = $form.Icon
 $isDark = $themeSwitch.Checked
 if ($isDark) { $dlg.BackColor = [Drawing.Color]::FromArgb(5,15,32); $dlg.ForeColor = [Drawing.Color]::FromArgb(235,241,250); $muted = [Drawing.Color]::FromArgb(144,163,190); $surface = [Drawing.Color]::FromArgb(15,32,56) }
 else { $dlg.BackColor = [Drawing.Color]::FromArgb(246,248,251); $dlg.ForeColor = [Drawing.Color]::FromArgb(27,39,54); $muted = [Drawing.Color]::FromArgb(88,103,120); $surface = [Drawing.Color]::White }
 $dlg.Add_HandleCreated({ $darkTitle = if ($isDark) { 1 } else { 0 }; [void][DarkWindowTitle]::DwmSetWindowAttribute($dlg.Handle,20,[ref]$darkTitle,4) })
 $heading = New-Object Windows.Forms.Label; $heading.Text = 'Settings'; $heading.Font = New-Object Drawing.Font('Segoe UI Semibold', 19); $heading.Location = New-Object Drawing.Point(26,22); $heading.AutoSize = $true
 $desc = New-Object Windows.Forms.Label; $desc.Text = 'Choose how Nexus Guard runs.'; $desc.ForeColor = $muted; $desc.Location = New-Object Drawing.Point(29,62); $desc.AutoSize = $true
 $panel = New-Object Windows.Forms.Panel; $panel.Location = New-Object Drawing.Point(24,104); $panel.Size = New-Object Drawing.Size(452,310); $panel.BackColor = $surface; Set-Rounded $panel 12
 function Add-PreferenceRow($caption,$description,[int]$y,[bool]$value) {
  $name = New-Object Windows.Forms.Label; $name.Text = $caption; $name.Font = New-Object Drawing.Font('Segoe UI Semibold',10); $name.Location = New-Object Drawing.Point(20,$y); $name.AutoSize = $true; $name.ForeColor = $dlg.ForeColor
  $detail = New-Object Windows.Forms.Label; $detail.Text = $description; $detail.Font = New-Object Drawing.Font('Segoe UI',8.5); $detail.Location = New-Object Drawing.Point(21,($y+23)); $detail.AutoSize = $true; $detail.ForeColor = $muted
  $switch = New-Object AnimatedSwitch; $switch.Location = New-Object Drawing.Point(378,($y+6)); $switch.Size = New-Object Drawing.Size(50,26); $switch.Checked = $value; $switch.Add_Click({ $this.Checked = -not $this.Checked })
  $panel.Controls.AddRange(@($name,$detail,$switch)); return $switch
 }
 $auto = Add-PreferenceRow 'Start with Windows' 'Launch automatically when you sign in.' 16 (Test-Path $startupLink)
 $mini = Add-PreferenceRow 'Minimize to tray' 'Keep the taskbar clear when minimized.' 76 ([bool]$script:settings.MinimizeToTray)
 $close = Add-PreferenceRow 'Close to tray' 'Continue watching after closing the window.' 136 ([bool]$script:settings.CloseToTray)
 $hidden = Add-PreferenceRow 'Start quietly' 'Open directly in the system tray.' 196 ([bool]$script:settings.StartHidden)
 $darkPref = Add-PreferenceRow 'Dark appearance' 'Use the dark color theme.' 256 ([bool]$themeSwitch.Checked)
 $intervalLabel = New-Object Windows.Forms.Label; $intervalLabel.Text = 'Check interval'; $intervalLabel.Font = New-Object Drawing.Font('Segoe UI Semibold',10); $intervalLabel.Location = New-Object Drawing.Point(29,433); $intervalLabel.AutoSize = $true
 $intervalHelp = New-Object Windows.Forms.Label; $intervalHelp.Text = 'How often to look for running games.'; $intervalHelp.Font = New-Object Drawing.Font('Segoe UI',8.5); $intervalHelp.ForeColor = $muted; $intervalHelp.Location = New-Object Drawing.Point(30,457); $intervalHelp.AutoSize = $true
 $interval = New-Object Windows.Forms.Label; $interval.Text = [string][Math]::Max(2,[Math]::Min(60,[int]$script:settings.PollSeconds)); $interval.Location = New-Object Drawing.Point(365,439); $interval.Size = New-Object Drawing.Size(34,30); $interval.TextAlign = 'MiddleCenter'; $interval.ForeColor = $dlg.ForeColor
 $minus = New-Object ModernButton; $minus.Text = [string][char]0x2212; $minus.Location = New-Object Drawing.Point(328,439); $minus.Size = New-Object Drawing.Size(32,30); $minus.BackColor = $surface; $minus.ForeColor = $dlg.ForeColor; $minus.Add_Click({ $interval.Text = [string][Math]::Max(2,([int]$interval.Text - 1)) })
 $plus = New-Object ModernButton; $plus.Text = '+'; $plus.Location = New-Object Drawing.Point(404,439); $plus.Size = New-Object Drawing.Size(32,30); $plus.BackColor = $surface; $plus.ForeColor = $dlg.ForeColor; $plus.Add_Click({ $interval.Text = [string][Math]::Min(60,([int]$interval.Text + 1)) })
 $seconds = New-Object Windows.Forms.Label; $seconds.Text = 'sec'; $seconds.ForeColor = $muted; $seconds.Location = New-Object Drawing.Point(444,444); $seconds.AutoSize = $true
 $save = New-Object ModernButton; $save.Text = 'Save changes'; $save.Accent = $true; $save.Location = New-Object Drawing.Point(326,493); $save.Size = New-Object Drawing.Size(150,39); $save.ForeColor = [Drawing.Color]::White; $save.Font = New-Object Drawing.Font('Segoe UI Semibold',10)
 $save.Add_Click({ try { $startup.Checked = $auto.Checked; if ($startup.Checked -ne $auto.Checked) { throw 'Could not change startup setting.' }; $script:settings.MinimizeToTray = $mini.Checked; $script:settings.CloseToTray = $close.Checked; $script:settings.StartHidden = $hidden.Checked; $script:settings.PollSeconds = [int]$interval.Text; $themeSwitch.Checked = $darkPref.Checked; $script:settings.Dark = $darkPref.Checked; Apply-Theme; Save-Settings; $timer.Interval = $script:settings.PollSeconds * 1000; $dlg.Close() } catch { [Windows.Forms.MessageBox]::Show('Could not save settings: ' + $_.Exception.Message) | Out-Null } })
 $cancel = New-Object ModernButton; $cancel.Text = 'Cancel'; $cancel.Location = New-Object Drawing.Point(210,493); $cancel.Size = New-Object Drawing.Size(105,39); $cancel.BackColor = $surface; $cancel.ForeColor = $dlg.ForeColor; $cancel.Add_Click({ $dlg.Close() })
 $dlg.Controls.AddRange(@($heading,$desc,$panel,$intervalLabel,$intervalHelp,$interval,$minus,$plus,$seconds,$save,$cancel)); [void]$dlg.ShowDialog($form); $dlg.Dispose()
})
$icon = New-Object Windows.Forms.NotifyIcon
$icon.Icon = New-Object Drawing.Icon (Join-Path $base 'Nexus-Watcher.ico'); $icon.Text = 'Nexus Guard'; $icon.Visible = $true
$menu = New-Object Windows.Forms.ContextMenuStrip
$menu.ShowImageMargin = $false
$menu.ShowCheckMargin = $false
$menu.BackColor = [Drawing.Color]::FromArgb(39, 43, 53)
$menu.ForeColor = [Drawing.Color]::White
$open = $menu.Items.Add('Open'); $open.Add_Click({ $form.ShowInTaskbar = $true; $form.Show(); $form.WindowState = 'Normal'; $form.Activate() })
$nexusMenuItem = $menu.Items.Add('Open Nexus'); $nexusMenuItem.Add_Click({ Toggle-Nexus })
Update-NexusControl
$toggle = $menu.Items.Add('Pause monitoring')
$toggle.Add_Click({
 $script:monitoring = -not $script:monitoring
 if ($script:monitoring) { $toggle.Text = 'Pause monitoring'; $status.Text = 'Watching for games...' } else { $toggle.Text = 'Resume monitoring'; $status.Text = 'Monitoring paused'; if ($script:pausedNexus -and -not (Get-Process -Name 'Nexus' -ErrorAction SilentlyContinue) -and (Test-Path $nexusPath)) { Start-Nexus }; $script:pausedNexus = $false }
})
$exitItem = $menu.Items.Add('Exit'); $exitItem.Add_Click({ $script:quitting = $true; $form.Close() })
$icon.ContextMenuStrip = $menu
$icon.Add_DoubleClick({ $form.ShowInTaskbar = $true; $form.Show(); $form.WindowState = 'Normal'; $form.Activate() })
$form.Add_FormClosing({ param($sender,$e) if (-not $script:quitting -and $script:settings.CloseToTray) { $e.Cancel = $true; $form.Hide() } })
$form.Add_Resize({ if ($script:settings.MinimizeToTray -and $form.WindowState -eq [Windows.Forms.FormWindowState]::Minimized) { $form.Hide(); $form.ShowInTaskbar = $false } })
$timer = New-Object Windows.Forms.Timer; $timer.Interval = [Math]::Max(2,[Math]::Min(60,[int]$script:settings.PollSeconds)) * 1000
$timer.Add_Tick({
 Update-GameScroll
 try { $script:cpuProcess.Refresh(); $nowCpu = $script:cpuProcess.TotalProcessorTime.TotalSeconds; $nowTime = $script:cpuClock.Elapsed.TotalSeconds; $elapsed = $nowTime - $script:cpuLastTime; if ($elapsed -gt 0) { $percent = 100 * ($nowCpu - $script:cpuLast) / $elapsed / [Environment]::ProcessorCount; $cpuLabel.Text = 'CPU: ' + $percent.ToString('0.00') + '%' }; $script:cpuLast = $nowCpu; $script:cpuLastTime = $nowTime } catch { $cpuLabel.Text = 'CPU: unavailable' }
 Update-NexusControl
 if (-not $script:monitoring) { if (Get-Process -Name 'Nexus' -ErrorAction SilentlyContinue) { $nexusStatus.Text = 'Running'; $nexusStatus.ForeColor = if ($themeSwitch.Checked) { [Drawing.Color]::FromArgb(68,212,199) } else { [Drawing.Color]::FromArgb(0,117,110) } } else { $nexusStatus.Text = 'Closed'; $nexusStatus.ForeColor = if ($themeSwitch.Checked) { [Drawing.Color]::FromArgb(157,170,188) } else { [Drawing.Color]::FromArgb(88,103,120) } }; return }
 try {
  $names = @($list.Items | ForEach-Object { [IO.Path]::GetFileNameWithoutExtension([string]$_.Tag) } | Where-Object { $_ })
  $running = $names.Count -gt 0 -and @(Get-Process -Name $names -ErrorAction SilentlyContinue).Count -gt 0
  if ($running -and -not $script:pausedNexus) {
   $nexus = @(Get-Process -Name 'Nexus','nexus-overlay' -ErrorAction SilentlyContinue)
   if ($nexus.Count) { Stop-Nexus; $script:pausedNexus = $true }
  } elseif (-not $running -and $script:pausedNexus) {
   if (-not (Get-Process -Name 'Nexus' -ErrorAction SilentlyContinue) -and (Test-Path $nexusPath)) { Start-Nexus }
   $script:pausedNexus = $false
  }
  if ($running) { $status.Text = 'Game detected' } else { $status.Text = 'Watching for games...' }
  $nexusExtra.Visible = [bool](Get-Process -Name 'Nexus' -ErrorAction SilentlyContinue)
  if (Get-Process -Name 'Nexus' -ErrorAction SilentlyContinue) { $nexusStatus.Text = 'Running'; $nexusStatus.ForeColor = if ($themeSwitch.Checked) { [Drawing.Color]::FromArgb(68,212,199) } else { [Drawing.Color]::FromArgb(0,117,110) } } elseif ($script:pausedNexus) { $nexusStatus.Text = 'Paused for game'; $nexusStatus.ForeColor = if ($themeSwitch.Checked) { [Drawing.Color]::FromArgb(244,191,94) } else { [Drawing.Color]::FromArgb(143,88,0) } } else { $nexusStatus.Text = 'Closed'; $nexusStatus.ForeColor = if ($themeSwitch.Checked) { [Drawing.Color]::FromArgb(157,170,188) } else { [Drawing.Color]::FromArgb(88,103,120) } }
 } catch { $status.Text = 'Error: ' + $_.Exception.Message }
})
$timer.Start()
Apply-Theme
$form.Add_Shown({ if ($script:settings.StartHidden) { $form.Hide(); $form.ShowInTaskbar = $false } })
try { [Windows.Forms.Application]::Run($form) } finally {
 $timer.Stop(); if ($script:pausedNexus -and -not (Get-Process -Name 'Nexus' -ErrorAction SilentlyContinue) -and (Test-Path $nexusPath)) { Start-Nexus }
 $icon.Visible = $false; $icon.Dispose(); $mutex.ReleaseMutex(); $mutex.Dispose()
}

























