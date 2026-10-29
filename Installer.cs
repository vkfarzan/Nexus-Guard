using System;
using System.IO;
using System.Reflection;
using System.Diagnostics;
using System.Drawing;
using System.Windows.Forms;
using Microsoft.Win32;
internal static class Installer {
 static string dir=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"Programs","Nexus Guard");
 static string app=Path.Combine(dir,"Nexus Guard.exe");
 static string shortcut=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Programs),"Nexus Guard.lnk");
 static string startup=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Startup),"Nexus Guard.lnk");
 static string uninstallKey=@"Software\Microsoft\Windows\CurrentVersion\Uninstall\NexusGuard";
 static void Shortcut(string path) { Type t=Type.GetTypeFromProgID("WScript.Shell"); dynamic shell=Activator.CreateInstance(t); dynamic l=shell.CreateShortcut(path); l.TargetPath=app; l.WorkingDirectory=dir; l.IconLocation=app+",0"; l.Description="Nexus Guard"; l.Save(); }
 static void Install(bool autostart) {
  Directory.CreateDirectory(dir);
  using(var input=Assembly.GetExecutingAssembly().GetManifestResourceStream("NexusGuard.portable")) using(var output=File.Create(app)) { if(input==null)throw new Exception("Installer package is incomplete."); input.CopyTo(output); }
  string uninstaller=Path.Combine(dir,"Uninstall Nexus Guard.exe"); File.Copy(Assembly.GetExecutingAssembly().Location,uninstaller,true);
  Shortcut(shortcut); if(autostart)Shortcut(startup);
  using(var key=Registry.CurrentUser.CreateSubKey(uninstallKey)) { key.SetValue("DisplayName","Nexus Guard"); key.SetValue("DisplayVersion","1.0.0"); key.SetValue("DisplayIcon",app); key.SetValue("InstallLocation",dir); key.SetValue("UninstallString","\""+uninstaller+"\" --uninstall"); key.SetValue("NoModify",1,RegistryValueKind.DWord); key.SetValue("NoRepair",1,RegistryValueKind.DWord); }
 }
 [STAThread] static int Main(string[] args) {
  if(args.Length>0 && args[0]=="--self-test") { using(var s=Assembly.GetExecutingAssembly().GetManifestResourceStream("NexusGuard.portable")) return s!=null&&s.Length>0?0:1; }
  Application.EnableVisualStyles();
  if(args.Length>0 && args[0]=="--uninstall") { if(MessageBox.Show("Remove Nexus Guard? Your game list and settings will remain on this computer.","Nexus Guard",MessageBoxButtons.YesNo,MessageBoxIcon.Question)!=DialogResult.Yes)return 0; try { if(File.Exists(shortcut))File.Delete(shortcut); if(File.Exists(startup))File.Delete(startup); if(File.Exists(app))File.Delete(app); Registry.CurrentUser.DeleteSubKey(uninstallKey,false); MessageBox.Show("Nexus Guard was removed. Your settings were kept.","Nexus Guard"); } catch(Exception e){MessageBox.Show("Could not uninstall: "+e.Message,"Nexus Guard");return 1;} return 0; }
  using(var f=new Form()) {
   f.Text="Install Nexus Guard"; f.ClientSize=new Size(460,300); f.StartPosition=FormStartPosition.CenterScreen; f.FormBorderStyle=FormBorderStyle.FixedDialog; f.MaximizeBox=false; f.Font=new Font("Segoe UI",10); f.BackColor=Color.FromArgb(8,18,36); f.ForeColor=Color.FromArgb(235,241,250); f.Icon=Icon.ExtractAssociatedIcon(Assembly.GetExecutingAssembly().Location);
   var title=new Label {Text="Install Nexus Guard",Font=new Font("Segoe UI Semibold",19),AutoSize=true,Location=new Point(27,24)};
   var desc=new Label {Text="Pause Nexus while your selected games run.",AutoSize=true,ForeColor=Color.FromArgb(153,174,201),Location=new Point(30,72)};
   var where=new Label {Text="Install for this Windows user:",AutoSize=true,Location=new Point(30,115)};
   var path=new Label {Text=dir,AutoEllipsis=true,Size=new Size(402,32),ForeColor=Color.FromArgb(153,174,201),Location=new Point(30,142)};
   var auto=new CheckBox {Text="Start automatically with Windows",AutoSize=true,Location=new Point(30,190),Checked=false};
   var install=new Button {Text="Install",Size=new Size(115,38),Location=new Point(315,239),FlatStyle=FlatStyle.Flat,BackColor=Color.FromArgb(70,110,224),ForeColor=Color.White}; install.FlatAppearance.BorderSize=0;
   var cancel=new Button {Text="Cancel",Size=new Size(100,38),Location=new Point(205,239),FlatStyle=FlatStyle.Flat,BackColor=Color.FromArgb(26,43,67),ForeColor=Color.White}; cancel.FlatAppearance.BorderSize=0; cancel.Click+=(s,e)=>f.Close();
   install.Click+=(s,e)=>{ try { Install(auto.Checked); if(MessageBox.Show("Nexus Guard is installed. Open it now?","Nexus Guard",MessageBoxButtons.YesNo,MessageBoxIcon.Information)==DialogResult.Yes) Process.Start(app); f.Close(); } catch(Exception ex) {MessageBox.Show("Installation failed: "+ex.Message,"Nexus Guard",MessageBoxButtons.OK,MessageBoxIcon.Error);} };
   f.Controls.AddRange(new Control[]{title,desc,where,path,auto,install,cancel}); Application.Run(f);
  } return 0;
 }
}
